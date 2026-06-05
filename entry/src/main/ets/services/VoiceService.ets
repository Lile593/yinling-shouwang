import { VoiceRecognitionResult, ServiceType } from '../models/ServiceModels'

export class VoiceService {
  private static instance: VoiceService
  private useMockMode: boolean = true

  static getInstance(): VoiceService {
    if (!VoiceService.instance) {
      VoiceService.instance = new VoiceService()
    }
    return VoiceService.instance
  }

  setMockMode(enabled: boolean): void {
    this.useMockMode = enabled
  }

  async startRecognition(): Promise<VoiceRecognitionResult> {
    if (this.useMockMode) {
      return this.mockRecognition()
    }
    return this.realRecognition()
  }

  private async realRecognition(): Promise<VoiceRecognitionResult> {
    throw new Error('Real voice recognition requires HarmonyOS AI API. ' +
      'In production: import speechRecognizer from \'@ohos.ai.speechRecognizer\' ' +
      'and call recognizer.startListening() with proper config.')
  }

  private async mockRecognition(): Promise<VoiceRecognitionResult> {
    return new Promise<VoiceRecognitionResult>((resolve) => {
      const scenarios: VoiceRecognitionResult[] = [
        { text: '我想学怎么用微信发朋友圈给孩子们看', confidence: 0.96, intent: ServiceType.WECHAT },
        { text: '帮我在手机上挂一个明天上午的号', confidence: 0.93, intent: ServiceType.MEDICAL_BOOKING },
        { text: '我想查一下我的医保卡里还有多少钱', confidence: 0.89, intent: ServiceType.HEALTH_INSURANCE },
        { text: '教我用手机打个车去市人民医院', confidence: 0.94, intent: ServiceType.TRANSPORT },
        { text: '怎么在微信上和孙子视频聊天', confidence: 0.91, intent: ServiceType.WECHAT },
        { text: '帮我预约专家号，腰疼好几天了', confidence: 0.88, intent: ServiceType.MEDICAL_BOOKING },
        { text: '我想知道退休金这个月到账了没有', confidence: 0.90, intent: ServiceType.HEALTH_INSURANCE },
        { text: '下雨天不好打车，教我用手机叫一辆出租车', confidence: 0.92, intent: ServiceType.TRANSPORT },
        { text: '微信里照片太多了想备份出来', confidence: 0.87, intent: ServiceType.WECHAT },
        { text: '医保异地就医备案怎么操作', confidence: 0.85, intent: ServiceType.HEALTH_INSURANCE }
      ]
      const pick = scenarios[Math.floor(Math.random() * scenarios.length)]
      setTimeout(() => resolve(pick), 600)
    })
  }

  parseIntent(text: string): ServiceType {
    const keywords: Record<ServiceType, string[]> = {
      [ServiceType.WECHAT]: ['微信', '朋友圈', '聊天', '视频', '照片', '相册', '语音', '群聊'],
      [ServiceType.MEDICAL_BOOKING]: ['挂号', '医院', '看病', '预约', '专家', '门诊', '科室', '就诊'],
      [ServiceType.HEALTH_INSURANCE]: ['医保', '社保', '养老', '退休', '报销', '备案', '社保卡'],
      [ServiceType.TRANSPORT]: ['打车', '出行', '导航', '公交', '地铁', '出租车', '叫车', '路线']
    }

    let bestMatch = ServiceType.WECHAT
    let maxScore = 0
    const kwEntries = Object.entries(keywords)
    for (let i = 0; i < kwEntries.length; i++) {
      const service = kwEntries[i][0] as ServiceType
      const words = kwEntries[i][1] as string[]
      let score = 0
      for (let j = 0; j < words.length; j++) {
        if (text.includes(words[j])) score++
      }
      if (score > maxScore) {
        maxScore = score
        bestMatch = service
      }
    }
    return bestMatch
  }
}
