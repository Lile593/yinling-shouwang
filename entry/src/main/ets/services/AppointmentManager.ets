import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { Appointment, AppointmentStatus, ServiceType } from '../models/ServiceModels'

/**
 * 预约管理器
 * 基于鸿蒙 Preferences 实现本地持久化存储
 */
export class AppointmentManager {
  private static instance: AppointmentManager
  private store: preferences.Preferences | null = null
  private readonly STORE_NAME = 'yinling_appointments'
  private readonly KEY_PREFIX = 'appointment_'

  static getInstance(): AppointmentManager {
    if (!AppointmentManager.instance) {
      AppointmentManager.instance = new AppointmentManager()
    }
    return AppointmentManager.instance
  }

  /**
   * 初始化存储
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    this.store = await preferences.getPreferences(context, this.STORE_NAME)
  }

  /**
   * 创建预约单
   */
  async create(appointment: Appointment): Promise<boolean> {
    if (!this.store) return false
    try {
      await this.store.put(`${this.KEY_PREFIX}${appointment.id}`, JSON.stringify(appointment))
      await this.store.flush()
      return true
    } catch (e) {
      console.error('[AppointmentManager] create failed:', JSON.stringify(e))
      return false
    }
  }

  /**
   * 查询所有预约单（按时间倒序）
   */
  async queryAll(): Promise<Appointment[]> {
    if (!this.store) return []
    try {
      const allData = await this.store.getAll()
      const result: Appointment[] = []
      const dataEntries = Object.entries(allData) as Array<[string, Object]>
      for (let i = 0; i < dataEntries.length; i++) {
        const key: string = dataEntries[i][0]
        const value: Object = dataEntries[i][1]
        if (typeof key === 'string' && key.startsWith(this.KEY_PREFIX) && typeof value === 'string') {
          result.push(JSON.parse(value) as Appointment)
        }
      }
      return result.sort((a, b) => b.createTime - a.createTime)
    } catch (e) {
      console.error('[AppointmentManager] queryAll failed:', JSON.stringify(e))
      return []
    }
  }

  /**
   * 按状态筛选预约单
   */
  async queryByStatus(status: AppointmentStatus): Promise<Appointment[]> {
    const all = await this.queryAll()
    return all.filter(a => a.status === status)
  }

  /**
   * 更新预约状态
   */
  async updateStatus(id: string, status: AppointmentStatus): Promise<boolean> {
    if (!this.store) return false
    try {
      const raw = await this.store.get(`${this.KEY_PREFIX}${id}`, '') as string
      if (!raw) return false
      const appointment = JSON.parse(raw) as Appointment
      appointment.status = status
      await this.store.put(`${this.KEY_PREFIX}${id}`, JSON.stringify(appointment))
      await this.store.flush()
      return true
    } catch (e) {
      console.error('[AppointmentManager] updateStatus failed:', JSON.stringify(e))
      return false
    }
  }

  /**
   * 删除预约单
   */
  async delete(id: string): Promise<boolean> {
    if (!this.store) return false
    try {
      await this.store.delete(`${this.KEY_PREFIX}${id}`)
      await this.store.flush()
      return true
    } catch (e) {
      console.error('[AppointmentManager] delete failed:', JSON.stringify(e))
      return false
    }
  }

  /**
   * 生成预约ID
   */
  generateId(): string {
    const ts = Date.now().toString(36).toUpperCase()
    const rand = Math.random().toString(36).substring(2, 6).toUpperCase()
    return `APT-${ts}-${rand}`
  }
}
