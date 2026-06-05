import router from '@ohos.router'
import { promptAction } from '@kit.ArkUI'
import common from '@ohos.app.ability.common'
import { AppointmentManager } from '../services/AppointmentManager'
import { Evaluation, ServiceType, ServiceTypeLabel } from '../models/ServiceModels'
import { Colors, Sizes } from '../common/DesignTokens'

@Entry
@Component
struct EvaluationPage {
  @State rating: number = 0
  @State comment: string = ''
  @State volunteerId: string = ''
  @State volunteerName: string = ''
  @State serviceType: ServiceType = ServiceType.WECHAT
  @State appointmentId: string = ''
  @State submitting: boolean = false
  private manager: AppointmentManager = AppointmentManager.getInstance()

  async aboutToAppear(): Promise<void> {
    const params = router.getParams() as Record<string, Object>
    if (params) {
      this.appointmentId = (params['appointmentId'] as string) || ''
      this.volunteerId = (params['volunteerId'] as string) || ''
      this.volunteerName = (params['volunteerName'] as string) || ''
      this.serviceType = (params['serviceType'] as ServiceType) || ServiceType.WECHAT
    }
    const context = getContext(this) as common.UIAbilityContext
    await this.manager.init(context)
  }

  async submitEvaluation(): Promise<void> {
    if (this.rating === 0) {
      promptAction.showToast({ message: '请先打分', duration: 1500 })
      return
    }

    this.submitting = true
    const evaluation: Evaluation = {
      id: this.appointmentId,
      appointmentId: this.appointmentId,
      volunteerId: this.volunteerId,
      volunteerName: this.volunteerName,
      serviceType: this.serviceType,
      rating: this.rating,
      comment: this.comment || '用户未填写评价内容',
      createTime: Date.now()
    }

    const success = await this.manager.saveEvaluation(evaluation)
    this.submitting = false

    if (success) {
      promptAction.showDialog({
        title: '评价成功！',
        message: `感谢您对${this.volunteerName}的服务进行评价`,
        buttons: [{
          text: '返回首页',
          color: Colors.PRIMARY,
          primary: true
        }]
      }).then(() => {
        router.clear()
        router.pushUrl({ url: 'pages/Index' })
      })
    } else {
      promptAction.showToast({ message: '评价保存失败，请重试', duration: 2000 })
    }
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

      Scroll() {
        Column({ space: Sizes.SPACING_L }) {
          Column({ space: Sizes.SPACING_S }) {
            Text('服务评价')
              .fontSize(Sizes.TITLE_XL)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.TEXT_PRIMARY)
            Text(`为志愿者 ${this.volunteerName} 的服务打分`)
              .fontSize(Sizes.BODY_L)
              .fontColor(Colors.TEXT_HINT)
          }
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .margin({ top: Sizes.SPACING_XL })

          Column({ space: Sizes.SPACING_S }) {
            Text('服务类型')
              .fontSize(Sizes.BODY_M)
              .fontColor(Colors.TEXT_SECONDARY)
            Text(ServiceTypeLabel[this.serviceType] || this.serviceType)
              .fontSize(Sizes.TITLE_M)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.PRIMARY)
              .padding({ left: Sizes.SPACING_M, right: Sizes.SPACING_M, top: 6, bottom: 6 })
              .backgroundColor(Colors.PRIMARY_LIGHT)
              .borderRadius(12)
          }
          .alignItems(HorizontalAlign.Center)

          Column({ space: Sizes.SPACING_M }) {
            Text('请您打分')
              .fontSize(Sizes.BODY_L)
              .fontColor(Colors.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)

            Row({ space: Sizes.SPACING_S }) {
              ForEach([1, 2, 3, 4, 5], (star: number) => {
                Text(star <= this.rating ? '★' : '☆')
                  .fontSize(48)
                  .fontColor(star <= this.rating ? '#FF9500' : '#DDDDDD')
                  .onClick(() => { this.rating = star })
              })
            }

            Text(this.rating > 0 ? this.getRatingLabel(this.rating) : '点击星星评价')
              .fontSize(Sizes.BODY_L)
              .fontColor(this.rating > 0 ? '#FF9500' : Colors.TEXT_DISABLED)
              .fontWeight(FontWeight.Medium)
          }
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .padding(Sizes.SPACING_L)
          .backgroundColor(Colors.BG_PRIMARY)
          .borderRadius(Sizes.RADIUS_CARD)
          .shadow({ radius: 6, color: Colors.CARD_SHADOW, offsetY: 2 })
          .margin({ top: Sizes.SPACING_M })

          Column({ space: Sizes.SPACING_S }) {
            Text('评价留言')
              .fontSize(Sizes.BODY_L)
              .fontColor(Colors.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)

            TextArea({
              text: this.comment,
              placeholder: '请输入您的评价，分享服务感受...'
            })
              .height(140)
              .fontSize(Sizes.BODY_M)
              .backgroundColor(Colors.BG_PRIMARY)
              .borderRadius(12)
              .border({ width: 1, color: Colors.DIVIDER })
              .padding(Sizes.SPACING_M)
              .onChange((value: string) => { this.comment = value })
          }
          .width('100%')

          Button(this.submitting ? '提交中...' : '提交评价')
            .width('100%')
            .height(56)
            .fontSize(Sizes.BODY_L)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.TEXT_WHITE)
            .backgroundColor(this.rating > 0 && !this.submitting ? Colors.PRIMARY : Colors.TEXT_DISABLED)
            .borderRadius(Sizes.RADIUS_BTN)
            .shadow({ radius: 10, color: Colors.PRIMARY + '44', offsetY: 4 })
            .enabled(this.rating > 0 && !this.submitting)
            .margin({ top: Sizes.SPACING_M })
            .onClick(() => this.submitEvaluation())
        }
        .width('100%')
        .padding({ left: Sizes.SPACING_L, right: Sizes.SPACING_L, bottom: Sizes.SPACING_XL })
      }
      .layoutWeight(1)
    }
    .width('100%').height('100%')
    .backgroundColor(Colors.BG_SECONDARY)
  }

  private getRatingLabel(rating: number): string {
    const labels: Record<number, string> = {
      1: '需要改进',
      2: '还可以',
      3: '基本满意',
      4: '很满意',
      5: '非常满意！'
    }
    return labels[rating] || ''
  }
}
