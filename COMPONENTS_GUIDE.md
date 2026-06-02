# Components Guide

这个文档放在仓库根目录，目的不是替代 `README.md`，而是回答两个实际问题：

1. 单个项目开发时，某个页面应该优先用哪个组件
2. 多个项目共用时，哪些组件适合直接复用，哪些只适合参考实现

---

## 先看结论

如果你在做一个项目，优先按“场景”选组件。

- 表单输入：先看 `app_field`、`app_search`、`app_stepper`、`app_switch`
- 选择类交互：先看 `app_checkbox`、`app_radio`、`app_picker`、`app_date_picker`、`app_calendar`、`area_pick`
- 操作反馈：先看 `app_toast`、`app_dialog`、`app_action_sheet`、`app_sheet`
- 展示类内容：先看 `app_tag`、`app_notice_bar`、`app_text_ellipsis`、`app_rolling_text`
- 列表/导航：先看 `app_swipe`、`app_swipe_cell`、`app_index_bar`、`app_sidebar`
- 页面结构：先看 `route_page_header`、`route_bottom_nav_bar`
- 媒体/资源：先看 `network_img`、`gallery_preview`、`app_asset_icon`

如果你在做多个项目，先按“复用层级”判断。

- 可以直接复用到别的项目：`app_*`、`route_*`、`gallery_preview`、`network_img`
- 可以作为业务模板参考，但不建议原样搬走：`short_video`、`weather`、`search_view`、`todolist_detail`
- 明显带业务语义，复用前要再拆：`oolaf_*`、`article`、`comment`

---

## 怎么判断该用哪个组件

### 1. 先判断你要解决的是“业务”还是“交互”

如果你只是要一个稳定交互，不要自己重写，优先找 `lib/components/`。

典型例子：

- 只是要一个输入框：用 `app_field`
- 只是要搜索框：用 `app_search`
- 只是要弹出确认框：用 `app_dialog`
- 只是要底部操作菜单：用 `app_action_sheet`
- 只是要左右滑动 Banner：用 `app_swipe`

如果你要的是完整业务流，不要直接把 `pages/` 下整页复制过去，先拆出可复用 UI。

---

### 2. 单项目判断标准

单项目里，优先考虑“开发效率”和“风格统一”。

可以直接用现成组件的信号：

- 页面只是缺一个常见交互控件
- 样式要保持当前仓库的 iOS / Cupertino 风格
- 交互和 Vant 类似，已有现成实现
- 你不希望重复处理边界状态，比如清空、禁用、校验、展开收起、联动

应该新增组件而不是硬塞进现有组件的信号：

- 需求和现有组件语义不同
- 新增参数会让组件变成“万能组件”
- 只有一个页面能用到，而且高度业务化
- 需要绑定接口、Redux、路由或埋点

一句话判断：

- 只解决 UI/交互问题，放 `components`
- 带业务流程和状态编排，放 `pages`

---

### 3. 多项目判断标准

多项目里，优先考虑“边界清晰”和“迁移成本”。

适合跨项目复用的组件，通常满足这些条件：

- 不依赖具体业务页面
- 不依赖具体 API
- 不依赖具体 Redux store 结构
- 参数语义稳定
- 视觉风格统一且可配置

不适合直接跨项目复用的组件，通常有这些问题：

- 组件里写死了业务文案
- 组件依赖某个 store 字段
- 组件内部直接跳路由
- 组件里混了接口请求、埋点、登录判断
- 参数非常少，但内部写死很多页面逻辑

如果准备做“多项目共用组件库”，优先从这些目录开始抽：

- `lib/components/app_*`
- `lib/components/route_*`
- `lib/components/gallery_preview`
- `lib/components/network_img`

---

## 组件索引

下面按“你现在要做什么”来找。

### 表单输入

#### `app_field`
路径：`lib/components/app_field`

适用场景：

- 普通输入框
- 数字输入
- 密码输入
- 多行文本
- 带校验、清空、错误提示、只读、链接态输入项

优先使用时机：

- 页面里原本是 `CupertinoTextField`，但还要加 label、错误态、clear、formatter
- 希望统一表单视觉和交互

不要用它的时候：

- 只是极简单行输入，没有 label、校验、状态需求
- 你做的是完全自定义排版的搜索头部

#### `app_search`
路径：`lib/components/app_search`

