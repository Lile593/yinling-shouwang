import router from '@ohos.router'
import { promptAction } from '@kit.ArkUI'
import { VoiceService } from '../services/VoiceService'
import { ApiService } from '../services/ApiService'
import { ServiceType, ServiceIcons } from '../models/ServiceModels'
import { Colors, Sizes } from '../common/DesignTokens'

@Entry
@Component
struct VoicePage {
  @State time: number = 5
  @State isRecording: boolean = false
  @State tip: string = '请点击下方按钮，说出您的需求'
  @State recognizedText: string = ''
  @State confidence: number = 0
  @State serviceType: ServiceType = ServiceType.WECHAT
  private countTimer: number | null = null
  private voiceService: VoiceService = VoiceService.getInstance()
  private apiService: ApiService = ApiService.getInstance()

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
          .fontSize(Sizes.BODY_L)
          .fontColor(Colors.PRIMARY)
          .onClick(() => router.back())
      }
      .width('100%')
      .padding({ left: Sizes.SPACING_L, top: 20, bottom: 12 })

      Column({ space: Sizes.SPACING_S }) {
        Text('语音录入需求')
          .fontSize(Sizes.TITLE_XL)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_PRIMARY)
        Row({ space: 6 }) {
          Text('当前服务:')
            .fontSize(Sizes.BODY_L)
            .fontColor(Colors.TEXT_HINT)
          Text(this.getServiceName())
            .fontSize(Sizes.BODY_L)
            .fontWeight(FontWeight.Medium)
            .fontColor(Colors.PRIMARY)
            .padding({ left: 12, right: 12, top: 5, bottom: 5 })
            .backgroundColor(Colors.PRIMARY_LIGHT)
            .borderRadius(10)
        }
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .margin({ top: Sizes.SPACING_S })

      Row() {
        Text(this.tip)
          .fontSize(20)
          .fontColor(Colors.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
      }
      .width('80%')
      .margin({ top: Sizes.SPACING_XL, bottom: Sizes.SPACING_S })
      .justifyContent(FlexAlign.Center)

      if (this.recognizedText) {
        Column({ space: Sizes.SPACING_S }) {
          Row({ space: 6 }) {
            Text('✓').fontSize(Sizes.BODY_M).fontColor(Colors.SUCCESS).fontWeight(FontWeight.Bold)
            Text('识别结果').fontSize(Sizes.BODY_M).fontColor(Colors.SUCCESS).fontWeight(FontWeight.Medium)
            Text(`(置信度 ${(this.confidence * 100).toFixed(0)}%)`)
              .fontSize(Sizes.CAPTION)
              .fontColor(Colors.TEXT_HINT)
          }
          Text(this.recognizedText)
            .fontSize(22)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
            .maxLines(3)
        }
        .width('88%')
        .padding(20)
        .backgroundColor(Colors.PRIMARY_LIGHT)
        .borderRadius(Sizes.SPACING_M)
        .margin({ top: Sizes.SPACING_M })
      }

      Blank()

      Column({ space: Sizes.SPACING_M }) {
        Text(this.isRecording ? this.time.toString() : '')
          .fontSize(20)
          .fontColor(Colors.TEXT_HINT)

        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(176)
            .height(176)
            .fill(this.isRecording ? Colors.DANGER : Colors.PRIMARY)
            .shadow({
              radius: this.isRecording ? 32 : 16,
              color: this.isRecording ? Colors.DANGER + '66' : Colors.PRIMARY + '66'
            })

          if (this.isRecording) {
            Column({ space: 2 }) {
              Text(this.time.toString())
                .fontSize(64)
                .fontColor(Colors.TEXT_WHITE)
                .fontWeight(FontWeight.Bold)
              Text('秒')
                .fontSize(Sizes.BODY_L)
                .fontColor('rgba(255,255,255,0.85)')
            }
          } else {
            Column({ space: 6 }) {
              Text('🎤')
                .fontSize(40)
              Text(this.recognizedText ? '重新录入' : '点击开始录入')
                .fontSize(18)
                .fontColor(Colors.TEXT_WHITE)
                .fontWeight(FontWeight.Medium)
            }
          }
        }
        .onClick(() => this.startRecording())

        Text(this.recognizedText ? '点击圆圈可重新录入' : '点击后连续录入5秒，AI自动识别')
          .fontSize(Sizes.BODY_M)
          .fontColor(Colors.TEXT_DISABLED)
      }

      if (this.recognizedText) {
        Button('确认，开始匹配志愿者')
          .width('84%')
          .height(56)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_WHITE)
          .backgroundColor(Colors.PRIMARY)
          .borderRadius(Sizes.RADIUS_BTN)
          .shadow({ radius: 12, color: Colors.PRIMARY + '44', offsetY: 4 })
          .margin({ bottom: Sizes.SPACING_M })
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
    .backgroundColor(Colors.BG_PRIMARY)
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
      this.confidence = result.confidence
      this.serviceType = result.intent
      this.tip = `识别成功，置信度 ${(result.confidence * 100).toFixed(0)}%`

      this.apiService.uploadVoice(result.text, result.intent)
    } catch (e) {
      this.tip = '识别失败，请点击按钮重新录入'
      promptAction.showToast({ message: '语音识别失败，请重试', duration: 2000 })
    }
  }
}
