import router from '@ohos.router'
import { promptAction } from '@kit.ArkUI'
import { http } from '@kit.NetworkKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { MatchingEngine } from '../services/MatchingEngine'
import { AppointmentManager } from '../services/AppointmentManager'
import { Volunteer, ServiceType, MatchResult, Appointment, AppointmentStatus } from '../models/ServiceModels'
import { DateUtils } from '../utils/DateUtils'
import common from '@ohos.app.ability.common'

class MatchDataSource implements IDataSource {
  private dataArray: MatchResult[] = []
  private listeners: DataChangeListener[] = []

  totalCount(): number {
    return this.dataArray.length
  }

  getData(index: number): MatchResult {
    return this.dataArray[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  refresh(data: MatchResult[]): void {
    this.dataArray = data
    this.listeners.forEach(listener => listener.onDataReloaded())
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
    const volunteerPool: Volunteer[] = [
      {
        id: 'EDU22-LI', name: '李同学', major: '师范专业',
        skills: ['智能手机', '社交软件', '视频通话', '耐心教学'],
        availableTimes: [
          { dayOfWeek: 1, startHour: 14, endHour: 17 },
          { dayOfWeek: 3, startHour: 14, endHour: 17 },
          { dayOfWeek: 5, startHour: 14, endHour: 17 }
        ],
        rating: 4.8, serviceCount: 12, avatar: ''
      },
      {
        id: 'CS22-WANG', name: '王同学', major: '计算机专业',
        skills: ['智能手机', '打车软件', '地图导航', '政务APP', '系统操作'],
        availableTimes: [
          { dayOfWeek: 2, startHour: 9, endHour: 17 },
          { dayOfWeek: 4, startHour: 9, endHour: 17 }
        ],
        rating: 4.9, serviceCount: 18, avatar: ''
      },
      {
        id: 'MED23-ZHANG', name: '张同学', major: '医学专业',
        skills: ['医疗系统', '挂号流程', '医院导航', '健康咨询'],
        availableTimes: [
          { dayOfWeek: 1, startHour: 9, endHour: 12 },
          { dayOfWeek: 3, startHour: 9, endHour: 12 },
          { dayOfWeek: 5, startHour: 9, endHour: 12 }
        ],
        rating: 4.7, serviceCount: 8, avatar: ''
      },
      {
        id: 'SSA24-LIU', name: '刘同学', major: '社会工作专业',
        skills: ['社保知识', '医保政策', '养老金咨询', '政务APP'],
        availableTimes: [
          { dayOfWeek: 1, startHour: 14, endHour: 18 },
          { dayOfWeek: 2, startHour: 14, endHour: 18 },
          { dayOfWeek: 4, startHour: 14, endHour: 18 }
        ],
        rating: 4.6, serviceCount: 15, avatar: ''
      }
    ]

    const today = DateUtils.getTodayDayOfWeek()
    setTimeout(() => {
      this.matchResults = this.matchingEngine.match(this.serviceType, volunteerPool, today)
      this.matchDataSource.refresh(this.matchResults)
      this.loading = false
    }, 1000)
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
        Blank()
      }
      .width('100%')
      .padding({ left: 24, top: 20, bottom: 8 })

      if (this.loading) {
        Column({ space: 24 }) {
          LoadingProgress()
            .width(72)
            .height(72)
            .color('#0066CC')
          Column({ space: 10 }) {
            Text('AI正在为您匹配合适的志愿者…')
              .fontSize(22)
              .fontColor('#556677')
              .fontWeight(FontWeight.Medium)
            Text(`"${this.voiceText}"`)
              .fontSize(16)
              .fontColor('#8899AA')
              .maxLines(2)
              .textAlign(TextAlign.Center)
          }
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height('60%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 8 }) {
            Column({ space: 4 }) {
              Text('匹配成功！')
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor('#0066CC')
              Text(`为您找到 ${this.matchResults.length} 位合适的志愿者`)
                .fontSize(16)
                .fontColor('#8899AA')
            }
            .alignItems(HorizontalAlign.Center)
            .width('100%')
            .margin({ top: 16, bottom: 12 })

            Column({ space: 16 }) {
              LazyForEach(this.matchDataSource, (result: MatchResult, index: number) => {
                this.VolunteerCard(result, index)
              }, (item: MatchResult) => item.volunteer.id + item.score.toString())
            }
            .width('100%')

            Text('志愿者均已实名认证 · 服务全程免费 · 信息安全保密')
              .fontSize(14)
              .fontColor('#AABBCC')
              .textAlign(TextAlign.Center)
              .width('100%')
              .margin({ top: 8, bottom: 32 })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder
  VolunteerCard(result: MatchResult, index: number) {
    Column({ space: 12 }) {
      Row() {
        Text(`${(result.score * 100).toFixed(0)}% 匹配`)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .backgroundColor(index === 0 ? '#F97316' : '#0066CC')
          .borderRadius(14)
        Blank()
        if (index === 0) {
          Row({ space: 4 }) {
            Text('⭐').fontSize(16)
            Text('最佳匹配').fontSize(16).fontColor('#F97316').fontWeight(FontWeight.Bold)
          }
        }
      }

      Row({ space: 12 }) {
        Circle()
          .width(56)
          .height(56)
          .fill(index === 0 ? '#EBF4FF' : '#F0F0F0')

        Column({ space: 3 }) {
          Text(result.volunteer.name)
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A2E')
          Text(result.volunteer.major)
            .fontSize(15)
            .fontColor('#8899AA')
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Column({ space: 4 }) {
          Text(`★ ${result.volunteer.rating.toFixed(1)}`)
            .fontSize(16)
            .fontColor('#FF9500')
            .fontWeight(FontWeight.Medium)
          Text(`已服务${result.volunteer.serviceCount}次`)
            .fontSize(13)
            .fontColor('#8899AA')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      Divider().color('#F0F2F5')

      Column({ space: 4 }) {
        ForEach(result.matchDetails, (detail: string) => {
          Text(`· ${detail}`)
            .fontSize(14)
            .fontColor('#667788')
        })
      }

      Row({ space: 8 }) {
        ForEach(result.volunteer.skills.slice(0, 3), (skill: string) => {
          Text(skill)
            .fontSize(13)
            .fontColor('#0066CC')
            .padding({ left: 12, right: 12, top: 5, bottom: 5 })
            .backgroundColor('#EBF4FF')
            .borderRadius(10)
        })
      }

      Button('立即预约')
        .width('100%')
        .height(52)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(index === 0 ? '#0066CC' : '#667788')
        .borderRadius(26)
        .shadow({ radius: 8, color: index === 0 ? '#0066CC33' : '#66778822', offsetY: 4 })
        .margin({ top: 4 })
        .onClick(() => this.createAppointment(result))
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({ radius: 10, color: '#0000000C', offsetY: 3 })
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
      this.syncToBackend(appointment)
      promptAction.showDialog({
        title: '预约成功！',
        message: `已预约${result.volunteer.name}为您服务\n预约单号: ${appointment.id}`,
        buttons: [{ text: '好的', color: '#0066CC' }]
      })
    } else {
      promptAction.showToast({ message: '预约失败，请重试', duration: 2000 })
    }
  }

  syncToBackend(appointment: Appointment): void {
    let httpRequest = http.createHttp()
    httpRequest.request('http://192.168.10.1:8000/api/v1/service/request', {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/json' },
      extraData: {
        request_id: appointment.id,
        service_type: appointment.serviceType,
        matched_volunteer: appointment.volunteerId,
        voice_text: appointment.remark,
        timestamp: new Date().toISOString()
      }
    }, (err: BusinessError) => {
      if (!err) {
        console.info('[ResultPage] Backend sync succeeded')
      } else {
        console.error(`[ResultPage] Backend sync failed: ${err.message}`)
      }
    })
  }
}
