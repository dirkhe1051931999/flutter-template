# 埋点开发计划

## 1. 目标

为 `flutter-template` 的 `video_tabs` 页面接入一套可本地联调、可持续扩展的埋点系统：

- Flutter 侧统一调用埋点 SDK
- Go 后端提供埋点采集 API
- MySQL 持久化事件数据
- Redis 预留去重、限流、异步缓冲能力
- `oolaf` 的 Web 管理层展示埋点概览和事件明细

推荐方案：

- Flutter 侧使用本地 SDK 封装埋点调用
- SDK 内部通过 HTTP API 上报到 Go 后端
- 不使用 custom 协议作为主链路

原因：

- HTTP API 更容易本地联调
- 请求链路更清晰，方便抓日志和排查问题
- 后续 Android、iOS、Windows、Web 都能复用同一套埋点协议
- Go 服务端更容易做鉴权、限流、补充服务端字段、批量处理和监控

## 2. 总体架构

链路建议如下：

1. Flutter 页面触发行为事件
2. Flutter `AnalyticsSdk` 统一组装事件
3. SDK 调用 Go 埋点接口 `POST /api/public/ingest`
4. Go Handler 校验 token 和参数
5. Go Service 补齐服务端公共字段
6. Repository 写入 MySQL
7. Web 管理层通过 Analytics API 查询和展示

第一期先做同步落库，保证尽快联调成功。

第二期再视数据量加入：

- 批量上报
- 本地失败重试
- Redis 队列
- 异步消费入库

## 3. 开发阶段

建议按三个阶段推进。

### 第一阶段：埋点采集打通

目标：

- Flutter 能成功把埋点发到本机 Go 服务
- Go 能校验、记录、入库
- 本地能看到事件明细

范围：

- 单条事件上报
- 最小事件模型
- 简单事件列表查询

### 第二阶段：SDK 和页面接入完善

目标：

- `video_tabs` 关键交互全部接入
- SDK 能自动附带公共字段
- 失败有简单重试或降级

范围：

- 页面曝光、播放、暂停、完成、切 tab 等
- 会话、设备、用户、页面上下文补齐

### 第三阶段：Web 可视化

目标：

- 在 `oolaf` Web 层查看埋点数据
- 能看总量、活跃、近实时事件流
- 能按项目、环境、事件名筛选

范围：

- 仪表盘
- 事件明细页
- 简单趋势图

## 4. Go 后端埋点服务开发计划

项目位置：

- `C:\Users\Administrator\Documents\code\oolaf`

从现状看，`oolaf` 已经有以下基础：

- `IngestService`
- `IngestRepository`
- `AnalyticsHandler`
- `event_ingests` / `ingest_tokens` / `user_identities` 相关模型基础

因此重点不是重做一套，而是把现有能力补齐到可用。

### 4.1 接口设计

第一期新增接口：

- `POST /api/public/ingest`

请求头建议：

- `Content-Type: application/json`
- `X-Ingest-Token: <token>`

请求体建议：

```json
{
  "event_name": "video_play",
  "distinct_id": "windows_debug_user_001",
  "user_id": 123,
  "session_id": "session_xxx",
  "trace_id": "trace_xxx",
  "page_url": "/video_tabs/feed",
  "referrer": "/video_tabs/home",
  "event_time": "2026-05-29T22:30:00Z",
  "properties": {
    "video_id": "123",
    "tab": "feed",
    "position_ms": 3200
  }
}
```

返回体建议：

```json
{
  "code": 0,
  "message": "ok",
  "data": {
    "event_id": 1001
  }
}
```

第二期新增接口：

- `POST /api/public/ingest/batch`

用于批量上报，减少请求次数。

### 4.2 Handler 层

新增建议：

- `internal/api/handler/ingest_handler.go`

职责：

- 解析请求头中的 `X-Ingest-Token`
- 绑定 JSON 参数
- 将 `properties` 转成 JSON 字符串或 `json.RawMessage`
- 获取客户端 IP、User-Agent
- 调用 `IngestService`
- 返回标准响应

同时在路由中挂载公开埋点接口。

建议修改：

- `internal/api/router.go`

新增路由组：

- `apiV1.Group("/public")`
- `POST /api/v1/public/ingest`

如果想更短，也可直接：

- `POST /api/public/ingest`

但为了和现有版本化风格一致，更推荐：

- `POST /api/v1/public/ingest`

### 4.3 Service 层

复用并扩展：

- `internal/service/ingest_service.go`

需要确认或补充的逻辑：

- token 是否有效
- token 是否属于激活状态
- `event_name` 是否为空
- `distinct_id` 是否为空
- 默认 `ingest_source` 填 `flutter_sdk`
- `event_time` 为空时使用服务端时间
- 自动 upsert `user_identities`

建议额外补充：

- 限制 `properties_json` 最大长度
- 对高频错误事件做日志采样
- 可选做事件名白名单校验

### 4.4 Repository 层

复用：

