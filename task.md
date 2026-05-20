# Koa2 迁移后续任务清单

## 1. Producer 内容主链模块化收口

### 1.1 Video 模块收口
- 修正 `tbl_video` 与当前 Koa2 查询/写入字段不一致的问题
- 验证并修复列表、详情、创建、更新、删除、状态切换、发布流转
- 收口表单字段校验、页面回填、错误提示
- 验证搜索、数据填充、权限边界是否完整

### 1.2 TV Show 模块收口
- 修正 `tbl_tv_show` 与当前 Koa2 查询/写入字段不一致的问题
- 验证并修复列表、详情、创建、更新、删除、状态切换、发布流转
- 收口表单字段校验、页面回填、错误提示
- 验证搜索、数据填充、权限边界是否完整

### 1.3 Shorts 模块收口
- 修正 `tbl_shorts` 与当前 Koa2 查询/写入字段不一致的问题
- 解除对 `ProducerTvShowItem` / `ProducerTvShowDetail` 的过度复用，按真实 shorts 表结构拆分类型与查询
- 验证并修复列表、详情、创建、更新、删除、状态切换、发布流转
- 收口表单字段校验、页面回填、错误提示

## 2. Episode 模块继续补强

### 2.1 TV Show Episode
- 补充 `episodeId -> show_id` 一致性校验
- 补充排序时所有 episode id 必须属于当前 show 的强校验
- 对照真实表结构，继续验证创建、更新、删除、状态、排序全链路
- 收口字段校验、表单回填、错误提示

### 2.2 Shorts Episode
- 补充 `episodeId -> show_id` 一致性校验
- 补充排序时所有 episode id 必须属于当前 show 的强校验
- 对照真实表结构，继续验证创建、更新、删除、状态、排序全链路
- 解除对 TV Show Episode 类型/页面的过度复用，按真实 shorts episode 语义收口

## 3. Producer 财务模块收口

### 3.1 Rent Transaction
- 对照真实 `tbl_rent_transaction` 结构继续适配查询
- 验证摘要统计、列表筛选、内容关联、状态显示是否正确
- 修正页面字段含义与数据库真实字段不一致的问题
- 明确是否需要 `payment_type` 语义，若真实库不存在则调整页面文案/展示逻辑

### 3.2 Withdrawal
- 对照真实 `tbl_withdrawal_request` 结构核对字段
- 验证提现申请创建、列表、状态展示、余额联动
- 校验最小提现额度、钱包余额、错误提示是否与 Laravel 语义一致

## 4. Admin 内容管理线补齐

### 4.1 Admin 内容入口补齐
- 在 `admin/dashboard` 补齐内容管理导航入口
- 明确 admin 与 producer 在内容管理上的职责边界

### 4.2 Admin Video / TV Show / Shorts / Episode
- 对照 Laravel 原后台补齐 admin 内容管理路由、服务、仓储、页面
- 验证 admin 端的创建、编辑、删除、状态、发布、排序等能力
- 确保 admin 端不是仅有配置页，而具备完整运营后台能力

## 5. 数据库真实结构适配专项
- 系统梳理当前 Koa2 假设字段与真实 MySQL 表结构差异
- 优先覆盖以下表：
  - `tbl_video`
  - `tbl_tv_show`
  - `tbl_shorts`
  - `tbl_tv_show_video`
  - `tbl_shorts_episode`
  - `tbl_rent_transaction`
  - `tbl_withdrawal_request`
  - `tbl_type`
  - `tbl_channel`
- 减少“页面可进但查询报字段不存在”的问题
- 将共享类型定义从“理想模型”调整为“真实库模型 + 显式兼容层”

## 6. 权限与业务边界审计
- 继续审计 producer 侧所有写操作是否都带有归属校验
- 审计 admin / producer 删除、发布、状态切换是否都符合 Laravel 语义
- 补齐 demo mode (`checkadmin`) 对关键操作的保护范围
- 梳理 show / episode / type / channel 之间的一致性校验

## 7. 页面与体验收口
- 统一 dashboard、列表页、详情页、编辑页导航结构
- 优化缺配置、空数据、无权限时的提示文案
- 将当前“开发态报错”收敛为可读的后台提示
- 复查列表页内嵌表单与独立编辑入口的合理性

## 8. 与 Laravel 原语义逐项对照补齐
- 冻结对照基线：`routes/admin.php`、`routes/producer.php` + 对应 Controller
- 对每个模块统一按以下维度核对并落文档：
  - 路由覆盖
  - 校验规则
  - 写操作链路（增改删/状态/发布/排序）
  - 文件字段链路（上传/回填/旧文件清理）
  - 搜索/自动填充
  - 权限边界（admin/producer/checkadmin）
- 输出并持续维护“已完成 / 半完成 / 未完成 / 有意偏离”清单
- 明确保留增强项（如 `shorts/releases`）并在清单中标注“有意偏离 + 治理策略”
- 每轮迭代同步：本轮已补齐项 / 剩余缺口 / 验收结果

## 9. 最终目标定义

### 9.1 里程碑 M1：对照清单可执行化（P0）
- 完成对照清单模板统一、状态统一、偏离治理区块
- 产出 Top 缺口优先级，作为后续实施队列

### 9.2 里程碑 M2：Producer 主链可用闭环（P1）
- Video / TV Show / Shorts / Episode / Rent / Withdrawal 主链完成语义收口
- 重点完成校验分支、归属校验、状态/发布/排序、核心页面语义

### 9.3 里程碑 M3：Admin 内容管理线闭环（P2）
- Admin Video / TV Show / Shorts / Episode 补齐 add/edit/details/delete/release/sort
- 确保 admin 端具备完整运营动作，不再停留在列表+toggle

### 9.4 里程碑 M4：细粒度等价与偏离治理（P3）
- 文件字段链路（上传/存储/旧文件清理）持续补齐
- 保留增强能力但持续标注“有意偏离”，并记录回滚条件
