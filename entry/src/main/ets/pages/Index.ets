import router from '@ohos.router'
import { ServiceType, ServiceTypeLabel, ServiceIcons } from '../models/ServiceModels'
import { DateUtils } from '../utils/DateUtils'
import { Colors, Sizes } from '../common/DesignTokens'

@Entry
@Component
struct Index {
  @State currentTime: string = ''
  @State greeting: string = ''
  @State unreadCount: number = 0

  async aboutToAppear(): Promise<void> {
    const now = new Date()
    const hour = now.getHours()
    if (hour < 6) this.greeting = '夜深了'
    else if (hour < 9) this.greeting = '早上好'
    else if (hour < 12) this.greeting = '上午好'
    else if (hour < 14) this.greeting = '中午好'
    else if (hour < 18) this.greeting = '下午好'
    else this.greeting = '晚上好'
    this.currentTime = DateUtils.formatDateTime(Date.now())
  }

  build() {
    Column({ space: 0 }) {
      Column({ space: Sizes.SPACING_XS }) {
        Text(`${this.greeting}，欢迎使用`)
          .fontSize(Sizes.BODY_L)
          .fontColor(Colors.TEXT_HINT)
        Text('银龄守望')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_PRIMARY)
        Text('老年数字生活互助平台')
          .fontSize(Sizes.BODY_M)
          .fontColor(Colors.TEXT_HINT)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .padding({ left: Sizes.SPACING_L, right: Sizes.SPACING_L, top: 52, bottom: 36 })
      .backgroundColor(Colors.BG_PRIMARY)
      .borderRadius({ bottomLeft: 32, bottomRight: 32 })
      .shadow({ radius: 16, color: '#0000000A', offsetY: 4 })

      Column({ space: Sizes.SPACING_S }) {
        Text('需要什么帮助？')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_PRIMARY)
        Text('点击下方卡片，语音说出您的需求')
          .fontSize(Sizes.BODY_M)
          .fontColor(Colors.TEXT_HINT)
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .padding({ left: Sizes.SPACING_L, right: Sizes.SPACING_L, top: 28, bottom: 20 })

      Grid() {
        GridItem() {
          this.ServiceCard('微信使用', Colors.SUCCESS, ServiceIcons['wechat'], ServiceType.WECHAT,
            '聊天 · 朋友圈 · 视频通话')
        }
        GridItem() {
          this.ServiceCard('医院挂号', Colors.PRIMARY, ServiceIcons['medical_booking'], ServiceType.MEDICAL_BOOKING,
            '预约挂号 · 问诊导航')
        }
        GridItem() {
          this.ServiceCard('医保社保', Colors.WARNING, ServiceIcons['health_insurance'], ServiceType.HEALTH_INSURANCE,
            '医保查询 · 社保办理')
        }
        GridItem() {
          this.ServiceCard('打车导航', Colors.PURPLE, ServiceIcons['transport'], ServiceType.TRANSPORT,
            '叫车出行 · 路线导航')
        }
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(Sizes.SPACING_M)
      .rowsGap(Sizes.SPACING_M)
      .padding({ left: 20, right: 20, top: 8, bottom: 8 })
      .width('100%')
      .layoutWeight(1)

      Button() {
        Row({ space: Sizes.SPACING_S }) {
          Text('📋').fontSize(20)
          Text('查看我的预约').fontSize(Sizes.BODY_L).fontWeight(FontWeight.Medium)
        }
      }
      .width('88%')
      .height(52)
      .fontColor(Colors.PRIMARY)
      .backgroundColor(Colors.PRIMARY_LIGHT)
      .borderRadius(Sizes.RADIUS_BTN)
      .margin({ bottom: Sizes.SPACING_S })
      .onClick(() => {
        router.pushUrl({ url: 'pages/AppointmentsPage' })
      })

      Column({ space: Sizes.SPACING_S }) {
        Row({ space: 6 }) {
          Text('🔒').fontSize(Sizes.BODY_M)
          Text('志愿者实名认证 · 服务全程免费 · 隐私严格保密')
            .fontSize(Sizes.BODY_S)
            .fontColor(Colors.TEXT_HINT)
        }
        Text(`更新时间: ${this.currentTime}`)
          .fontSize(Sizes.CAPTION)
          .fontColor(Colors.TEXT_DISABLED)
      }
      .margin({ top: 4, bottom: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BG_SECONDARY)
  }

  @Builder
  ServiceCard(name: string, color: ResourceColor, icon: string, type: ServiceType, desc: string) {
    Column({ space: 12 }) {
      Text(icon)
        .fontSize(44)
      Column({ space: 6 }) {
        Text(name)
          .fontSize(Sizes.TITLE_M)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_WHITE)
        Text(desc)
          .fontSize(Sizes.BODY_S)
          .fontColor('rgba(255,255,255,0.85)')
          .textAlign(TextAlign.Center)
          .maxLines(1)
      }
    }
    .width('100%')
    .height(180)
    .backgroundColor(color)
    .borderRadius(Sizes.RADIUS_CARD + 4)
    .justifyContent(FlexAlign.Center)
    .shadow({ radius: 16, color: color, offsetY: 6 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/VoicePage', params: { serviceType: type } })
    })
  }
}
