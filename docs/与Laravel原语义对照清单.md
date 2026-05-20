# 与 Laravel 原语义对照清单

## 目标

用于持续对照 `admin_panel` Laravel 实现与当前 Koa2 `src/modules/backoffice` 的迁移完成度，按模块标注：

- 已完成
- 半完成
- 未完成
- 有意偏离

本清单重点关注：

- 路由覆盖范围
- 校验规则
- 删除级联行为
- 发布流转
- 文件字段处理
- 搜索 / 自动填充逻辑

### 模块对照模板（执行时统一口径）

每个模块都按以下维度更新，避免“状态有结论、但无法执行”：

- 路由覆盖（入口、方法、参数语义）
- 校验规则（必填、分支、归属、跨实体一致性）
- 写操作链路（创建/更新/删除/状态/发布/排序）
- 文件字段链路（上传、回填、旧文件清理）
- 查询与展示（筛选、详情、搜索、自动填充）
- 权限边界（admin/producer/checkadmin）
- 当前状态（已完成/半完成/未完成/有意偏离）
- 下一步（缺口、落点文件、验收标准）

---

## 一、当前对照范围

### Laravel 路由基准

- `routes/admin.php`
- `routes/producer.php`

### Laravel Controller 基准

本轮重点核对：

- `App\Http\Controllers\Producer\VideoController`
- `App\Http\Controllers\Producer\TVShowController`
- `App\Http\Controllers\Producer\ShortsController`
- `App\Http\Controllers\Producer\RentTransactionController`
- `App\Http\Controllers\Producer\WithdrawalController`

### Koa2 对照实现

- `src/modules/backoffice/backoffice.route.ts`
- `src/modules/backoffice/backoffice.service.ts`
- `src/modules/backoffice/backoffice.repository.ts`
- `src/modules/backoffice/backoffice.views.ts`

---

## 二、模块状态总览

| 模块 | 状态 | 结论 |
|---|---|---|
| Admin 登录 / 仪表盘 / 个人资料 | 已完成 | 主链已具备基础可用性 |
| Admin Type / Category / Language / Season / Avatar / Channel | 半完成 | 基础列表与增改状态/排序已具备，但 destroy/show 等 Laravel 语义未全补齐 |
| Admin Video / TV Show / Shorts 内容管理 | 半完成 | 目前仅列表 + 状态切换，缺少 add/edit/details/delete 完整后台能力 |
| Admin Episode 管理 | 未完成 | 仅占位页 |
| Producer Profile / Change Password | 已完成 | 基础资料与密码修改可用 |
| Producer Channel | 已完成 | 列表页已具备 |
| Producer Video | 半完成 | 列表、创建、更新、删除、状态、发布、搜索/自动填充已具备，但与 Laravel 在字段校验、文件处理、详情页语义上仍有差距 |
| Producer TV Show | 半完成 | 列表、创建、更新、删除、状态、发布、搜索/自动填充、分集链路已具备，但与 Laravel 文件/校验/详情页语义仍不完全等价 |
| Producer TV Show Episode | 半完成 | CRUD/状态/排序已具备，且新增了 show 归属强校验，但文件字段与 Laravel 细节仍有差距 |
| Producer Shorts | 半完成 | 列表、创建、更新、删除、状态、发布、搜索/自动填充已具备，但 Laravel 本身无 release 路由，Koa2 目前存在扩展语义 |
| Producer Shorts Episode | 半完成 | CRUD/状态/排序已具备，归属校验已增强，但字段与 Laravel 语义仍需继续收口 |
| Producer Rent Transaction | 半完成 | 列表与摘要统计已具备，但筛选与字段语义是否完全等价仍需结合真实表结构继续校验 |
| Producer Withdrawal | 半完成 | 列表与申请已具备，最小提现金额/钱包校验已具备，但返回语义与 Laravel 仍有差异 |
| Admin 其余后台模块（User / Producer / Cast / Banner / Section / Notification / Coupon / Package / Payment / Setting / Page 等） | 未完成 | Koa2 backoffice 暂未迁移 |

---

## 三、路由覆盖对照

## 3.1 Producer 路由覆盖

