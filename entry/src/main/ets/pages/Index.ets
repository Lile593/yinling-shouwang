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
      // 顶部问候区
      Row() {
        Column({ space: 4 }) {
          Text(`${this.greeting}，欢迎使用`)
            .fontSize(16)
            .fontColor('#8899AA')
          Text('银龄守望')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A2E')
          Text('老年数字生活互助平台')
            .fontSize(14)
            .fontColor('#8899AA')
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Image($r('app.media.startIcon'))
          .width(64)
          .height(64)
          .borderRadius(32)
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 20, bottom: 12 })

      Divider().color('#E8ECF0').margin({ left: 24, right: 24 })

      Row() {
        Text('需要什么帮助？')
          .fontSize(20).fontWeight(FontWeight.Medium).fontColor('#333')
        Blank()
        Text('点击卡片语音录入')
          .fontSize(13).fontColor('#99AABB')
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 20, bottom: 12 })

      // 四大服务卡片（2x2 网格）
      Grid() {
        GridItem() { this.ServiceCard('微信使用', '#07C160', '📱', ServiceType.WECHAT) }
        GridItem() { this.ServiceCard('医院挂号', '#0066CC', '🏥', ServiceType.MEDICAL_BOOKING) }
        GridItem() { this.ServiceCard('医保社保', '#FF6633', '📋', ServiceType.HEALTH_INSURANCE) }
        GridItem() { this.ServiceCard('打车导航', '#9933FF', '🚗', ServiceType.TRANSPORT) }
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(16).rowsGap(16)
      .padding({ left: 20, right: 20, top: 8, bottom: 8 })
      .width('100%')

      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Text('🔒').fontSize(14)
          Text('服务全程免费 · 志愿者实名认证 · 隐私严格保密').fontSize(12).fontColor('#8899AA')
        }
        Row({ space: 8 }) {
          Text('⏰').fontSize(14)
          Text(`更新于 ${this.currentTime}`).fontSize(12).fontColor('#8899AA')
        }
      }
      .margin({ top: 16, bottom: 30 })
    }
    .width('100%').height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder
  ServiceCard(name: string, color: ResourceColor, icon: string, type: ServiceType) {
    Column({ space: 10 }) {
      Text(icon).fontSize(36)
      Text(name).fontSize(20).fontWeight(FontWeight.Medium).fontColor('#fff')
      Text('点击语音说出需求').fontSize(12).fontColor('rgba(255,255,255,0.8)')
    }
    .width('100%').height(150)
    .backgroundColor(color).borderRadius(20)
    .justifyContent(FlexAlign.Center)
    .shadow({ radius: 12, color: color, offsetY: 4 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/VoicePage', params: { serviceType: type } })
    })
  }
}
