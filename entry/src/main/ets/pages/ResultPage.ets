import router from '@ohos.router'
import { promptAction } from '@kit.ArkUI'
import common from '@ohos.app.ability.common'
import { MatchingEngine } from '../services/MatchingEngine'
import { AppointmentManager } from '../services/AppointmentManager'
import { ApiService } from '../services/ApiService'
import { getVolunteerPool } from '../data/VolunteerData'
import { Appointment, AppointmentStatus, ServiceType, ServiceTypeLabel, MatchResult, Volunteer } from '../models/ServiceModels'
import { DateUtils } from '../utils/DateUtils'
import { Colors, Sizes } from '../common/DesignTokens'

class MatchDataSource implements IDataSource {
  private dataArray: MatchResult[] = []
  private listeners: DataChangeListener[] = []

  totalCount(): number { return this.dataArray.length }
  getData(index: number): MatchResult { return this.dataArray[index] }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) this.listeners.push(listener)
  }
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) this.listeners.splice(pos, 1)
  }
  refresh(data: MatchResult[]): void {
    this.dataArray = data
    this.listeners.forEach(l => l.onDataReloaded())
  }
}

@Entry
@Component
struct ResultPage {
  @State matchResults: MatchResult[] = []
  @State loading: boolean = true
  @State serviceType: ServiceType = ServiceType.WECHAT
  @State voiceText: string = ''
  private matchingEngine: MatchingEngine = MatchingEngine.getInstance()
  private appointmentManager: AppointmentManager = AppointmentManager.getInstance()
  private apiService: ApiService = ApiService.getInstance()
  private matchDataSource: MatchDataSource = new MatchDataSource()

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    if (params) {
      this.serviceType = (params['serviceType'] as ServiceType) || ServiceType.WECHAT
      this.voiceText = (params['voiceText'] as string) || ''
    }
    const context = getContext(this) as common.UIAbilityContext
    this.appointmentManager.init(context)
    this.performMatching()
  }

  performMatching(): void {
    const volunteerPool = getVolunteerPool()
    const today = DateUtils.getTodayDayOfWeek()

    setTimeout(() => {
      this.matchResults = this.matchingEngine.match(this.serviceType, volunteerPool, today)
      this.matchDataSource.refresh(this.matchResults)
      this.loading = false
    }, 800)
  }

  build() {
    Column({ space: 0 }) {
      Row() {
        Text('< 返回')
          .fontSize(Sizes.BODY_L)
          .fontColor(Colors.PRIMARY)
          .onClick(() => router.back())
        Blank()
      }
      .width('100%')
      .padding({ left: Sizes.SPACING_L, top: 20, bottom: 8 })

      if (this.loading) {
        Column({ space: Sizes.SPACING_L }) {
          LoadingProgress().width(72).height(72).color(Colors.PRIMARY)
          Column({ space: Sizes.SPACING_S }) {
            Text('AI正在分析您的需求，匹配合适的志愿者…')
              .fontSize(20)
              .fontColor(Colors.TEXT_SECONDARY)
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
            Text(`"${this.voiceText}"`)
              .fontSize(Sizes.BODY_M)
              .fontColor(Colors.TEXT_HINT)
              .maxLines(2)
              .textAlign(TextAlign.Center)
          }
          .alignItems(HorizontalAlign.Center)
          .width('85%')
        }
        .width('100%')
        .height('60%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Sizes.SPACING_S }) {
            Column({ space: Sizes.SPACING_XS }) {
              Text('匹配完成')
                .fontSize(Sizes.TITLE_XL)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.PRIMARY)
              Text(`为您找到 ${this.matchResults.length} 位合适的志愿者`)
                .fontSize(Sizes.BODY_M)
                .fontColor(Colors.TEXT_HINT)
            }
            .alignItems(HorizontalAlign.Center)
            .width('100%')
            .margin({ top: Sizes.SPACING_M, bottom: Sizes.SPACING_S })

            Column({ space: Sizes.SPACING_M }) {
              LazyForEach(this.matchDataSource, (result: MatchResult, index: number) => {
                this.VolunteerCard(result, index)
              }, (item: MatchResult) => item.volunteer.id + item.score.toString())
            }
            .width('100%')

            Text('志愿者均已实名认证 · 服务全程免费 · 信息安全保密')
              .fontSize(Sizes.BODY_S)
              .fontColor(Colors.TEXT_DISABLED)
              .textAlign(TextAlign.Center)
              .width('100%')
              .margin({ top: Sizes.SPACING_S, bottom: 32 })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BG_SECONDARY)
  }

  @Builder
  VolunteerCard(result: MatchResult, index: number) {
    Column({ space: Sizes.SPACING_M }) {
      Row() {
        Text(`${(result.score * 100).toFixed(1)}% 匹配`)
          .fontSize(Sizes.BODY_M)
          .fontColor(Colors.TEXT_WHITE)
          .fontWeight(FontWeight.Bold)
          .padding({ left: Sizes.SPACING_M, right: Sizes.SPACING_M, top: 6, bottom: 6 })
          .backgroundColor(index === 0 ? Colors.WARNING : Colors.PRIMARY)
          .borderRadius(14)
        Blank()
        if (index === 0) {
          Row({ space: 4 }) {
            Text('🌟').fontSize(Sizes.BODY_L)
            Text('最佳匹配').fontSize(Sizes.BODY_L).fontColor(Colors.WARNING).fontWeight(FontWeight.Bold)
          }
        }
      }

      Row({ space: Sizes.SPACING_M }) {
        Circle()
          .width(56)
          .height(56)
          .fill(index === 0 ? Colors.PRIMARY_LIGHT : Colors.DIVIDER)

        Column({ space: 3 }) {
          Row({ space: 6 }) {
            Text(result.volunteer.name)
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.TEXT_PRIMARY)
            Text(result.volunteer.gender + ' · ' + result.volunteer.age + '岁')
              .fontSize(Sizes.CAPTION)
              .fontColor(Colors.TEXT_HINT)
          }
          Text(`${result.volunteer.university} · ${result.volunteer.major}`)
            .fontSize(Sizes.BODY_S)
            .fontColor(Colors.TEXT_HINT)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Column({ space: Sizes.SPACING_XS }) {
          Text(`★ ${result.volunteer.rating.toFixed(1)}`)
            .fontSize(Sizes.BODY_M)
            .fontColor('#FF9500')
            .fontWeight(FontWeight.Medium)
          Text(`服务${result.volunteer.serviceCount}次`)
            .fontSize(Sizes.CAPTION)
            .fontColor(Colors.TEXT_HINT)
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      Text(result.volunteer.description)
        .fontSize(Sizes.BODY_S)
        .fontColor(Colors.TEXT_SECONDARY)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .padding({ left: 4, right: 4 })

      Divider().color(Colors.DIVIDER)

      Column({ space: Sizes.SPACING_XS }) {
        ForEach(result.matchDetails, (detail: string) => {
          Row({ space: 6 }) {
            Text('✓').fontSize(Sizes.BODY_S).fontColor(Colors.SUCCESS)
            Text(detail)
              .fontSize(Sizes.BODY_S)
              .fontColor(Colors.TEXT_SECONDARY)
          }
        })
      }

      Row({ space: Sizes.SPACING_S }) {
        ForEach(result.volunteer.skills.slice(0, 4), (skill: string) => {
          Text(skill)
            .fontSize(Sizes.CAPTION)
            .fontColor(Colors.PRIMARY)
            .padding({ left: 12, right: 12, top: 5, bottom: 5 })
            .backgroundColor(Colors.PRIMARY_LIGHT)
            .borderRadius(10)
        })
      }
      .width('100%')

      if (result.volunteer.certifications.length > 0) {
        Row({ space: Sizes.SPACING_XS }) {
          Text('📜').fontSize(Sizes.CAPTION)
          Text(result.volunteer.certifications.slice(0, 2).join(' · '))
            .fontSize(Sizes.CAPTION)
            .fontColor(Colors.TEXT_HINT)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }

      Button('立即预约')
        .width('100%')
        .height(52)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.TEXT_WHITE)
        .backgroundColor(index === 0 ? Colors.PRIMARY : Colors.TEXT_SECONDARY)
        .borderRadius(Sizes.RADIUS_BTN)
        .shadow({ radius: 8, color: index === 0 ? Colors.PRIMARY + '33' : Colors.TEXT_SECONDARY + '22', offsetY: 4 })
        .onClick(() => this.createAppointment(result))
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Colors.BG_PRIMARY)
    .borderRadius(Sizes.RADIUS_CARD)
    .shadow({ radius: 10, color: Colors.CARD_SHADOW, offsetY: 3 })
  }

  async createAppointment(result: MatchResult): Promise<void> {
    const appointment: Appointment = {
      id: this.appointmentManager.generateId(),
      serviceType: this.serviceType,
      volunteerId: result.volunteer.id,
      volunteerName: result.volunteer.name,
      elderName: '', elderPhone: '', elderAddress: '',
      appointmentDate: DateUtils.formatDate(Date.now() + 86400000),
      timeSlot: '下午 14:00-17:00',
      status: AppointmentStatus.PENDING,
      remark: this.voiceText,
      createTime: Date.now()
    }

    const success = await this.appointmentManager.create(appointment)
    if (success) {
      this.apiService.syncAppointment(appointment.id, appointment.volunteerId)
      promptAction.showDialog({
        title: '预约成功！',
        message: `已预约${result.volunteer.name}为您提供${ServiceTypeLabel[this.serviceType]}服务\n预约单号: ${appointment.id}\n预计服务时间: ${appointment.appointmentDate} ${appointment.timeSlot}`,
        buttons: [
          { text: '查看预约', color: Colors.PRIMARY, primary: true },
          { text: '返回首页', color: Colors.TEXT_HINT }
        ]
      }).then((res: Object) => {
        const idx = (res as Record<string, number>)['index']
        if (idx === 0) {
          router.pushUrl({ url: 'pages/AppointmentsPage' })
        } else {
          router.clear()
          router.pushUrl({ url: 'pages/Index' })
        }
      })
    } else {
      promptAction.showToast({ message: '预约失败，请重试', duration: 2000 })
    }
  }
}