### 已完成或基本覆盖

- `login / logout / dashboard`
- `profile`
- `change-password`
- `channel`
- `video/{type_id}`
- `video/save`
- `video/update/{video_id}`
- `video/delete/{video_id}/{type_id}`
- `video/serachname/{txtVal}`
- `video/getdata/{id}`
- `video-status`
- `video/releases`
- `tvshow/{type_id}`
- `tvshow/save`
- `tvshow/update/{tvshow_id}`
- `tvshow/delete/{tvshow_id}/{type_id}`
- `tvshow/serachname/{txtVal}`
- `tvshow/getdata/{id}`
- `tvshow-status`
- `tvshow/releases`
- `tvshow-episode/{tvshow_id}/{type_id}`
- `tvshow-episode/save`
- `tvshow-episode/update/{id}`
- `tvshow-episode/delete/{tvshow_id}/{id}/{type_id}`
- `tvshow-episode/status`
- `tvshow-episode/sortable`
- `shorts/{type_id}`
- `shorts/save`
- `shorts/update/{shorts_id}`
- `shorts/delete/{shorts_id}/{type_id}`
- `shorts/getdata/{id}`
- `shorts/serachname/{txtVal}`
- `shorts/status`
- `shorts-episode/{id}/{type_id}`
- `shorts-episode/save`
- `shorts-episode/update/{id}`
- `shorts-episode/delete/{showId}/{id}/{typeId}`
- `shorts-episode/status`
- `shorts-episode/sortable`
- `rent-transaction`
- `withdrawal`

### 半完成

- `video/details/{id}`
  - Laravel 有独立详情语义。
  - Koa2 当前以列表页折叠编辑 + `getdata` 自动填充为主，**没有独立 details 页面**。

- `tvshow/add / edit`
  - Laravel 是独立新增/编辑页面。
  - Koa2 当前是列表内新增 + 行内折叠编辑，能力在，但页面形态不等价。

- `shorts/add / edit`
  - 同上，能力在，形态不等价。

- `tvshow-episode/add / edit`
  - Laravel 为独立页面。
  - Koa2 当前为列表页新增 + 行内编辑。

- `shorts-episode/add / edit`
  - 同上。

### 有意偏离

- Laravel Producer 路由中 **没有** `shorts/releases`。
  - 当前 Koa2 增加了 `/producer/shorts/releases`，并且本项目策略为**保留增强**。
  - 偏离说明：
    - 类型：业务增强（非 Laravel 等价能力）
    - 当前决策：保留
    - 风险：后续与 Laravel 对照时容易被误判为“遗漏/错误”
    - 治理：始终在本清单保留“有意偏离”标记，必要时支持配置化关闭

---

## 3.2 Admin 路由覆盖

### 已完成或基本覆盖

- `login / logout / dashboard`
- `profile`
- `profile/changepassword`
- `type`
- `type/sortable/save`
- `category`
- `category/sortable/save`
- `language`
- `language/sortable/save`
- `season`
- `season/sortable/save`
- `avatar`
- `avatar/sortable/save`
- `channel`
- `video`
- `tvshow`
- `shorts`

### 半完成

- `admin/video/{type_id}`
  - Koa2 目前为聚合列表入口 `/admin/video`，没有 Laravel 的 `type_id` 分组内容管理语义。
  - 当前只支持状态切换，不支持 add/edit/details/delete/release。

- `admin/tvshow/{type_id}`
  - 同上，仅列表与状态切换，未达 Laravel 完整运营后台能力。

- `admin/shorts/{type_id}`
  - 同上，仅列表与状态切换。

### 未完成

以下 Laravel Admin 模块当前在 Koa2 backoffice 中基本未迁移：

- `user`
- `producer`
- `cast`
- `banner`
- `section`
- `notification`
- `reviews`
- `refer-earn`
- `coupon`
- `rent-price-list`
- `rent-transaction`（admin）
- `package`
- `transaction`
- `payment`
- `withdrawal`（admin）
- `admob`
- `app-setting`
- `panel-setting`
- `system-setting`
- `notificationconfiguration`
- `page`
- `admin episode tvshow/shorts` 真正管理页