适用场景：

- 搜索页头部
- 列表筛选搜索
- 带取消按钮和清空按钮的搜索交互

#### `app_stepper`
路径：`lib/components/app_stepper`

适用场景：

- 数量加减
- 购物车数量
- 票数/库存/配额步进

#### `app_switch`
路径：`lib/components/app_switch`

适用场景：

- 设置开关
- 状态启停

#### `app_password_input`
路径：`lib/components/app_password_input`

适用场景：

- 支付密码
- 短验证码格子输入展示

---

### 选择与筛选

#### `app_checkbox`
路径：`lib/components/app_checkbox`

适用场景：

- 多选条件
- 协议勾选
- 多标签选择

#### `app_radio`
路径：`lib/components/app_radio`

适用场景：

- 单选项
- 规格选择
- 设置项互斥选择

#### `app_picker`
路径：`lib/components/app_picker`

适用场景：

- 单列/多列/级联选择

#### `app_date_picker`
路径：`lib/components/app_date_picker`

适用场景：

- 年月日时间选择

#### `app_calendar`
路径：`lib/components/app_calendar`

适用场景：

- 单选日期
- 多选日期
- 日期范围

#### `area_pick`
路径：`lib/components/area_pick`

适用场景：

- 省市区镇选择

#### `app_dropdown_menu`
路径：`lib/components/app_dropdown_menu`

适用场景：

- 顶部筛选栏
- 分类、排序、状态筛选

#### `app_index_bar`
路径：`lib/components/app_index_bar`

适用场景：

- 城市索引
- 品牌库
- 通讯录
- 长列表按字母跳转

#### `app_sidebar`
路径：`lib/components/app_sidebar`

适用场景：

- 左侧分类导航
- 设置页分栏
- 类目切换

---

### 展示与文本

#### `app_tag`
路径：`lib/components/app_tag`

适用场景：

- 状态标签
- 推荐标识
- 活动角标

#### `app_notice_bar`
路径：`lib/components/app_notice_bar`

适用场景：

- 公告栏
- 滚动播报
- 垂直资讯提示

#### `app_text_ellipsis`
路径：`lib/components/app_text_ellipsis`

适用场景：

- 摘要折叠
- 简介展开收起
- 路径/链接中间省略

#### `app_rolling_text`
路径：`lib/components/app_rolling_text`

适用场景：

- 数字翻牌
- 营销数据滚动
- 文本轮播数字效果

#### `app_steps`
路径：`lib/components/app_steps`

适用场景：

- 订单流程
- 审批流程
- onboarding 步骤

---

### 反馈与弹层

#### `app_toast`
路径：`lib/components/app_toast`

适用场景：

- 成功/失败提示
- loading 提示
- 轻量消息反馈

#### `app_dialog`
路径：`lib/components/app_dialog`

适用场景：

- 二次确认
- 风险提示
- 删除确认

#### `app_action_sheet`
路径：`lib/components/app_action_sheet`

适用场景：

- 底部操作面板
- 分享、删除、举报这类操作列表

#### `app_sheet`
路径：`lib/components/app_sheet`

适用场景：

- 自定义顶部/底部抽屉内容
- 复杂自定义面板

#### `app_popover`
路径：`lib/components/app_popover`

适用场景：

- 轻量浮层菜单
- 更多操作点按菜单

---

### 列表与滑动交互

#### `app_swipe`
路径：`lib/components/app_swipe`

适用场景：

- Banner
- 卡片轮播
- 活动位滑动

已处理：

- Windows 鼠标拖拽滑动兼容

#### `app_swipe_cell`
路径：`lib/components/app_swipe_cell`

适用场景：

- 列表项左滑删除
- 订单/消息的滑动操作

---

### 页面结构与导航

#### `route_page_header`
路径：`lib/components/route_page_header`

适用场景：

- 通用页面头部
- 带返回、标题、头像、副标题的顶部区域

#### `route_bottom_nav_bar`
路径：`lib/components/route_bottom_nav_bar`

适用场景：

- 底部主导航
- 中间主操作按钮的 Tab 导航

---

### 媒体与资源

#### `network_img`
路径：`lib/components/network_img`

适用场景：

- 网络图片加载
- 占位图
- 错误回退

#### `gallery_preview`
路径：`lib/components/gallery_preview`

