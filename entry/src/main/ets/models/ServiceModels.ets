export enum ServiceType {
  WECHAT = 'wechat',
  MEDICAL_BOOKING = 'medical_booking',
  HEALTH_INSURANCE = 'health_insurance',
  TRANSPORT = 'transport'
}

export const ServiceTypeLabel: Record<string, string> = {
  'wechat': '微信使用',
  'medical_booking': '医院挂号',
  'health_insurance': '医保社保',
  'transport': '打车导航'
}

export const ServiceIcons: Record<string, string> = {
  'wechat': '💬',
  'medical_booking': '🏥',
  'health_insurance': '📋',
  'transport': '🚗'
}

export interface Volunteer {
  id: string
  name: string
  age: number
  gender: string
  university: string
  major: string
  grade: string
  description: string
  skills: string[]
  availableTimes: TimeSlot[]
  rating: number
  serviceCount: number
  certifications: string[]
  avatar: string
}

export interface TimeSlot {
  dayOfWeek: number
  startHour: number
  endHour: number
}

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

export enum AppointmentStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled'
}

export const AppointmentStatusLabel: Record<string, string> = {
  'pending': '待确认',
  'confirmed': '已确认',
  'completed': '已完成',
  'cancelled': '已取消'
}

export const AppointmentStatusColor: Record<string, string> = {
  'pending': '#F97316',
  'confirmed': '#2563EB',
  'completed': '#07C160',
  'cancelled': '#8899AA'
}

export interface MatchResult {
  volunteer: Volunteer
  score: number
  matchDetails: string[]
}

export interface VoiceRecognitionResult {
  text: string
  confidence: number
  intent: ServiceType
}

export interface Evaluation {
  id: string
  appointmentId: string
  volunteerId: string
  volunteerName: string
  serviceType: ServiceType
  rating: number
  comment: string
  createTime: number
}

export interface ApiResponse {
  code: number
  message: string
  data: Object | null
}
