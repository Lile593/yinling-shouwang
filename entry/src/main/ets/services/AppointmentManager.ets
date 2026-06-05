import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { Appointment, AppointmentStatus, Evaluation, ServiceType } from '../models/ServiceModels'

export class AppointmentManager {
  private static instance: AppointmentManager
  private store: preferences.Preferences | null = null
  private readonly STORE_NAME = 'yinling_appointments'
  private readonly EVAL_STORE_NAME = 'yinling_evaluations'
  private readonly KEY_PREFIX = 'appointment_'
  private readonly EVAL_PREFIX = 'evaluation_'
  private evalStore: preferences.Preferences | null = null

  static getInstance(): AppointmentManager {
    if (!AppointmentManager.instance) {
      AppointmentManager.instance = new AppointmentManager()
    }
    return AppointmentManager.instance
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    this.store = await preferences.getPreferences(context, this.STORE_NAME)
    this.evalStore = await preferences.getPreferences(context, this.EVAL_STORE_NAME)
  }

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

  async queryByStatus(status: AppointmentStatus): Promise<Appointment[]> {
    const all = await this.queryAll()
    return all.filter(a => a.status === status)
  }

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

  async saveEvaluation(evaluation: Evaluation): Promise<boolean> {
    if (!this.evalStore) return false
    try {
      await this.evalStore.put(`${this.EVAL_PREFIX}${evaluation.id}`, JSON.stringify(evaluation))
      await this.evalStore.flush()
      return true
    } catch (e) {
      console.error('[AppointmentManager] saveEvaluation failed:', JSON.stringify(e))
      return false
    }
  }

  async getEvaluation(appointmentId: string): Promise<Evaluation | null> {
    if (!this.evalStore) return null
    try {
      const raw = await this.evalStore.get(`${this.EVAL_PREFIX}${appointmentId}`, '') as string
      if (!raw) return null
      return JSON.parse(raw) as Evaluation
    } catch (e) {
      return null
    }
  }

  generateId(): string {
    const ts = Date.now().toString(36).toUpperCase()
    const rand = Math.random().toString(36).substring(2, 6).toUpperCase()
    return `APT-${ts}-${rand}`
  }
}
