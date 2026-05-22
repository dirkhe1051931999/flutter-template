# DTLive admin_panel 迁移差距台账（截至 2026-05-22）

源项目：`D:\code\DTLive v2.1\...\ServerCode\admin_panel`
目标项目：`D:\code\flutter-template`

## 1) 总览结论

- `API`（移动端）主线已迁移约 90%+，但仍缺少少量账号设备能力与 v2.1 新增接口。
- `Producer` 后台（内容生产端）已迁移较完整，可继续以修复和补边角为主。
- `Admin` 后台（运营管理端）仅迁移了基础与部分内容管理能力，大量核心运营模块尚未迁移。
- 安装向导（install 多步骤）和部分运维管理能力尚未迁移。

## 2) API 缺失清单（高优先级）

以下接口在 Laravel `routes/api.php` 存在，但 Node `src/modules/dtlive/dtlive.route.ts` 未提供：

1. `POST /api/get_tv_login_code`
2. `POST /api/tv_login`
3. `POST /api/check_tv_login`
4. `POST /api/parent_control_check_password`
5. `POST /api/get_device_sync_list`
6. `POST /api/logout_device_sync`
7. `POST /api/add_remove_device_watching`
8. `POST /api/validate_coupon`（v2.1）

兼容性差异（建议补别名）：

1. 源：`POST /api/get_refer_earn_history`
2. 现：`/api/getReferEarnHistory`

建议同时支持两者，避免旧客户端 404。

## 3) Admin 后台缺失模块（最高工作量）

对比 Laravel `routes/admin.php` 与 Node `src/modules/backoffice/backoffice.route.ts`：

### 3.1 已基本覆盖

1. 登录/登出/仪表盘
2. profile 与改密
3. type/category/language/season/avatar/channel（含部分排序/状态切换）
4. video/tvshow/shorts 的基础列表与状态切换

### 3.2 仍缺失（按业务域）

1. 用户域：`user`、`user/dashboard/{id}`
2. 制作人域：`producer`、`producer/content/*`
3. 演员域：`cast`
4. Banner 域：`banner/*`（typebydata/list/sort）
5. 首页分区域：`section/*`（data/edit/sort/content/status）
6. 通知域：`notification`、`notifications/setting`
7. 评论审核域：`reviews`、`approve/reject/destroy`
8. 营销与交易域：`coupon`、`rent-price-list`、`rent-transaction`、`package`、`transaction`
9. 支付与财务域：`payment`、`wallet-transaction`、`withdrawal`
10. 广告配置域：`admob`（status/android/ios）
11. 应用配置域：`app-setting/*`（api token/smtp/storage/social/vdocipher/refer-earn 等）
12. 面板/系统域：`panel-setting`、`system-setting/*`
13. 通知配置域：`notificationconfiguration`
14. 页面管理域：`page/*`、`page/pagesetting`
15. Admin 端完整分集管理（目前还是占位页）

## 4) Producer 后台状态

`routes/producer.php` 主流程在 Node 端已可见对应路由，整体迁移进度较好。

待确认点（非阻断）：

1. 个别方法命名兼容（如 `serachname` 拼写保持历史兼容）。
2. 与 Laravel 页面行为一致性（提示文案、筛选、排序细节）可后续回归。

## 5) 安装与运维流程缺失

Laravel `routes/install.php` 的安装步骤未在 Node 项目看到等价流程：

1. `step0` ~ `step5`
2. `purchase_code`
3. `database_installation`
4. `backup_db`
5. `import_sql`
6. `system_settings`

如果你的部署改为容器化/一键脚本，也可以不做页面式安装向导；但需补齐同等自动化能力（环境检测、导库、初始化配置）。

## 6) 资源迁移现状

- Laravel `resources/views` 文件数约 `101`
- Node `backoffice/templates` 文件数约 `19`

说明大量后台页面模板尚未迁移，当前页面覆盖仍偏核心路径。

## 7) 推荐迁移顺序（可执行）

### 阶段 A（1-2 天，先保客户端可用）

1. 补齐缺失 API 8 个接口。
2. 为 `get_refer_earn_history` 增加兼容别名路由。
3. 做一轮接口契约回归（请求参数、响应码、字段名）。

### 阶段 B（3-5 天，先补运营核心）

1. `user`、`producer`、`section`、`banner`、`notification`。
2. 这 5 组决定运营日常是否可闭环。

### 阶段 C（4-7 天，补财务与配置）

1. `coupon`、`package`、`transaction`、`payment`、`wallet-transaction`、`withdrawal`。
2. `app-setting`、`admob`、`panel-setting`、`system-setting`。

### 阶段 D（2-4 天，收尾）

1. `page`、`notificationconfiguration`、Admin 分集完善。
2. 全量回归 + 文案/权限/边界行为对齐。

## 8) 风险提醒

1. 你当前新项目同时放开 `GET + POST` API（老项目多为 `POST`），建议确认网关/缓存策略，避免被错误缓存。
2. 中文提示出现乱码（路由文件里可见），建议统一 UTF-8 文案源，避免后台可用性问题。
3. 涉及支付/提现/配置项迁移时，优先做只读页，再放写操作，降低事故风险。

## 9) 阶段 A 联调脚本

- 已新增接口回归脚本：`tests/dtlive-stage-a-regression.http`
- 覆盖范围：
  1. TV 登录三件套（取码/绑定/轮询）
  2. 家长控制密码校验
  3. 设备同步列表与登出
  4. 设备观看并发控制（add/remove）
  5. `validate_coupon`
  6. `get_refer_earn_history` 兼容别名
