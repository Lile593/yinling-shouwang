/**
 * 服务类型枚举
 */
export enum ServiceType {
  WECHAT = 'wechat',
  MEDICAL_BOOKING = 'medical_booking',
  HEALTH_INSURANCE = 'health_insurance',
  TRANSPORT = 'transport'
}

/**
 * 服务类型中文映射
 */
export const ServiceTypeLabel: Record<string, string> = {
  'wechat': '微信使用',
  'medical_booking': '医院挂号',
  'health_insurance': '医保社保',
  'transport': '打车导航'
}

/**
 * 志愿者信息模型
 */
export interface Volunteer {
  id: string
  name: string
  major: string
  skills: string[]
  availableTimes: TimeSlot[]
  rating: number
  serviceCount: number
  avatar: string
}

/**
 * 时间段模型
 */
export interface TimeSlot {
  dayOfWeek: number  // 0=周日, 1=周一...
  startHour: number
  endHour: number
}

/**
 * 预约单模型
 */
export interface Appointment {
  id: string
  serviceType: ServiceType
  volunteerId: string
  volunteerName: string
  elderName: string
  elderPhone: string
  elderAddress: string
  appointmentDate: string
  timeSlot: string
  status: AppointmentStatus
  remark: string
  createTime: number
}

/**
 * 预约状态枚举
 */
export enum AppointmentStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled'
}

/**
 * 匹配结果模型
 */
export interface MatchResult {
  volunteer: Volunteer
  score: number
  matchDetails: string[]
}

/**
 * 语音识别结果模型
 */
export interface VoiceRecognitionResult {
  text: string
  confidence: number
  intent: ServiceType
}
