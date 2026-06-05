import { Volunteer, ServiceType, MatchResult } from '../models/ServiceModels'

interface MatchWeights {
  skillMatch: number
  availability: number
  rating: number
  experience: number
  certification: number
}

interface ScoreResult {
  score: number
  details: string[]
}

export class MatchingEngine {
  private static instance: MatchingEngine

  private readonly weights: MatchWeights = {
    skillMatch: 0.30,
    availability: 0.25,
    rating: 0.20,
    experience: 0.15,
    certification: 0.10
  }

  static getInstance(): MatchingEngine {
    if (!MatchingEngine.instance) {
      MatchingEngine.instance = new MatchingEngine()
    }
    return MatchingEngine.instance
  }

  match(serviceType: ServiceType, volunteers: Volunteer[], preferredDay?: number): MatchResult[] {
    const results: MatchResult[] = []

    for (let i = 0; i < volunteers.length; i++) {
      const v = volunteers[i]
      const calcResult = this.calculateScore(serviceType, v, preferredDay)
      const score = calcResult.score
      const details = calcResult.details
      results.push({ volunteer: v, score, matchDetails: details })
    }

    return results
      .filter(r => r.score > 0.15)
      .sort((a, b) => b.score - a.score)
  }

  private calculateScore(serviceType: ServiceType, v: Volunteer, preferredDay?: number): ScoreResult {
    const details: string[] = []

    const skillScore = this.calcSkillMatch(serviceType, v)
    details.push(`技能匹配度: ${(skillScore * 100).toFixed(0)}%`)

    const availScore = this.calcAvailability(v, preferredDay)
    details.push(`空闲时间匹配: ${(availScore * 100).toFixed(0)}%`)

    const ratingScore = Math.min(v.rating / 5.0, 1.0)
    details.push(`用户评分: ${v.rating.toFixed(1)}/5.0`)

    const expScore = Math.min(v.serviceCount / 20, 1.0)
    details.push(`服务经验: ${v.serviceCount}次`)

    const certScore = Math.min(v.certifications.length / 3, 1.0)
    if (v.certifications.length > 0) {
      details.push(`持有${v.certifications.length}项相关资质`)
    }

    const total = skillScore * this.weights.skillMatch +
      availScore * this.weights.availability +
      ratingScore * this.weights.rating +
      expScore * this.weights.experience +
      certScore * this.weights.certification

    const result: ScoreResult = { score: Math.round(total * 10000) / 10000, details }
    return result
  }

  private calcSkillMatch(serviceType: ServiceType, v: Volunteer): number {
    const skillMap: Record<ServiceType, string[]> = {
      [ServiceType.WECHAT]: ['微信', '聊天', '视频通话', '朋友圈', '社交', '手机', '拍照', '相册'],
      [ServiceType.MEDICAL_BOOKING]: ['挂号', '医院', '就诊', '科室', '检查', '预约', '门诊', '看病'],
      [ServiceType.HEALTH_INSURANCE]: ['医保', '社保', '报销', '养老', '退休', '政策', '保险', '备案'],
      [ServiceType.TRANSPORT]: ['打车', '导航', '公交', '地铁', '出行', '地图', '交通', '路线']
    }

    const required = skillMap[serviceType] || []
    if (required.length === 0) return 0.3

    let matchCount = 0
    for (let i = 0; i < required.length; i++) {
      const keyword = required[i]
      for (let j = 0; j < v.skills.length; j++) {
        if (v.skills[j].includes(keyword) || keyword.includes(v.skills[j])) {
          matchCount++
          break
        }
      }
    }

    let score = matchCount / required.length

    const bonusThreshold = required.length * 0.6
    if (matchCount >= bonusThreshold) {
      score = score * 1.15
    }

    return Math.min(score, 1.0)
  }

  private calcAvailability(v: Volunteer, preferredDay?: number): number {
    if (!v.availableTimes || v.availableTimes.length === 0) return 0.1

    if (preferredDay !== undefined) {
      let todayMatches = 0
      let adjacentMatches = 0

      for (let i = 0; i < v.availableTimes.length; i++) {
        const t = v.availableTimes[i]
        const diff = Math.abs(t.dayOfWeek - preferredDay)
        if (diff === 0) {
          todayMatches++
        } else if (diff <= 1) {
          adjacentMatches++
        }
      }

      if (todayMatches > 0) {
        let score = 1.0
        if (todayMatches >= 2) score = 1.0
        return score
      }

      if (adjacentMatches > 0) return 0.55
      return 0.15
    }

    return Math.min(v.availableTimes.length / 6, 1.0)
  }
}
