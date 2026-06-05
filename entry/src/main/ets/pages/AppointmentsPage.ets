import router from '@ohos.router'
import { promptAction } from '@kit.ArkUI'
import common from '@ohos.app.ability.common'
import { AppointmentManager } from '../services/AppointmentManager'
import { Appointment, AppointmentStatus, AppointmentStatusLabel, AppointmentStatusColor, ServiceTypeLabel } from '../models/ServiceModels'
import { DateUtils } from '../utils/DateUtils'
import { Colors, Sizes } from '../common/DesignTokens'

class AppointmentDataSource implements IDataSource {
  private dataArray: Appointment[] = []
  private listeners: DataChangeListener[] = []

  totalCount(): number { return this.dataArray.length }
  getData(index: number): Appointment { return this.dataArray[index] }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) this.listeners.push(listener)
  }
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) this.listeners.splice(pos, 1)
  }
  refresh(data: Appointment[]): void {
    this.dataArray = data
    this.listeners.forEach(l => l.onDataReloaded())
  }
}

@Entry
@Component
struct AppointmentsPage {
  @State appointments: Appointment[] = []
  @State filterStatus: string = 'all'
  @State loading: boolean = true
  private manager: AppointmentManager = AppointmentManager.getInstance()
  private dataSource: AppointmentDataSource = new AppointmentDataSource()
  private filterTabs: Array<{ label: string; value: string }> = [
    { label: '全部', value: 'all' },
    { label: '待确认', value: 'pending' },
    { label: '已确认', value: 'confirmed' },
    { label: '已完成', value: 'completed' }
  ]

  async aboutToAppear(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext
    await this.manager.init(context)
    await this.loadData()
  }

  async loadData(): Promise<void> {
    this.loading = true
    let data: Appointment[]
    if (this.filterStatus === 'all') {
      data = await this.manager.queryAll()
    } else {
      data = await this.manager.queryByStatus(this.filterStatus as AppointmentStatus)
    }
    this.appointments = data
    this.dataSource.refresh(data)
    this.loading = false
  }

  async onFilterChange(status: string): Promise<void> {
    this.filterStatus = status
    await this.loadData()
  }

  async handleCancel(id: string): Promise<void> {
    const success = await this.manager.updateStatus(id, AppointmentStatus.CANCELLED)
    if (success) {
      promptAction.showToast({ message: '已取消预约', duration: 1500 })
      await this.loadData()
    } else {
      promptAction.showToast({ message: '操作失败，请重试', duration: 1500 })
    }
  }

  async handleComplete(id: string, volunteerId: string, volunteerName: string, serviceType: string, appointmentId: string): Promise<void> {
    const success = await this.manager.updateStatus(id, AppointmentStatus.COMPLETED)
    if (success) {
      promptAction.showToast({ message: '服务已完成', duration: 1500 })
      router.pushUrl({
        url: 'pages/EvaluationPage',
        params: {
          appointmentId: appointmentId,
          volunteerId: volunteerId,
          volunteerName: volunteerName,
          serviceType: serviceType
        }
      })
    }
  }

