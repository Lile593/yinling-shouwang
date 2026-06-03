# 银龄守望 —— 老年数字生活互助平台

基于 **HarmonyOS NEXT** 开发的智能服务匹配系统，通过 **AI 语音识别** 与 **多维度匹配算法**，为老年人精准匹配合适的大学生志愿者，帮助老年人跨越"数字鸿沟"。

## 技术栈

| 层级 | 技术 |
|------|------|
| 开发框架 | ArkTS + ArkUI（Stage 模型） |
| 操作系统 | HarmonyOS NEXT (API 14+) |
| 语音服务 | 鸿蒙 AI 语音 API / 模拟模式 |
| 数据持久化 | Preferences（键值对存储） |
| 网络通信 | HTTP Client（对接 AI 边缘计算节点） |
| 架构模式 | 单例服务层 + 组件化 UI |

## 项目结构

```
entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets           # 应用入口，多端自适应
├── models/
│   └── ServiceModels.ets          # 数据模型（志愿者、预约、匹配结果）
├── services/
│   ├── VoiceService.ets           # 语音识别服务（AI API + 模拟模式）
│   ├── MatchingEngine.ets         # 加权多维匹配算法引擎
│   └── AppointmentManager.ets     # 预约单 CRUD + 本地持久化
├── utils/
│   └── DateUtils.ets              # 日期/时间工具
└── pages/
    ├── Index.ets                  # 首页（四大服务入口 + 动态问候）
    ├── VoicePage.ets              # 语音录入页（5秒录音 + AI 识别）
    └── ResultPage.ets             # 匹配结果页（评分排序 + 预约下单）
```

## 核心功能

### 1. 智能语音录入
- 5 秒录音倒计时，自动采集语音
- `VoiceService` 封装语音识别逻辑，支持模拟模式与真实 AI API 双切换
- 基于关键词匹配的意图解析算法，自动推断服务类型
- 同步上传至 AI 边缘计算节点（`http://192.168.10.1:8000/ai-service`）

### 2. 加权多维匹配算法 (`MatchingEngine`)
| 维度 | 权重 | 说明 |
|------|------|------|
| 技能匹配度 | 40% | 志愿者技能与需求服务类型的关键词匹配 |
| 时间可用性 | 25% | 当天可用满分，相邻天 60%，其他递减 |
| 用户评分 | 20% | 5 分制归一化，区间 [0,1] |
| 服务经验 | 15% | 服务 10 次以上满分，线性递增 |

- 综合评分公式：`Score = Σ(维度得分 × 权重)`
- 结果按评分降序排列，最佳匹配高亮标注

### 3. 预约服务管理 (`AppointmentManager`)
- 基于鸿蒙 `Preferences` API 实现本地持久化存储
- 支持创建、查询（全部/按状态）、状态更新、删除
- 自动生成唯一预约单号（时间戳 + 随机码）
- 预约完成后同步至后端 REST API

### 4. 多端适配
- 支持手机（phone）和平板（tablet）双设备类型
- 窗口尺寸变化监听，自适应布局调整
- 深色/浅色模式跟随系统

## 快速开始

### 环境要求
- DevEco Studio 5.0+
- HarmonyOS NEXT API 14+
- 设备或模拟器

### 构建运行
1. 用 DevEco Studio 打开项目根目录
2. 等待依赖同步完成（`oh-package.json5`）
3. 连接设备或启动模拟器
4. 点击 **Run** → **Run 'entry'**

### 配置 AI 后端地址
编辑 `entry/src/main/ets/pages/VoicePage.ets` 第 112 行：
```typescript
httpRequest.request('http://YOUR_SERVER:PORT/ai-service', { ... })
```

编辑 `entry/src/main/ets/pages/ResultPage.ets` 第 170 行：
```typescript
httpRequest.request('http://YOUR_SERVER:PORT/api/v1/service/request', { ... })
```

## 适用场景

- 社区老年服务数字化平台
- 高校志愿者服务管理系统
- 鸿蒙 IoT + AI 边缘计算集成演示
- 无障碍/适老化应用参考

## 许可证

MIT License

## 作者

李乐 (Li Le) — 鸿蒙应用开发者

---

> 服务全程免费 · 志愿者实名认证 · 隐私严格保密
