import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { MatchingEngine } from '../main/ets/services/MatchingEngine'
import { VoiceService } from '../main/ets/services/VoiceService'
import { DateUtils } from '../main/ets/utils/DateUtils'
import { Volunteer, ServiceType, MatchResult } from '../main/ets/models/ServiceModels'

export default function localUnitTest() {
  describe('银龄守望 - 核心模块单元测试', () => {

    // ==================== MatchingEngine 测试 ====================
    describe('MatchingEngine — 智能匹配算法', () => {
      let engine: MatchingEngine
      let volunteers: Volunteer[]

      beforeAll(() => {
        engine = MatchingEngine.getInstance()
        volunteers = [
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
            id: 'EDU22-LI', name: '李同学', major: '师范专业',
            skills: ['智能手机', '社交软件', '视频通话'],
            availableTimes: [
              { dayOfWeek: 1, startHour: 14, endHour: 17 },
              { dayOfWeek: 3, startHour: 14, endHour: 17 }
            ],
            rating: 4.8, serviceCount: 12, avatar: ''
          }
        ]
      })

      it('匹配结果应按评分降序排列', 0, () => {
        const results = engine.match(ServiceType.TRANSPORT, volunteers)
        expect(results.length).assertEqual(2)
        expect(results[0].score > results[1].score).assertTrue()
      })

      it('技能匹配度应影响排序', 0, () => {
        const results = engine.match(ServiceType.TRANSPORT, volunteers)
        // 王同学有打车/导航技能，李同学没有，所以王同学排名更高
        expect(results[0].volunteer.id).assertEqual('CS22-WANG')
      })

      it('指定偏好日当天有空应优先', 0, () => {
        // 周二(dayOfWeek=2)：王同学全天可用，李同学不可用
        const results = engine.match(ServiceType.WECHAT, volunteers, 2)
        expect(results[0].volunteer.id).assertEqual('CS22-WANG')
      })

      it('空志愿者列表应返回空结果', 0, () => {
        const results = engine.match(ServiceType.WECHAT, [])
        expect(results.length).assertEqual(0)
      })

      it('匹配分数应在 0-1 之间', 0, () => {
        const results = engine.match(ServiceType.WECHAT, volunteers)
        for (let r of results) {
          expect(r.score >= 0).assertTrue()
          expect(r.score <= 1).assertTrue()
        }
      })
    })

    // ==================== VoiceService 测试 ====================
    describe('VoiceService — 语音识别服务', () => {
      let voiceService: VoiceService

      beforeAll(() => {
        voiceService = VoiceService.getInstance()
      })

      it('意图解析：包含"微信"关键词应返回 WECHAT', 0, () => {
        const result = voiceService.parseIntent('我想学微信发朋友圈')
        expect(result).assertEqual(ServiceType.WECHAT)
      })

      it('意图解析：包含"挂号"关键词应返回 MEDICAL_BOOKING', 0, () => {
        const result = voiceService.parseIntent('帮我在手机上挂号')
        expect(result).assertEqual(ServiceType.MEDICAL_BOOKING)
      })

      it('意图解析：包含"医保"关键词应返回 HEALTH_INSURANCE', 0, () => {
        const result = voiceService.parseIntent('怎么查医保余额')
        expect(result).assertEqual(ServiceType.HEALTH_INSURANCE)
      })

      it('意图解析：包含"打车"关键词应返回 TRANSPORT', 0, () => {
        const result = voiceService.parseIntent('教我用手机打车')
        expect(result).assertEqual(ServiceType.TRANSPORT)
      })

      it('无匹配关键词应返回默认值 WECHAT', 0, () => {
        const result = voiceService.parseIntent('你好')
        expect(result).assertEqual(ServiceType.WECHAT)
      })
    })

    // ==================== DateUtils 测试 ====================
    describe('DateUtils — 日期工具', () => {
      it('formatDate 应输出 YYYY-MM-DD 格式', 0, () => {
        const ts = new Date(2026, 2, 16).getTime()
        const result = DateUtils.formatDate(ts)
        expect(result).assertEqual('2026-03-16')
      })

      it('getDayOfWeekName 周日应返回"周日"', 0, () => {
        expect(DateUtils.getDayOfWeekName(0)).assertEqual('周日')
      })

      it('getDayOfWeekName 周三应返回"周三"', 0, () => {
        expect(DateUtils.getDayOfWeekName(3)).assertEqual('周三')
      })

      it('getTodayDayOfWeek 应在 0-6 范围内', 0, () => {
        const today = DateUtils.getTodayDayOfWeek()
        expect(today >= 0 && today <= 6).assertTrue()
      })
    })
  })
}
