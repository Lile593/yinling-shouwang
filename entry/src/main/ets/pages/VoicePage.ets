import router from '@ohos.router'
import { promptAction } from '@kit.ArkUI'
import { http } from '@kit.NetworkKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { VoiceService } from '../services/VoiceService'
import { ServiceType } from '../models/ServiceModels'

@Entry
@Component
struct VoicePage {
  @State time: number = 5
  @State isRecording: boolean = false
  @State tip: string = '点击按钮，开始说出您的需求'
  @State recognizedText: string = ''
  @State serviceType: ServiceType = ServiceType.WECHAT
  private countTimer: number | null = null
  private voiceService: VoiceService = VoiceService.getInstance()

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    if (params && params['serviceType']) {
      this.serviceType = params['serviceType'] as ServiceType
      this.tip = `请说出与"${this.getServiceName()}"相关的需求`
    }
  }

  getServiceName(): string {
    const names: Record<string, string> = {
      'wechat': '微信使用', 'medical_booking': '医院挂号',
      'health_insurance': '医保社保', 'transport': '打车导航'
    }
    return names[this.serviceType] || '服务'
  }

  build() {
    Column({ space: 20 }) {
      Row() {
        Text('< 返回').fontSize(18).fontColor('#0066CC').onClick(() => router.back())
      }
      .width('100%').padding({ left: 20, top: 16 })

      Column({ space: 8 }) {
        Text('语音录入需求').fontSize(30).fontWeight(FontWeight.Bold)
        Text(`当前服务: ${this.getServiceName()}`).fontSize(16).fontColor('#8899AA')
      }
      .margin({ top: 20 })

      Text(this.tip).fontSize(20).fontColor('#555').textAlign(TextAlign.Center).width('80%').margin({ top: 20 })

      if (this.recognizedText) {
        Column() {
          Text('识别结果:').fontSize(14).fontColor('#888')
          Text(this.recognizedText).fontSize(18).fontColor('#333').fontWeight(FontWeight.Medium).margin({ top: 4 })
        }
        .padding(16).backgroundColor('#F0F4FF').borderRadius(12).width('85%')
      }

      // 录音按钮
      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(160).height(160)
          .fill(this.isRecording ? '#FF4444' : '#0066CC')
          .shadow({ radius: this.isRecording ? 24 : 12, color: this.isRecording ? '#FF444488' : '#0066CC88' })

        if (this.isRecording) {
          Column({ space: 4 }) {
            Text(this.time.toString()).fontSize(56).fontColor('#fff').fontWeight(FontWeight.Bold)
            Text('秒').fontSize(16).fontColor('rgba(255,255,255,0.8)')
          }
        } else {
          Column({ space: 4 }) {
            Text('🎤').fontSize(36)
            Text(this.recognizedText ? '重新录入' : '开始录入').fontSize(16).fontColor('#fff')
          }
        }
      }
      .margin({ top: 30 })
      .onClick(() => this.startRecording())

      Text(this.recognizedText ? '点击可重新录入，或' : '5秒自动识别您的语音需求')
        .fontSize(14).fontColor('#99AABB').margin({ top: 16 })

      if (this.recognizedText) {
        Button('确认，开始匹配志愿者')
          .width('80%').height(52).fontSize(20).fontWeight(FontWeight.Medium)
          .backgroundColor('#0066CC').borderRadius(26).margin({ top: 20 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ResultPage',
              params: { serviceType: this.serviceType, voiceText: this.recognizedText }
            })
          })
      }
    }
    .width('100%').height('100%').backgroundColor('#FFFFFF')
  }

  startRecording(): void {
    if (this.countTimer) clearInterval(this.countTimer)
    this.time = 5
    this.isRecording = true
    this.recognizedText = ''
    this.tip = '正在聆听您的需求...'

    this.countTimer = setInterval(() => {
      this.time--
      if (this.time <= 0) {
        clearInterval(this.countTimer!)
        this.isRecording = false
        this.tip = 'AI正在识别您的语音...'
        this.processVoice()
      }
    }, 1000)
  }

  async processVoice(): Promise<void> {
    // 先尝试本地语音识别
    try {
      const result = await this.voiceService.startRecognition()
      this.recognizedText = result.text
      this.serviceType = result.intent
      this.tip = `识别成功！置信度: ${(result.confidence * 100).toFixed(0)}%`

      // 同时上传到AI边缘计算节点
      this.uploadToAIEdge(result.text)
    } catch (e) {
      this.tip = '识别失败，请重新录入'
      promptAction.showToast({ message: '语音识别失败，请重试', duration: 2000 })
    }
  }

  // 对接AI边缘计算后端
  uploadToAIEdge(text: string): void {
    let httpRequest = http.createHttp()
    httpRequest.request('http://192.168.10.1:8000/ai-service', {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/json' },
      extraData: {
        voice_text: text,
        service_type: this.serviceType,
        timestamp: new Date().toISOString()
      }
    }, (err: BusinessError) => {
      if (!err) {
        console.info('[VoicePage] AI service request succeeded')
      } else {
        console.error(`[VoicePage] AI service request failed: ${err.message}`)
      }
    })
  }
}
