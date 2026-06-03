import { Volunteer, ServiceType, MatchResult, TimeSlot } from '../models/ServiceModels'

/**
 * 智能匹配引擎
 * 基于加权多维度评分算法，为老年人匹配最合适的志愿者
 */
export class MatchingEngine {
  private static instance: MatchingEngine
  // 评分权重配置
  private readonly weights = {
    skillMatch: 0.40,       // 技能匹配度
    availability: 0.25,     // 时间可用性
    rating: 0.20,           // 志愿者评分
    serviceExperience: 0.15 // 服务经验
  }

  static getInstance(): MatchingEngine {
    if (!MatchingEngine.instance) {
      MatchingEngine.instance = new MatchingEngine()
    }
    return MatchingEngine.instance
  }

  /**
   * 核心匹配算法
   * @param serviceType 需求服务类型
   * @param volunteers  候选志愿者池
   * @param preferredDay 偏好的服务日（可选，0=周日...6=周六）
   * @returns 按评分降序排列的匹配结果
   */
  match(serviceType: ServiceType, volunteers: Volunteer[], preferredDay?: number): MatchResult[] {
    const results: MatchResult[] = []

    for (const v of volunteers) {
      const { score, details } = this.calculateScore(serviceType, v, preferredDay)
      results.push({ volunteer: v, score, matchDetails: details })
    }

    // 按评分降序排列，过滤零分结果
    return results
      .filter(r => r.score > 0)
      .sort((a, b) => b.score - a.score)
  }

  /**
   * 计算单个志愿者的综合评分
   */
  private calculateScore(serviceType: ServiceType, v: Volunteer, preferredDay?: number): { score: number; details: string[] } {
    const details: string[] = []

    // 技能匹配分
    const skillScore = this.calcSkillMatch(serviceType, v)
    details.push(`技能匹配: ${(skillScore * 100).toFixed(0)}%`)

    // 时间可用性分
    const availScore = this.calcAvailability(v, preferredDay)
    details.push(`时间可用: ${(availScore * 100).toFixed(0)}%`)

    // 评分归一化（假设满分5.0）
    const ratingScore = Math.min(v.rating / 5.0, 1.0)
    details.push(`用户评分: ${v.rating.toFixed(1)}/5.0`)

    // 服务经验分（10次以上满分）
    const expScore = Math.min(v.serviceCount / 10, 1.0)
    details.push(`服务次数: ${v.serviceCount}次`)

    const total = skillScore * this.weights.skillMatch +
      availScore * this.weights.availability +
      ratingScore * this.weights.rating +
      expScore * this.weights.serviceExperience

    return { score: Math.round(total * 100) / 100, details }
  }

  /**
   * 技能匹配度计算
   */
  private calcSkillMatch(serviceType: ServiceType, v: Volunteer): number {
    const skillMap: Record<ServiceType, string[]> = {
      [ServiceType.WECHAT]: ['社交软件', '智能手机', '视频通话'],
      [ServiceType.MEDICAL_BOOKING]: ['医疗系统', '挂号流程', '医院导航'],
      [ServiceType.HEALTH_INSURANCE]: ['社保知识', '医保政策', '政务APP'],
      [ServiceType.TRANSPORT]: ['打车软件', '地图导航', '公交查询']
    }

    const required = skillMap[serviceType] || []
    if (required.length === 0) return 0.5

    const matched = required.filter(s => v.skills.some(vs => vs.includes(s) || s.includes(vs)))
    return matched.length / required.length
  }

  /**
   * 时间可用性计算
   */
  private calcAvailability(v: Volunteer, preferredDay?: number): number {
    if (!v.availableTimes || v.availableTimes.length === 0) return 0.3

    if (preferredDay !== undefined) {
      const todayMatch = v.availableTimes.filter(t => t.dayOfWeek === preferredDay)
      if (todayMatch.length > 0) return 1.0
      // 相邻天也算部分可用
      const adjacentMatch = v.availableTimes.filter(t =>
        Math.abs(t.dayOfWeek - preferredDay) <= 1
      )
      return adjacentMatch.length > 0 ? 0.6 : 0.2
    }

    return Math.min(v.availableTimes.length / 5, 1.0)
  }
}