  build() {
    Column({ space: 0 }) {
      Row() {
        Text('< 返回')
          .fontSize(Sizes.BODY_L)
          .fontColor(Colors.PRIMARY)
          .onClick(() => router.back())
        Blank()
        Text('我的预约')
          .fontSize(Sizes.TITLE_M)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_PRIMARY)
        Blank()
        Text('      ')
          .fontSize(Sizes.BODY_L)
          .fontColor('transparent')
      }
      .width('100%')
      .padding({ left: Sizes.SPACING_L, right: Sizes.SPACING_L, top: 20, bottom: 12 })
      .backgroundColor(Colors.BG_PRIMARY)

      Scroll({ scrollDirection: Axis.Horizontal }) {
        Row({ space: Sizes.SPACING_S }) {
          ForEach(this.filterTabs, (tab: { label: string; value: string }) => {
            Text(tab.label)
              .fontSize(Sizes.BODY_M)
              .fontWeight(this.filterStatus === tab.value ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.filterStatus === tab.value ? Colors.BG_PRIMARY : Colors.TEXT_SECONDARY)
              .padding({ left: 18, right: 18, top: 8, bottom: 8 })
              .backgroundColor(this.filterStatus === tab.value ? Colors.PRIMARY : Colors.DIVIDER)
              .borderRadius(Sizes.RADIUS_BTN)
              .onClick(() => this.onFilterChange(tab.value))
          })
        }
        .padding({ left: Sizes.SPACING_L, top: Sizes.SPACING_S, bottom: Sizes.SPACING_S })
      }
      .scrollBar(BarState.Off)
      .backgroundColor(Colors.BG_PRIMARY)

      if (this.loading) {
        Column({ space: Sizes.SPACING_M }) {
          LoadingProgress().width(60).height(60).color(Colors.PRIMARY)
          Text('加载中...').fontSize(Sizes.BODY_M).fontColor(Colors.TEXT_HINT)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.appointments.length === 0) {
        Column({ space: Sizes.SPACING_M }) {
          Text('📋').fontSize(64)
          Text('暂无预约记录').fontSize(Sizes.BODY_L).fontColor(Colors.TEXT_SECONDARY)
          Text('完成语音录入后即可预约志愿者').fontSize(Sizes.BODY_S).fontColor(Colors.TEXT_HINT)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Sizes.SPACING_M }) {
            LazyForEach(this.dataSource, (appointment: Appointment, index: number) => {
              this.AppointmentItem(appointment)
            }, (item: Appointment) => item.id)
          }
          .width('100%')
          .padding({ left: Sizes.SPACING_L, right: Sizes.SPACING_L, top: Sizes.SPACING_M, bottom: Sizes.SPACING_XL })
        }
        .layoutWeight(1)
      }
    }
    .width('100%').height('100%')
    .backgroundColor(Colors.BG_SECONDARY)
  }

  @Builder
  AppointmentItem(appointment: Appointment) {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 3 }) {
          Text(ServiceTypeLabel[appointment.serviceType] || appointment.serviceType)
            .fontSize(Sizes.BODY_L)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.TEXT_PRIMARY)
          Text(`预约时间: ${appointment.appointmentDate} ${appointment.timeSlot}`)
            .fontSize(Sizes.BODY_S)
            .fontColor(Colors.TEXT_HINT)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Text(AppointmentStatusLabel[appointment.status])
          .fontSize(Sizes.BODY_S)
          .fontColor(Colors.TEXT_WHITE)
          .fontWeight(FontWeight.Medium)
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .backgroundColor(AppointmentStatusColor[appointment.status])
          .borderRadius(10)
      }
      .width('100%')

      Divider().color(Colors.DIVIDER)

      Row() {
        Text(`志愿者: ${appointment.volunteerName}`)
          .fontSize(Sizes.BODY_M)
          .fontColor(Colors.TEXT_SECONDARY)
        Blank()
        Text(`单号: ${appointment.id}`)
          .fontSize(Sizes.CAPTION)
          .fontColor(Colors.TEXT_HINT)
      }
      .width('100%')

      Text(`备注: ${appointment.remark || '无'}`)
        .fontSize(Sizes.BODY_S)
        .fontColor(Colors.TEXT_HINT)
        .maxLines(1)

      Text(DateUtils.getRelativeTime(appointment.createTime))
        .fontSize(Sizes.CAPTION)
        .fontColor(Colors.TEXT_DISABLED)

      if (appointment.status === AppointmentStatus.PENDING) {
        Row({ space: Sizes.SPACING_S }) {
          Button('取消预约')
            .fontSize(Sizes.BODY_M)
            .height(40)
            .backgroundColor(Colors.DANGER_LIGHT)
            .fontColor(Colors.DANGER)
            .borderRadius(12)
            .layoutWeight(1)
            .onClick(() => this.handleCancel(appointment.id))
        }
        .width('100%')
        .margin({ top: 4 })
      }

      if (appointment.status === AppointmentStatus.CONFIRMED) {
        Button('完成服务并评价')
          .fontSize(Sizes.BODY_M)
          .height(44)
          .width('100%')
          .backgroundColor(Colors.SUCCESS)
          .fontColor(Colors.TEXT_WHITE)
          .borderRadius(Sizes.RADIUS_BTN)
          .onClick(() => this.handleComplete(appointment.id, appointment.volunteerId, appointment.volunteerName, appointment.serviceType, appointment.id))
      }
    }
    .width('100%')
    .padding(Sizes.SPACING_L)
    .backgroundColor(Colors.BG_PRIMARY)
    .borderRadius(Sizes.RADIUS_CARD)
    .shadow({ radius: 6, color: Colors.CARD_SHADOW, offsetY: 2 })
  }
}
