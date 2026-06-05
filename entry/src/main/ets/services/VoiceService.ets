import { ServiceType, VoiceRecognitionResult } from '../models/ServiceModels'

/**
 * 语音识别服务
 * 封装鸿蒙AI语音API，支持真实语音输入与模拟模式切换
 */
export class VoiceService {
  private static instance: VoiceService
  private useMockMode: boolean = true

  static getInstance(): VoiceService {
    if (!VoiceService.instance) {
      VoiceService.instance = new VoiceService()
    }
    return VoiceService.instance
  }

  /**
   * 切换模拟/真实模式
   * 真实环境需调用 @ohos.ai.speechRecognizer 接口
   */
  setMockMode(enabled: boolean): void {
    this.useMockMode = enabled
  }

  /**
   * 开始语音识别
   * 返回结构化识别结果
   */
  async startRecognition(): Promise<VoiceRecognitionResult> {
    if (this.useMockMode) {
      return this.mockRecognition()
    }
    return this.realRecognition()
  }

  /**
   * 模拟语音识别（演示用）
   * 可扩展为调用鸿蒙 AI 语音 API:
   * import speechRecognizer from '@ohos.ai.speechRecognizer'
   */
  private async mockRecognition(): Promise<VoiceRecognitionResult> {
    return new Promise<VoiceRecognitionResult>((resolve) => {
      const scenarios: VoiceRecognitionResult[] = [
        { text: '我想学微信发朋友圈', confidence: 0.95, intent: ServiceType.WECHAT },
        { text: '帮我在手机上挂号', confidence: 0.92, intent: ServiceType.MEDICAL_BOOKING },
        { text: '怎么查医保余额', confidence: 0.88, intent: ServiceType.HEALTH_INSURANCE },
        { text: '教我用手机打车', confidence: 0.91, intent: ServiceType.TRANSPORT }
      ]
      const pick = scenarios[Math.floor(Math.random() * scenarios.length)]
      setTimeout(() => resolve(pick), 800)
    })
  }

  /**
   * 真实语音识别（对接鸿蒙AI语音API）
   * TODO: 接入 @ohos.ai.speechRecognizer.createRecognizer
   */
  private async realRecognition(): Promise<VoiceRecognitionResult> {
    // 实际实现示例:
    // const recognizer = speechRecognizer.createRecognizer({...})
    // const result = await recognizer.startListening()
    // return this.parseIntent(result.text)
    throw new Error('Real voice recognition requires HarmonyOS AI API integration')
  }

  /**
   * 基于关键词的意图解析
   */
  parseIntent(text: string): ServiceType {
    const keywords: Record<ServiceType, string[]> = {
      [ServiceType.WECHAT]: ['微信', '朋友圈', '聊天', '视频通话'],
      [ServiceType.MEDICAL_BOOKING]: ['挂号', '医院', '看病', '预约医生'],
      [ServiceType.HEALTH_INSURANCE]: ['医保', '社保', '养老金', '报销'],
      [ServiceType.TRANSPORT]: ['打车', '导航', '公交', '出行', '叫车']
    }

    let bestMatch = ServiceType.WECHAT
    let maxScore = 0
    const kwEntries = Object.entries(keywords)
    for (let i = 0; i < kwEntries.length; i++) {
      const service = kwEntries[i][0] as ServiceType
      const words = kwEntries[i][1] as string[]
      const score = words.filter(w => text.includes(w)).length
      if (score > maxScore) {
        maxScore = score
        bestMatch = service
      }
    }
    return bestMatch
  }
}