---

## 四、Controller 语义对照

## 4.1 Producer Video

### 已完成

- **列表筛选**
  - Koa2 已支持 `input_search / input_rent / input_premium / input_status`。

- **基础校验**
  - 已覆盖：`type_id`、`video_type`、`name`、`channel_id`（频道内容）、`price/rent_day`（租赁）等。

- **状态切换**
  - 已具备。

- **发布流转**
  - 已具备，且包含 `type` / `channel` 检查。

- **搜索 / 自动填充**
  - `searchname`、`getdata` 已具备。

- **producer 归属校验**
  - 更新 / 删除 / 状态 / 发布都已走 producer 维度约束。

### 半完成

- **校验规则仍有差异，但主分支已补齐**
  - 本轮已补齐：`video_upload_type`/`subtitle_type` 必填、`video_type=6` 的 `channel_id` 校验、`is_rent=1` 的 `price/rent_day` 校验。
  - 本轮已补齐：`video_upload_type` 分支（`server_video` 必填 `video_320`；`live_stream_url`/`vdocipher_id`/其他外链 必填 `video_url_320`）。
  - 本轮已补齐：非 `server_video` 场景强制 `is_download=0`，与 Laravel 行为保持一致。
  - 剩余差异：Laravel 的文件上传对象、TMDB 回填与旧文件删除链路尚未等价。

- **文件字段处理不等价**
  - Laravel 处理：
    - `thumbnail` 文件上传 / TMDB URL 回填
    - `landscape` 文件上传 / TMDB URL 回填
    - `video_320/480/720/1080` 本地或对象存储写入
    - `trailer` 服务端视频或外链
    - `subtitle_1/2/3` 文件或 URL
    - 更新时删除旧文件
  - Koa2 当前主要是**字符串字段写入**，尚未实现真实文件接收、存储、旧文件清理。

- **详情页语义未补齐**
  - Laravel 有 `video/details/{id}`。
  - Koa2 当前没有单独详情页。

### 未完成

- `saveChunk`
  - Laravel Admin 有分片上传入口，Koa2 backoffice 暂无对应能力。

---

## 4.2 Producer TV Show

### 已完成

- **列表筛选**
  - Koa2 已支持 `input_search / input_rent / input_status`。

- **基础校验**
  - 已覆盖：`type_id`、`video_type`、`name`、频道类型 channel 必填、租赁 price/rent_day 校验。

- **状态切换 / 发布 / 搜索 / 自动填充**
  - 均已具备。

- **producer 归属校验**
  - 更新 / 删除 / 状态 / 发布都已走 producer 约束。

### 半完成

- **文件字段处理不等价**
  - Laravel 处理 `thumbnail / landscape / trailer` 的文件上传、URL 存储、旧文件删除。
  - Koa2 当前仍以字符串字段为主。

- **通知发送语义未补**
  - Laravel `store` 成功后按内容类型触发通知配置。
  - Koa2 当前未实现通知发送。

- **详情 / add / edit 页面形态不等价**
  - Laravel 是独立页面。
  - Koa2 目前主要通过列表页承载。

### 已知强项

- Koa2 现已补强 **episode -> show 归属一致性校验**，这部分在迁移安全性上已经优于当前“裸参数更新”的低配实现。

---

## 4.3 Producer TV Show Episode

### 已完成

- **列表 / 创建 / 更新 / 删除 / 状态 / 排序**
  - 主链已具备。

- **show ownership 校验**
  - 已校验分集所属 show 是否归当前 producer 所有。

- **update 前 episode -> show 一致性校验**
  - 已补齐。

- **排序时 id 集合归属校验**
  - 已补齐。

### 半完成

- **校验规则未完全对齐 Laravel**
  - Laravel 对 `video_upload_type` 为 `server_video / vdocipher_id / external` 的分支更完整。
  - Koa2 当前主要覆盖 `server_video` 必填 `video_320`、`subtitle_type` 必填等主线规则。

- **文件字段处理不等价**
  - Laravel 会处理：
    - `thumbnail / landscape`
    - `video_320/480/720/1080`
    - `subtitle_1/2/3`
    - 更新时旧文件删除
  - Koa2 尚未实现真实文件层。