- `internal/repository/ingest_repository.go`

需确认数据库结构是否齐全：

- `event_ingests`
- `ingest_tokens`
- `user_identities`

建议检查并补充索引：

- `project_id, event_time`
- `event_name, event_time`
- `distinct_id, event_time`
- `received_at`

如果事件量增长较快，后续可加：

- 按日期分表
- 月分区

第一期先不做。

### 4.5 配置与联调

本地联调配置建议：

- Go 服务监听 `127.0.0.1:8080` 或 `0.0.0.0:8080`
- Flutter Windows 包使用 `http://127.0.0.1:8080`

本地验证步骤：

1. 启动 Go 服务
2. 手工调用埋点接口
3. 确认日志打印
4. 确认 MySQL 已写入
5. 再接 Flutter SDK

PowerShell 调试示例：

```powershell
$headers = @{
  "Content-Type" = "application/json"
  "X-Ingest-Token" = "your_local_token"
}

$body = @'
{
  "event_name": "video_play",
  "distinct_id": "windows_debug_user_001",
  "session_id": "session_001",
  "page_url": "/video_tabs/feed",
  "properties": {
    "video_id": "123",
    "tab": "feed"
  }
}
'@

Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:8080/api/v1/public/ingest" -Headers $headers -Body $body
```

### 4.6 Redis 的定位

第一期：

- Redis 不作为必选链路

第二期可用于：

- 简单限流
- 高频重复事件去重
- 批量落库缓冲
- 实时计数缓存

建议不要一开始就把埋点主链路做成 Redis 队列消费，否则本地联调复杂度会明显上升。

### 4.7 安全与治理

建议加入：

- `ingest_token` 鉴权
- 单 token 限流
- 单 IP 限流
- 最大 body 限制
- 非法事件名拦截
- 请求日志和错误日志

后续再加入：

- token 过期
- token 按环境区分
- 项目级别权限控制

## 5. Flutter 埋点 SDK 开发计划

项目位置：

- `C:\Users\Administrator\Documents\code\flutter-template`

目标：

- 页面只管调用埋点 API，不关心 HTTP 细节
- 统一公共字段
- 调试时容易打印日志

### 5.1 SDK 结构建议

建议新增目录：

- `lib/analytics/analytics_sdk.dart`
- `lib/analytics/analytics_event.dart`
- `lib/analytics/analytics_context.dart`
- `lib/analytics/analytics_transport.dart`

推荐职责划分：

- `analytics_sdk.dart`
  - 对外暴露 `track`
  - 暴露业务快捷方法，如 `trackVideoPlay`
- `analytics_event.dart`
  - 定义事件结构
- `analytics_context.dart`
  - 维护公共字段，如 `distinctId`、`sessionId`
- `analytics_transport.dart`
  - 封装 HTTP 请求

### 5.2 SDK 对外接口建议

建议对页面暴露：

```dart
analytics.track(
  eventName: 'video_play',
  properties: {
    'video_id': videoId,
    'tab': currentTab,
    'position_ms': positionMs,
  },
);
```

可再封装业务快捷方法：

```dart
analytics.trackVideoPlay(videoId: videoId, tab: 'feed', positionMs: 3200);
analytics.trackVideoPause(videoId: videoId, tab: 'feed', positionMs: 5600);
analytics.trackTabSwitch(from: 'hot', to: 'feed');
```

### 5.3 公共字段建议

SDK 自动补齐：

- `event_name`
- `distinct_id`
- `user_id`
- `session_id`
- `trace_id`
- `page_url`
- `event_time`
- `platform`
- `app_version`
- `device_type`
- `properties`

Windows 调试场景下建议：

- `distinct_id` 使用本地生成并持久化的 UUID
- `session_id` 启动应用时生成
- `trace_id` 每次请求生成

### 5.4 video_tabs 首批埋点范围

建议第一批只做关键路径，避免一次埋太多。

事件建议：

- `tab_switch`
- `video_expose`
- `video_play`
- `video_pause`
- `video_complete`
- `video_like`
- `video_share`
- `video_search`
- `video_open_detail`

属性建议：

- `video_id`
- `author_id`
- `tab_name`
- `position`
- `position_ms`
- `duration_ms`
- `from_page`
- `keyword`

### 5.5 页面接入建议

优先接入：

- `short_video_feed_page.dart`
- `short_video_hot_page.dart`
- `short_video_headline_page.dart`
- `short_video_search_page.dart`
- `short_video_shell_page.dart`

接入顺序建议：

1. Shell 页切 tab
2. Feed 页视频曝光
3. Feed 页播放暂停完成
4. 搜索和详情页行为

### 5.6 失败处理建议

第一期：

- 请求失败只打本地日志
- 不阻塞主流程

第二期：

- 内存队列重试
- 批量 flush
- 离线缓存到本地文件或 sqlite

Windows 本地调试阶段不建议一开始就做复杂离线机制。

### 5.7 本地联调方式

