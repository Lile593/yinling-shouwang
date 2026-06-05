import { http } from '@kit.NetworkKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { ApiResponse } from '../models/ServiceModels'

const BASE_URL = 'http://192.168.10.1:8000'
const TIMEOUT = 10000

interface VoiceUploadBody {
  voice_text: string
  service_type: string
  timestamp: string
}

interface AppointmentSyncBody {
  request_id: string
  matched_volunteer: string
  timestamp: string
}

export class ApiService {
  private static instance: ApiService

  static getInstance(): ApiService {
    if (!ApiService.instance) {
      ApiService.instance = new ApiService()
    }
    return ApiService.instance
  }

  async post(path: string, body: Object): Promise<ApiResponse> {
    return new Promise<ApiResponse>((resolve, reject) => {
      const req = http.createHttp()
      req.request(`${BASE_URL}${path}`, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: body,
        connectTimeout: TIMEOUT,
        readTimeout: TIMEOUT
      }, (err: BusinessError, data: http.HttpResponse) => {
        if (!err && data.responseCode === 200) {
          const result = JSON.parse(data.result as string) as ApiResponse
          resolve(result)
          console.info(`[ApiService] POST ${path} succeeded`)
        } else {
          console.error(`[ApiService] POST ${path} failed: ${err ? err.message : 'HTTP ' + data.responseCode}`)
          reject(err || new Error(`HTTP ${data.responseCode}`))
        }
        req.destroy()
      })
    })
  }

  async get(path: string, params?: Record<string, string>): Promise<ApiResponse> {
    let url = `${BASE_URL}${path}`
    if (params) {
      const query = Object.keys(params).map(k => `${k}=${encodeURIComponent(params[k])}`).join('&')
      url += '?' + query
    }

    return new Promise<ApiResponse>((resolve, reject) => {
      const req = http.createHttp()
      req.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: TIMEOUT,
        readTimeout: TIMEOUT
      }, (err: BusinessError, data: http.HttpResponse) => {
        if (!err && data.responseCode === 200) {
          const result = JSON.parse(data.result as string) as ApiResponse
          resolve(result)
          console.info(`[ApiService] GET ${path} succeeded`)
        } else {
          console.error(`[ApiService] GET ${path} failed: ${err ? err.message : 'HTTP ' + data.responseCode}`)
          reject(err || new Error(`HTTP ${data.responseCode}`))
        }
        req.destroy()
      })
    })
  }

  uploadVoice(text: string, serviceType: string): void {
    const body: VoiceUploadBody = {
      voice_text: text,
      service_type: serviceType,
      timestamp: new Date().toISOString()
    }
    this.post('/ai-service', body).catch(() => {})
  }

  syncAppointment(appointmentId: string, volunteerId: string): void {
    const body: AppointmentSyncBody = {
      request_id: appointmentId,
      matched_volunteer: volunteerId,
      timestamp: new Date().toISOString()
    }
    this.post('/api/v1/service/request', body).catch(() => {})
  }

  syncEvaluation(evaluation: Object): void {
    this.post('/api/v1/service/evaluation', evaluation).catch(() => {})
  }
}
