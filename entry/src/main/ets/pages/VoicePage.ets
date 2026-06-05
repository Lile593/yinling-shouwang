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
  @State tip: string = '请点击下方按钮，说出您的需求'
  @State recognizedText: string = ''
  @State serviceType: ServiceType = ServiceType.WECHAT
  private countTimer: number | null = null
  private voiceService: VoiceService = VoiceService.getInstance()

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    if (params && params['serviceType']) {
      this.serviceType = params['serviceType'] as ServiceType
      this.tip = `请说出与「${this.getServiceName()}」相关的需求`
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
    Column({ space: 0 }) {
      Row() {
        Text('< 返回')
          .fontSize(20)
          .fontColor('#0066CC')
          .onClick(() => router.back())
      }
      .width('100%')
      .padding({ left: 24, top: 20, bottom: 12 })

      Column({ space: 8 }) {
        Text('语音录入需求')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A2E')
        Row({ space: 6 }) {
          Text('当前服务:')
            .fontSize(18)
            .fontColor('#8899AA')
          Text(this.getServiceName())
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#0066CC')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor('#EBF4FF')
            .borderRadius(8)
        }
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .margin({ top: 8 })

      Row() {
        Text(this.tip)
          .fontSize(20)
          .fontColor('#555555')
          .textAlign(TextAlign.Center)
      }
      .width('80%')
      .margin({ top: 32, bottom: 8 })
      .justifyContent(FlexAlign.Center)

      if (this.recognizedText) {
        Column({ space: 6 }) {
          Text('✓ 识别结果')
            .fontSize(15)
            .fontColor('#0066CC')
            .fontWeight(FontWeight.Medium)
          Text(this.recognizedText)
            .fontSize(22)
            .fontColor('#1A1A2E')
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
            .maxLines(3)
        }
        .width('88%')
        .padding(20)
        .backgroundColor('#EBF4FF')
        .borderRadius(16)
        .margin({ top: 12 })
      }

      Blank()

      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(180)
          .height(180)
          .fill(this.isRecording ? '#FF4444' : '#0066CC')
          .shadow({
            radius: this.isRecording ? 32 : 16,
            color: this.isRecording ? '#FF444466' : '#0066CC66'
          })

        if (this.isRecording) {
          Column({ space: 2 }) {
            Text(this.time.toString())
              .fontSize(64)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
            Text('秒')
              .fontSize(18)
              .fontColor('rgba(255,255,255,0.85)')
          }
        } else {
          Column({ space: 6 }) {
            Text('🎤')
              .fontSize(42)
            Text(this.recognizedText ? '重新录入' : '开始录入')
              .fontSize(20)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
          }
        }
      }
      .onClick(() => this.startRecording())

      Text(this.recognizedText ? '点击圆圈可重新录入' : '点击后连续录入5秒，AI自动识别')
        .fontSize(16)
        .fontColor('#AABBCC')
        .margin({ top: 28 })

      if (this.recognizedText) {
        Button('确认，开始匹配志愿者')
          .width('84%')
          .height(56)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#0066CC')
          .borderRadius(28)
          .shadow({ radius: 12, color: '#0066CC44', offsetY: 4 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ResultPage',
              params: { serviceType: this.serviceType, voiceText: this.recognizedText }
            })
          })
      }

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  startRecording(): void {
    if (this.countTimer) clearInterval(this.countTimer)
    this.time = 5
    this.isRecording = true
    this.recognizedText = ''

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
    try {
      const result = await this.voiceService.startRecognition()
      this.recognizedText = result.text
      this.serviceType = result.intent
      this.tip = `识别成功，置信度 ${(result.confidence * 100).toFixed(0)}%`

      this.uploadToAIEdge(result.text)
    } catch (e) {
      this.tip = '识别失败，请点击按钮重新录入'
      promptAction.showToast({ message: '语音识别失败，请重试', duration: 2000 })
    }
  }

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