- **独立 add/edit 页面未对齐**
  - 当前为列表+折叠编辑。

### 未完成

- 与 Laravel 完整的多分辨率视频 / 多字幕文件管理等价仍未完成。

---

## 4.4 Producer Shorts

### 已完成

- **列表 / 创建 / 更新 / 删除 / 状态**
  - 主链已具备。

- **搜索 / 自动填充**
  - 已具备。

- **producer 归属校验**
  - 更新 / 删除 / 状态 已具备。

### 半完成

- **字段与 Laravel 仍存在偏差**
  - Laravel Shorts 重点在 `thumbnail + trailer + description + is_title/is_comment/is_like`。
  - Koa2 虽已单独拆出 Shorts payload，不再完全复用 TV Show，但仍需继续核对真实表结构和页面字段。

- **文件处理不等价**
  - Laravel 处理 `thumbnail` 和 `trailer` 的真实文件/URL逻辑、更新时旧文件删除。
  - Koa2 当前仍未实现文件层等价。

### 需要重点确认

- Koa2 当前实现了 `releaseProducerShorts` 与 `/producer/shorts/releases`。
- 但 Laravel Producer 路由中 **没有对应 release 路由**。
- 这意味着当前 Koa2 对 Shorts 的“发布”属于**扩展行为**，需要决定：
  - 保留为产品增强
  - 还是删除/隐藏以完全对齐 Laravel

---

## 4.5 Producer Shorts Episode

### 已完成

- **列表 / 创建 / 更新 / 删除 / 状态 / 排序**
  - 主链已具备。

- **show ownership 校验**
  - 已校验 Shorts 属于当前 producer。

- **episode -> show 一致性校验**
  - 已补齐。

### 半完成

- **校验规则未完全对齐 Laravel**
  - Laravel `ShortsSave/ShortsUpdate` 主要关心 `video` 或 `video_url` 的分支。
  - Koa2 已覆盖 `server_video` 主视频必填，但语义字段命名与 Laravel 还不完全一致。

- **文件字段处理不等价**
  - Laravel 处理 `thumbnail`、`video_320` 与旧文件删除。
  - Koa2 暂未做到文件上传等价。

---

## 4.6 Producer Rent Transaction

### 已完成

- **列表页与摘要统计**
  - Koa2 已支持 `year / month / today` 汇总。

- **搜索**
  - 已支持内容/关键词搜索入口。

- **过期逻辑**
  - Koa2 已在查询前执行 `expireRentTransactions()`，语义上对应 Laravel `rent_expiry()`。

### 半完成

- **字段展示语义仍需继续核对真实库**
  - Laravel 展示：
    - `payment_type`
    - `transaction_status`
    - `producer_earning`
    - `commission`
    - `expiry_date/status`
    - `Rent_Transaction::getVideoName(...)`
  - Koa2 当前虽然已有列表，但是否完全复刻字段含义，仍要结合真实表结构继续核对。

- **内容名解析逻辑需确认**
  - Laravel 有显式 `getVideoName(video_id, video_type, sub_video_type)`。
  - Koa2 当前已做内容关联展示，但仍需确认分类是否完全等价。

---

## 4.7 Producer Withdrawal

### 已完成

- **列表**
  - 已具备。

- **申请创建**
  - 已具备。

- **最小提现金额校验**
  - 已具备。

- **钱包余额校验**
  - 已具备。

### 半完成

- **Laravel 使用 `updateOrCreate` + 余额递减**
  - Koa2 当前已做余额校验与创建，但与 Laravel 在“是否允许更新已有申请记录”的实现细节上不完全一致。

- **返回语义未完全对齐**
  - Laravel 更偏 JSON + 多语言文案。
  - Koa2 当前以 SSR 页面提示为主。

- **错误文案已更友好，但未完全多语言化**
  - 目前 Koa2 已完成“开发态报错收口”，但还不是 Laravel 那套 `__('label.xxx')` 语义体系。

---

## 五、Admin 内容管理线对照

## 5.1 已完成

- Admin 基础配置类模块：
  - Type
  - Category
  - Language
  - Season
  - Avatar
  - Channel

