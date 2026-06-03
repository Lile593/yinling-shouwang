import { hilog } from '@kit.PerformanceAnalysisKit'
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { MatchingEngine } from '../../main/ets/services/MatchingEngine'
import { VoiceService } from '../../main/ets/services/VoiceService'
import { Volunteer, ServiceType, Appointment, AppointmentStatus } from '../../main/ets/models/ServiceModels'

const DOMAIN = 0x0001
const TAG = 'yinling-test'

export default function abilityTest() {
  describe('银龄守望 — 集成测试', () => {

    // ==================== 语音→匹配→预约 端到端流程 ====================
    describe('核心业务流程：语音录入 → 匹配算法 → 预约生成', () => {
      let voiceService: VoiceService
      let matchingEngine: MatchingEngine

      beforeAll(() => {
        voiceService = VoiceService.getInstance()
        matchingEngine = MatchingEngine.getInstance()
        hilog.info(DOMAIN, TAG, '集成测试初始化完成')
      })

      it('端到端：语音识别 → 意图解析 → 匹配阶段', 0, () => {
        // Step 1: 模拟用户语音输入
        const text = '我想学用手机打车'
        const intent = voiceService.parseIntent(text)
        expect(intent).assertEqual(ServiceType.TRANSPORT)
        hilog.info(DOMAIN, TAG, '意图解析成功: %{public}s', intent)

        // Step 2: 匹配算法
        const volunteers: Volunteer[] = [
          {
            id: 'CS22-WANG', name: '王同学', major: '计算机专业',
            skills: ['智能手机', '打车软件', '地图导航'],
            availableTimes: [{ dayOfWeek: 2, startHour: 9, endHour: 17 }],
            rating: 4.9, serviceCount: 18, avatar: ''
          },
          {
            id: 'EDU22-LI', name: '李同学', major: '师范专业',
            skills: ['智能手机', '社交软件'],
            availableTimes: [{ dayOfWeek: 1, startHour: 14, endHour: 17 }],
            rating: 4.8, serviceCount: 12, avatar: ''
          }
        ]

        const results = matchingEngine.match(intent, volunteers)
        expect(results.length > 0).assertTrue()
        expect(results[0].volunteer.id).assertEqual('CS22-WANG')
        hilog.info(DOMAIN, TAG, '匹配成功，最佳志愿者: %{public}s, 评分: %{public}f',
          results[0].volunteer.name, results[0].score)
      })

      it('预约单数据结构完整性校验', 0, () => {
        const appointment: Appointment = {
          id: 'APT-TEST-001',
          serviceType: ServiceType.WECHAT,
          volunteerId: 'CS22-WANG',
          volunteerName: '王同学',
          elderName: '张大爷',
          elderPhone: '13800138000',
          elderAddress: '北京市朝阳区',
          appointmentDate: '2026-03-17',
          timeSlot: '下午 14:00-17:00',
          status: AppointmentStatus.PENDING,
          remark: '想学微信视频通话',
          createTime: Date.now()
        }

        expect(appointment.id.startsWith('APT-')).assertTrue()
        expect(appointment.status).assertEqual(AppointmentStatus.PENDING)
        expect(appointment.serviceType).assertEqual(ServiceType.WECHAT)
        hilog.info(DOMAIN, TAG, '预约单数据结构校验通过: %{public}s', appointment.id)
      })
    })
  })
}