适用场景：

- 图片全屏预览
- 长图查看
- 双击缩放

#### `app_asset_icon`
路径：`lib/components/app_asset_icon`

适用场景：

- 本地资源图标
- SVG 图标统一染色

---

## 单项目推荐用法

### 页面开发顺序

推荐顺序：

1. 先用现成组件把页面交互搭起来
2. 如果发现参数不够，再扩组件
3. 如果扩完已经明显带业务语义，就不要继续塞进公共组件

例子：

- 个人资料编辑：优先 `app_field`
- 搜索页：优先 `app_search + app_filter/dropdown`
- 地址选择：优先 `area_pick` 或 `app_picker`
- 商品详情 Banner：优先 `app_swipe`
- 列表删除：优先 `app_swipe_cell`

---

## 多项目推荐用法

### 分三层看

#### 第一层：可直接沉淀成通用库

- `app_button`
- `app_field`
- `app_search`
- `app_checkbox`
- `app_radio`
- `app_switch`
- `app_stepper`
- `app_dialog`
- `app_action_sheet`
- `app_sheet`
- `app_popover`
- `app_tag`
- `app_notice_bar`
- `app_text_ellipsis`
- `app_rolling_text`
- `app_swipe`
- `app_swipe_cell`
- `app_index_bar`
- `app_sidebar`
- `route_page_header`
- `route_bottom_nav_bar`
- `gallery_preview`
- `network_img`

#### 第二层：适合作为通用能力模板

- `app_calendar`
- `app_date_picker`
- `app_picker`
- `area_pick`

这些通常可以跨项目复用，但经常会遇到：

- 数据源不同
- 确认文案不同
- 业务字段映射不同

所以更适合作为“可二次封装基础件”。

#### 第三层：不建议直接抽成通用库

- `weather`
- `short_video`
- `search_view`
- `article`
- `comment`
- `oolaf_music`
- `oolaf_player`

这些更像业务模块或场景模块。

---

## 什么时候该新建组件

出现下面任意一种情况，就建议新建组件，而不是继续堆参数：

- 新需求只服务一个业务页面
- 现有组件名已经不能准确描述用途
- 需要引入接口请求或 store 依赖
- 需要嵌入页面跳转
- 组件内部要知道“用户”、“订单”、“商品”这类业务实体

---

## 什么时候该继续扩现有组件

满足这些条件时，优先扩已有组件：

- 新能力和组件原语义一致
- 只是新增一种展示形态
- 只是补桌面端/移动端兼容
- 只是新增可选参数
- 多个页面未来都可能复用

例子：

- `app_swipe` 补 Windows 鼠标拖拽：应该扩现有组件
- `app_text_ellipsis` 补收起能力：应该扩现有组件
- `profile` 弹窗输入改成 `app_field`：应该复用现有组件

---

## 快速定位清单

如果你要做：

- 资料编辑页：`app_field`
- 搜索头部：`app_search`
- 数量加减：`app_stepper`
- 开关设置：`app_switch`
- 单选/多选：`app_radio` / `app_checkbox`
- 城市/品牌索引：`app_index_bar`
- 左侧分类：`app_sidebar`
- 文本展开收起：`app_text_ellipsis`
- 状态标签：`app_tag`
- 公告滚动：`app_notice_bar`
- 操作菜单：`app_action_sheet`
- 确认弹窗：`app_dialog`
- 自定义抽屉：`app_sheet`
- 浮层菜单：`app_popover`
- 轮播 Banner：`app_swipe`
- 左滑操作列表：`app_swipe_cell`
- 图片预览：`gallery_preview`
- 页面头：`route_page_header`
- 底部导航：`route_bottom_nav_bar`

---

## 相关目录

- 组件目录：`lib/components/`
- 组件示例页：`lib/pages/component_demo/`
- 首页入口分组：`lib/pages/home/index.dart`
- 路由注册：`lib/router/handler.dart`、`lib/router/routes.dart`

---

## 建议的使用习惯

- 先去 `component_demo` 看现成例子，再决定接入方式
- 优先复用 `app_*` 组件，不要页面里直接散落原生输入/弹层实现
- 跨项目前，先检查组件是否依赖具体业务状态
- 如果只是这个仓库内部复用，可以接受轻量封装
- 如果准备抽成多项目组件库，必须继续去业务化
