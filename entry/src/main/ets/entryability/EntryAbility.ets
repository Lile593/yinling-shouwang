import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'

const DOMAIN = 0x0001

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      // 支持深色/浅色模式跟随系统
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
    } catch (err) {
      hilog.error(DOMAIN, 'yinling', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err))
    }
    hilog.info(DOMAIN, 'yinling', '银龄守望应用启动 | onCreate')
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'yinling', '应用销毁 | onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'yinling', '窗口创建 | onWindowStageCreate')

    // 加载首页，支持多端自适应
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'yinling', '页面加载失败: %{public}s', JSON.stringify(err))
        return
      }
      hilog.info(DOMAIN, 'yinling', '首页加载成功')
    })

    // 窗口尺寸变化监听（平板/折叠屏适配）
    windowStage.getMainWindow().then((mainWindow) => {
      mainWindow.on('windowSizeChange', (size) => {
        hilog.info(DOMAIN, 'yinling', '窗口尺寸变化: width=%{public}d, height=%{public}d',
          size.width, size.height)
      })
    })
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'yinling', '窗口销毁 | onWindowStageDestroy')
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'yinling', '应用回到前台 | onForeground')
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'yinling', '应用进入后台 | onBackground')
  }
}
