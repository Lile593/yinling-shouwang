/**
 * 日期工具类
 */
export class DateUtils {
  /**
   * 格式化时间戳为可读日期
   */
  static formatDate(timestamp: number): string {
    const d = new Date(timestamp)
    const y = d.getFullYear()
    const m = String(d.getMonth() + 1).padStart(2, '0')
    const day = String(d.getDate()).padStart(2, '0')
    return `${y}-${m}-${day}`
  }

  /**
   * 格式化时间戳为可读日期时间
   */
  static formatDateTime(timestamp: number): string {
    const date = DateUtils.formatDate(timestamp)
    const d = new Date(timestamp)
    const h = String(d.getHours()).padStart(2, '0')
    const min = String(d.getMinutes()).padStart(2, '0')
    return `${date} ${h}:${min}`
  }

  /**
   * 获取星期几的中文名
   */
  static getDayOfWeekName(dayOfWeek: number): string {
    const names = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    return names[dayOfWeek] || '未知'
  }

  /**
   * 获取今天的星期数 (0-6)
   */
  static getTodayDayOfWeek(): number {
    return new Date().getDay()
  }

  /**
   * 获取相对时间描述
   */
  static getRelativeTime(timestamp: number): string {
    const now = Date.now()
    const diff = now - timestamp
    const minutes = Math.floor(diff / 60000)
    if (minutes < 1) return '刚刚'
    if (minutes < 60) return `${minutes}分钟前`
    const hours = Math.floor(minutes / 60)
    if (hours < 24) return `${hours}小时前`
    const days = Math.floor(hours / 24)
    if (days < 7) return `${days}天前`
    return DateUtils.formatDate(timestamp)
  }
}
