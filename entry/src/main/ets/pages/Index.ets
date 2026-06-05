import router from '@ohos.router'
import { ServiceType, ServiceTypeLabel } from '../models/ServiceModels'
import { DateUtils } from '../utils/DateUtils'

@Entry
@Component
struct Index {
  @State currentTime: string = ''
  @State greeting: string = ''

  aboutToAppear(): void {
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
      Column({ space: 4 }) {
        Text(`${this.greeting}，欢迎使用`)
          .fontSize(20)
          .fontColor('#8899AA')
        Row({ space: 8 }) {
          Text('银龄守望')
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A2E')
        }
        Text('老年数字生活互助平台')
          .fontSize(16)
          .fontColor('#8899AA')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .padding({ left: 24, right: 24, top: 48, bottom: 32 })
      .backgroundColor('#FFFFFF')
      .borderRadius({ bottomLeft: 32, bottomRight: 32 })
      .shadow({ radius: 16, color: '#0000000A', offsetY: 4 })

      Column({ space: 8 }) {
        Text('需要什么帮助？')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A2E')
        Text('点击下方卡片，语音说出您的需求')
          .fontSize(16)
          .fontColor('#99AABB')
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .padding({ left: 24, right: 24, top: 28, bottom: 16 })

      Grid() {
        GridItem() {
          this.ServiceCard('微信使用', '#07C160', '💬', ServiceType.WECHAT,
            '聊天 · 朋友圈 · 视频通话')
        }
        GridItem() {
          this.ServiceCard('医院挂号', '#2563EB', '🏥', ServiceType.MEDICAL_BOOKING,
            '预约挂号 · 问诊导航')
        }
        GridItem() {
          this.ServiceCard('医保社保', '#F97316', '📋', ServiceType.HEALTH_INSURANCE,
            '医保查询 · 社保办理')
        }
        GridItem() {
          this.ServiceCard('打车导航', '#7C3AED', '🚗', ServiceType.TRANSPORT,
            '叫车出行 · 路线导航')
        }
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(16)
      .rowsGap(16)
      .padding({ left: 20, right: 20, top: 8, bottom: 8 })
      .width('100%')
      .layoutWeight(1)

      Column({ space: 10 }) {
        Row({ space: 6 }) {
          Text('🔒').fontSize(16)
          Text('志愿者实名认证 · 服务全程免费 · 隐私严格保密')
            .fontSize(14)
            .fontColor('#8899AA')
        }
        Text(`更新时间: ${this.currentTime}`)
          .fontSize(13)
          .fontColor('#AABBCC')
      }
      .margin({ top: 8, bottom: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder
  ServiceCard(name: string, color: ResourceColor, icon: string, type: ServiceType, desc: string) {
    Column({ space: 12 }) {
      Text(icon)
        .fontSize(48)
      Column({ space: 6 }) {
        Text(name)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text(desc)
          .fontSize(13)
          .fontColor('rgba(255,255,255,0.85)')
          .textAlign(TextAlign.Center)
          .maxLines(1)
      }
    }
    .width('100%')
    .height(180)
    .backgroundColor(color)
    .borderRadius(24)
    .justifyContent(FlexAlign.Center)
    .shadow({ radius: 16, color: color, offsetY: 6 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/VoicePage', params: { serviceType: type } })
    })
  }
}