因为你当前是 Windows 包联调，本地地址直接使用：

- `http://127.0.0.1:8080`

建议在 Flutter 中集中配置：

```dart
class AnalyticsEnv {
  static const String baseUrl = 'http://127.0.0.1:8080';
  static const String ingestToken = 'your_local_token';
}
```

调试阶段建议打开详细日志：

- 请求 URL
- 请求 body
- 响应状态码
- 响应 body

## 6. Go Web 层展示埋点数据开发计划

项目位置：

- `C:\Users\Administrator\Documents\code\oolaf\web`

目标：

- 管理端能看项目埋点概览
- 能查看近实时事件
- 能看简单趋势和核心指标

### 6.1 现有基础

`oolaf` 已经存在：

- `AnalyticsHandler`
- 仪表盘概览接口基础
- 项目、环境、事件定义、属性定义等接口基础

说明管理侧已经不是从零开始，可以直接扩展。

### 6.2 Web 管理层第一期页面

建议先做两个页面。

#### A. 埋点概览页

展示：

- 今日事件总数
- 今日活跃用户数
- 最近 7 天事件趋势
- 事件名 Top N

筛选条件：

- 工作区
- 项目
- 环境
- 时间范围

#### B. 事件明细页

展示字段：

- 事件时间
- 事件名
- distinct_id
- user_id
- page_url
- ingest_source
- properties_json

支持：

- 按事件名筛选
- 按时间筛选
- 按 distinct_id 搜索

### 6.3 Go 查询接口建议

建议新增或扩展接口：

- `GET /api/v1/projects/:projectId/events/recent`
- `GET /api/v1/projects/:projectId/events/trend`
- `GET /api/v1/projects/:projectId/events/top`
- `GET /api/v1/projects/:projectId/events/search`

返回内容建议：

- recent: 最近事件流
- trend: 按小时或按天聚合的事件数量
- top: 按事件名聚合排行
- search: 支持分页查询明细

### 6.4 Service / Repository 查询能力

建议新增查询能力：

- 事件总数统计
- DAU 统计
- 按事件名分组统计
- 按时间桶聚合
- 分页明细查询

Repository SQL 方向建议：

- `COUNT(*)`
- `COUNT(DISTINCT distinct_id)`
- `GROUP BY event_name`
- `GROUP BY DATE(event_time)` 或按小时聚合
- `ORDER BY event_time DESC LIMIT ?, ?`

### 6.5 Web 前端展示建议

第一期就够用的组件：

- 指标卡片
- 简单折线图
- 事件表格
- 筛选栏

页面顺序建议：

1. 先把概览卡片做出来
2. 再做最近事件表格
3. 再补趋势图和筛选

### 6.6 事件治理页面

第二期可做：

- 事件定义管理
- 属性定义管理
- 是否启用某事件
- 事件说明文档

这样后续你们团队能规范事件命名，避免埋点越来越乱。

## 7. 数据模型建议

埋点最小公共模型建议统一为：

```json
{
  "event_name": "video_play",
  "distinct_id": "device_or_user_unique_id",
  "user_id": 123,
  "session_id": "session_001",
  "trace_id": "trace_001",
  "page_url": "/video_tabs/feed",
  "referrer": "/video_tabs/home",
  "event_time": "2026-05-29T22:30:00Z",
  "properties": {
    "video_id": "123",
    "tab": "feed",
    "position_ms": 3200
  }
}
```

命名规范建议：

- 事件名：小写下划线，如 `video_play`
- 属性名：小写下划线，如 `position_ms`
- 页面名：固定枚举，避免同义词过多

## 8. 推荐实施顺序

建议按下面顺序执行。

1. 检查 `oolaf` 数据库表和索引是否完整
2. 在 Go 中新增公开埋点接口
3. 用 PowerShell 手工请求验证入库
4. 在 Flutter 中实现最小 `AnalyticsSdk`
5. 在 `video_tabs` 先接 `tab_switch` 和 `video_play`
6. 在 Go Web 层增加最近事件列表页
7. 再补概览统计和趋势图
8. 最后做批量上报、重试和治理能力

## 9. 第一版验收标准

满足以下条件即可认为第一版打通：

- Flutter Windows 包点击页面后能发出埋点请求
- Go 后端能成功返回 `event_id`
- MySQL 的 `event_ingests` 中能看到记录
- Web 管理页能看到最近事件列表
- 能按项目查看事件总数和最近事件

## 10. 后续优化方向

后续可继续做：

- 批量上报
- 本地离线缓存
- 事件去重
- 秒级实时看板
- 漏斗分析
- 留存分析
- 用户行为路径
- A/B 实验

## 11. 本次建议结论

最合适的方向是：

- Flutter 侧做 SDK
- SDK 内部走 HTTP API
- Go 侧做公开 ingest 接口
- Web 层先做概览和事件明细

不建议把 custom 协议作为主链路，因为它不适合承担埋点系统的网络采集职责，也会提高联调和排障成本。