这些模块当前已具备：

- 列表
- 创建
- 更新
- 状态切换（除部分 Laravel 使用 `show` 语义）
- 排序（有 sortable 的模块）
- demo mode 防护
- 更友好的错误提示

## 5.2 半完成

### Admin Video / TVShow / Shorts

当前 Koa2 仅覆盖：

- 列表
- 状态切换

缺失：

- add
- edit
- details
- delete
- release
- getdata / searchname
- episode 管理入口的完整后台交互

结论：

- **当前 admin 内容管理线仍不是 Laravel 等价后台，只是最小可浏览/可切换状态版本。**

## 5.3 未完成

- Admin TVShow Episode 管理
- Admin Shorts Episode 管理
- 以及绝大多数运营后台模块

---

## 六、已完成 / 半完成 / 未完成清单

## 6.1 已完成

- Admin / Producer 登录登出与仪表盘基础链路
- Producer Profile / Change Password
- Producer Channel 列表
- Producer Video 主链基础能力
- Producer TV Show 主链基础能力
- Producer TV Show Episode 主链基础能力
- Producer Shorts 主链基础能力
- Producer Shorts Episode 主链基础能力
- Producer Withdrawal / Rent Transaction 基础查询链路
- demo mode 对关键写操作的保护范围已大幅补齐
- 开发态报错文案已收敛为后台可读提示

## 6.2 半完成

- Admin Type / Category / Language / Season / Avatar / Channel
- Admin Video / TV Show / Shorts
- Producer Video 与 Laravel 在文件处理 / 细粒度校验 / 详情页语义上的对齐
- Producer TV Show 与 Laravel 在文件处理 / 通知 / 独立页面语义上的对齐
- Producer TV Show Episode 与 Laravel 在多分辨率视频 / 字幕 / 文件删除上的对齐
- Producer Shorts 与 Laravel 的真实路由语义对齐（特别是 release）
- Producer Shorts Episode 与 Laravel 的文件处理语义对齐
- Producer Rent Transaction 与真实库字段语义对齐
- Producer Withdrawal 与 Laravel 的更新/创建细节语义对齐

## 6.3 未完成

- Admin 内容管理完整后台能力
- Admin Episode 管理
- Admin 其余运营模块
- Laravel 文件上传 / 存储 / 删除链路的 Koa2 等价实现
- Laravel 多语言消息体系的等价迁移

## 6.4 有意偏离

- Producer Shorts：保留 `/producer/shorts/releases` 增强路由（Laravel 原路由不存在）

---

## 七、Top 10 可执行缺口（按优先级）

1. Producer Video：补齐 `video_upload_type / subtitle_type / live_stream_url / vdocipher_id` 分支校验并形成验收样例。
2. Producer TV Show：补齐文件字段链路（上传/回填/旧文件清理）并更新详情语义对照。
3. Producer TV Show Episode：补齐多清晰度与字幕文件链路语义（含更新时旧文件处理）。
4. Producer Shorts：继续去 TV Show 化，收敛页面字段到真实 shorts 语义。
5. Producer Shorts Episode：补齐与 Laravel 的命名/校验分支差异并固定回归用例。
6. Producer Rent Transaction：逐字段核验列表与汇总语义（`transaction_status`、内容名解析等）。
7. Producer Withdrawal：核对 `updateOrCreate` 语义差异并明确是否需要兼容实现。
8. Admin Video / TV Show / Shorts：补齐 add/edit/details/delete/release，不再停留在列表 + toggle。
9. Admin Episode（TV Show / Shorts）：落地真实管理页，替换现有占位页。
10. 通用文件链路：建立统一文件兼容层（上传、URL/TMDB 回填、删除旧文件）并在清单记录模块覆盖率。

---

## 八、后续更新规则

后续每完成一项补齐，都在本文件中同步：

- 更新模块状态
- 更新“已完成 / 半完成 / 未完成 / 有意偏离”分类
- 在对应模块下追加“本轮已补齐项 / 剩余缺口 / 验收结果”

当前版本：`v2`（可执行对照结构 + 有意偏离治理）
