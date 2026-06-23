# Flutter Template

Flutter Template 是一个用于快速启动 Flutter 应用开发的项目模板。项目已经预置路由、网络请求、Redux 状态管理、主题配置、响应式适配、JSON 序列化、本地存储、设备信息、应用信息等常见基础能力。

本项目已经在 Windows 环境下通过 Android 模拟器运行验证。由于 Flutter、Dart、Android Gradle Plugin、Kotlin、Gradle、Android SDK 之间存在较强的版本耦合，请不要随意升级或降级关键依赖版本。版本不匹配可能导致 `flutter run` 阶段出现 Gradle 编译失败、插件接口缺失、Kotlin 编译失败、JDK class file 不兼容、下载超时等问题。

## 协作与变更规则

- 修改代码前优先使用 CodeGraph 分析相关调用链，不先做全仓库 grep。
- 修改代码前需要先分析影响范围。
- 修改完成后需要运行测试。
- 每次修改、编辑、新增或删除时，需要同步更新 `README.md`。

## 平台支持

- Android
- iOS
- Web
- Windows
- macOS
- Linux

## iOS 自用真机安装配置

当前 iOS 工程已经按自用真机安装做了基础配置：

- Bundle ID：`com.oolaf.flutted`
- iPhone 显示名称：`Oolaf`
- iOS 最低版本：`13.0`
- CocoaPods 入口：`ios/Podfile`

在 Mac mini 上安装到自己的 iPhone 时，仍需要在 Xcode 中完成本机相关配置：

1. 打开 `ios/Runner.xcworkspace`。
2. 在 `Runner > Signing & Capabilities` 中选择自己的 Apple ID Team。
3. 连接 iPhone，开启开发者模式并信任 Mac。
4. 使用 Xcode 选择真机后直接 Run。

不上 TestFlight 和 App Store 时，不需要配置 App Store Connect、上架证书或审核信息。

## 当前验证环境

以下版本是本项目当前能够在 Android 模拟器上运行的参考环境。

| 项目 | 版本或路径 |
| --- | --- |
| 操作系统 | Windows |
| Flutter SDK | 3.41.9 stable |
| Dart SDK | Flutter 3.41.9 自带 Dart 版本 |
| 项目 Dart SDK 约束 | `>=3.0.5 <4.0.0` |
| Flutter SDK 路径示例 | `D:\flutter_windows_3.41.9-stable\flutter` |
| Git 路径示例 | `D:\Git\cmd\git.exe` |
| Android SDK 路径示例 | `D:\Android-SDK` |
| Android Studio JBR | `D:\Android Studio\jbr` |
| Android Gradle Plugin | `8.6.0` |
| Kotlin Gradle Plugin | `2.1.0` |
| Gradle Wrapper | `8.11.1` |
| Gradle 分发地址 | `https://mirrors.cloud.tencent.com/gradle/gradle-8.11.1-all.zip` |
| Flutter Android 引擎制品镜像 | `https://storage.flutter-io.cn/download.flutter.io` |
| Maven 镜像 | 阿里云 Maven 仓库 |

## 关键版本说明

本项目的 Android 构建链路已经针对较新的 Flutter SDK 做过兼容调整，关键版本如下。

### Gradle Wrapper

文件位置：

```text
android/gradle/wrapper/gradle-wrapper.properties
```

当前配置：

```properties
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-8.11.1-all.zip
```

使用 Gradle 8.11.1 的原因：

- 旧版本 Gradle 与 JDK 21 不兼容时，可能出现 `Unsupported class file major version 65`。
- 使用腾讯云 Gradle 镜像可以避免从 `services.gradle.org` 下载超时。

### Android Gradle Plugin 和 Kotlin

文件位置：

```text
android/settings.gradle
android/build.gradle
```

当前版本：

```gradle
id "com.android.application" version "8.6.0" apply false
id "org.jetbrains.kotlin.android" version "2.1.0" apply false
```

```gradle
ext.kotlin_version = '2.1.0'
classpath 'com.android.tools.build:gradle:8.6.0'
```

这些版本不能随意改动。过低的 AGP 或 Kotlin 版本可能导致 Flutter 提示即将停止支持，也可能在新版本 Flutter、Gradle、JDK 下出现构建错误。

### Flutter Gradle 插件声明方式

新版本 Flutter 不再支持旧的 `apply from` 方式加载 Flutter Gradle 插件。本项目已经迁移为 `plugins` 块声明方式。

`android/settings.gradle` 中使用：

```gradle
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.6.0" apply false
    id "org.jetbrains.kotlin.android" version "2.1.0" apply false
}
```

`android/app/build.gradle` 中使用：

```gradle
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
    id 'dev.flutter.flutter-gradle-plugin'
}
```

如果改回旧写法，可能出现以下错误：

```text
You are applying Flutter's app_plugin_loader Gradle plugin imperatively using the apply script method, which is not possible anymore.
```

## 关键 Flutter 依赖版本

以下依赖与当前 Flutter SDK 兼容性关系较强，不建议随意降级。

```yaml
dependencies:
  path_provider: ^2.1.5
  flutter_screenutil: ^5.9.3
  shared_preferences: ^2.5.5
  device_info_plus: ^11.5.0
  package_info_plus: ^8.3.0
```

### path_provider

`path_provider` 已升级到 `^2.1.5`。旧版本可能间接锁定到 `path_provider_android 2.0.27`，该版本仍引用 Flutter v1 embedding 的 `PluginRegistry.Registrar`，在新版本 Flutter 中会编译失败。

典型错误：

```text
cannot find symbol
PluginRegistry.Registrar
```

解决方式是升级 `path_provider`，并重新执行：

```powershell
flutter clean
flutter pub get
```

### shared_preferences

`shared_preferences` 已升级到 `^2.5.5`，避免旧 Android 插件版本在新 Flutter 和新 Android 构建链路下出现兼容问题。

### device_info_plus 和 package_info_plus

当前配置：

```yaml
device_info_plus: ^11.5.0
package_info_plus: ^8.3.0
```

这两个插件包含 Android Kotlin 代码，和 Kotlin Gradle Plugin、Gradle 缓存关系较密切。Windows 下如果项目位于 `D:` 盘，而 Pub Cache 位于 `C:` 盘，Kotlin 增量编译可能出现跨盘符缓存路径错误。

本项目已在 `android/gradle.properties` 中关闭 Kotlin 增量编译：

```properties
kotlin.incremental=false
```

典型错误：

```text
this and base files have different roots
Could not close incremental caches
```

## 网络 timeout 处理

在国内网络环境下，Flutter Android 构建经常需要下载以下内容：

- Gradle 分发包
- Android Gradle Plugin
- Kotlin Gradle Plugin
- Maven 依赖
- Flutter Android debug 引擎包，例如 `x86_64_debug`、`arm64_v8a_debug`

如果默认访问 Google、Maven Central 或 Gradle 官方源，可能出现超时。

### Gradle 下载超时

典型错误：

```text
java.net.ConnectException: Connection timed out
```

本项目已经将 Gradle Wrapper 改为腾讯云镜像：

```properties
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-8.11.1-all.zip
```

## Oolaf 音频播放补充说明

`2026-06-23` 对 Oolaf 音频播放链路做了一次 iOS 真机兼容修复，重点是 `lib/utils/oolaf_audio_player.dart` 与 `lib/utils/oolaf_audio_cache_proxy.dart`。

- 点击音乐列表项后的调用链为 `lib/components/oolaf_music/music_list.dart -> lib/utils/oolaf_audio_player.dart`。
- iOS 下如果 `just_audio.setUrl()` 直连远端 FLAC 超时，不再继续把同一条 FLAC URL 交给本地 `localhost` HTTP 代理播放。
- 新逻辑会先把远端音频完整下载到应用缓存目录，再通过 `setFilePath()` 播放本地文件。
- 如果 iOS 首次装载音频仍然卡死，播放器会自动销毁旧的 `AudioPlayer` 实例并重建后重试一次，覆盖冷启动首播偶发失败场景。
- 这样可以规避 iOS 真机上远端 FLAC URL 长时间 loading、点击后一直转圈、最终播放失败的问题。

影响范围：

- iOS Oolaf 音乐播放失败回退路径。
- 音频缓存代理新增“下载到本地缓存文件”的复用能力。

平台说明：

- Android / macOS 仍保持原有缓存代理与直连回退逻辑。
- Web 不走这个本地缓存文件回退。

### Maven 依赖下载超时

本项目已经在 `android/build.gradle` 和 `android/settings.gradle` 中加入阿里云 Maven 镜像：

```gradle
maven { url 'https://maven.aliyun.com/repository/google' }
maven { url 'https://maven.aliyun.com/repository/central' }
maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
maven { url 'https://maven.aliyun.com/repository/public' }
```

### Flutter Android 引擎包下载超时

典型错误：

```text
Could not download x86_64_debug-1.0.0-xxxx.jar
Could not get resource 'https://storage.googleapis.com/download.flutter.io/...'
Read timed out
```

本项目已经加入 Flutter 国内 Maven 镜像：

```gradle
maven { url 'https://storage.flutter-io.cn/download.flutter.io' }
```

同时建议运行命令前设置环境变量：

```powershell
$env:PUB_HOSTED_URL="https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
flutter run
```

也可以一行执行：

```powershell
$env:PUB_HOSTED_URL="https://pub.flutter-io.cn"; $env:FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"; flutter run
```

## 环境变量建议

Windows 下建议确认以下环境变量或 PATH 配置。

### Flutter

Flutter SDK 的 `bin` 目录需要加入 PATH。

示例：

```text
D:\flutter_windows_3.41.9-stable\flutter\bin
```

验证命令：

```powershell
flutter --version
```

### Git

Flutter 依赖 Git。Git 的 `cmd` 目录需要加入 PATH。

示例：

```text
D:\Git\cmd
```

验证命令：

```powershell
git --version
```

如果 Flutter 提示找不到 Git，需要检查 PATH 中是否包含 Git，并确认 `C:\Windows\System32` 也在 PATH 中。

典型错误：

```text
Error: Unable to find git in your PATH.
```

### Android SDK

如果 Flutter 没有识别 Android SDK，可以手动指定：

```powershell
flutter config --android-sdk "D:\Android-SDK"
```

验证命令：

```powershell
flutter doctor -v
```

## 启动 Android 模拟器

查看设备：

```powershell
flutter devices
```

如果能看到 Android 模拟器，例如：

```text
sdk gphone64 x86 64
```

可以运行：

```powershell
flutter run
```

如果有多个设备，指定设备运行：

```powershell
flutter run -d emulator-5554
```

## 常用开发命令

安装依赖：

```powershell
flutter pub get
```

清理构建缓存：

```powershell
flutter clean
```

重新拉取依赖：

```powershell
flutter pub get
```

运行项目：

```powershell
flutter run
```

静态检查：

```powershell
flutter analyze
```

生成 JSON 序列化代码：

```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

构建 Android APK：

```powershell
flutter build apk
```

## 发布打包

如果需要让产物文件名自动带上版本号和时间，并在打包成功后自动执行一次版本自增，请使用仓库脚本，而不是直接执行裸 `flutter build`。

当前版本来源只使用：

- `pubspec.yaml` 的 `version`

### 产物命名规则

产物会输出到：

```text
dist/releases
```

命名格式：

```text
oolaf flutted <version> <yyyyMMdd HH>
```

示例：

```text
oolaf flutted 1.0.0 20260601 14.apk
oolaf flutted 1.0.0 20260601 14
```

其中：

- `apk` 会输出成单个 `.apk` 文件
- `windows` 会输出成同名目录，目录内是完整 Windows 发布文件
- `web` 会输出成同名目录，目录内是完整 Web 发布文件

### 发布命令

构建 Android APK 并在成功后自动升级到下一个 patch 版本：

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\release_build.ps1 -Platform apk
```

构建 Windows：

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\release_build.ps1 -Platform windows
```

构建 Web：

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\release_build.ps1 -Platform web
```

一次构建 `apk + windows + web`：

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\release_build.ps1 -Platform all
```

### 自动版本升级规则

如果当前版本是：

```text
1.0.0+1
```

那么脚本成功后会自动更新为：

```text
1.0.1+2
```

也就是：

- `pubspec.yaml` 的 `version` 从 `1.0.0+1` 变成 `1.0.1+2`

也可以指定升级策略：

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\release_build.ps1 -Platform all -Bump patch
powershell -ExecutionPolicy Bypass -File .\tool\release_build.ps1 -Platform all -Bump minor
powershell -ExecutionPolicy Bypass -File .\tool\release_build.ps1 -Platform all -Bump major
```

规则如下：

- `patch`: `1.2.3` -> `1.2.4`
- `minor`: `1.2.3` -> `1.3.0`
- `major`: `1.2.3` -> `2.0.0`

### 调试脚本时可用参数

只验证脚本流程，不执行版本升级：

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\release_build.ps1 -Platform apk -SkipVersionBump
```

如果你已经提前手动执行过 `flutter build`，只做产物复制和命名：

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\release_build.ps1 -Platform apk -SkipBuild
```

## flutter run 常见问题

### Gradle 锁被占用

错误示例：

```text
Timeout waiting to lock build logic queue
Lock file: android/.gradle/noVersion/buildLogic.lock
```

原因通常是上一次 Gradle 或 Java 构建进程未退出。

可以在 `android` 目录执行：

```powershell
$env:JAVA_HOME="D:\Android Studio\jbr"
$env:PATH="$env:JAVA_HOME\bin;$env:PATH"
.\gradlew --stop
```

然后重新执行：

```powershell
flutter run
```

### 修改 Gradle、Android 插件或依赖后仍然报旧错误

建议执行：

```powershell
flutter clean
flutter pub get
flutter run
```

必要时停止 Gradle daemon 后再试：

```powershell
.\gradlew --stop
```

### 初次构建很慢

第一次执行 `flutter run` 很慢是正常现象，尤其是在以下场景：

- 刚安装 Flutter SDK
- 刚安装 Android SDK
- 刚创建或首次打开模拟器
- 刚升级 Gradle、AGP、Kotlin
- 刚执行 `flutter clean`
- 需要下载 Flutter Android 引擎包
- 需要下载大量 Maven 依赖

只要不是长时间停在同一个 timeout 错误，首次构建可以等待较久。成功一次后，后续构建会明显变快。

## 项目结构

```text
lib/
├── main.dart              应用入口
├── app.config.dart        全局配置常量
├── layouts/               应用外壳、主题、Store 注入、路由初始化
├── router/                Fluro 路由定义、Handler 和配置
├── store/                 Redux 状态管理
├── pages/                 页面级组件
├── components/            可复用 UI 组件
├── api/                   API 请求封装
├── model/                 数据模型和 JSON 序列化
└── utils/                 工具类、DioClient、Cookie 管理等
```

## 组件示例与公共组件

首页首屏直接展示“基础示例”分组，当前主要用于按任务查找可复用组件和常见交互，不需要先从业务页兜进去。动感音频正在播放提示条固定展示在“基础示例”和“业务模块”之间，避免被业务模块展开状态影响，并与上下分组保持相同横向宽度。

基础示例按“什么时候该用这个组件”组织，而不是按组件名称堆叠：

- 搭页面骨架：页面导航、头部、底栏、tab、侧栏和基础数据流。
- 展示状态与内容：图片、图标、标签、流程状态、长文本、公告和动态数字。
- 收集输入：文本输入、搜索、提交按钮、开关、数量步进和固定长度密码输入。
- 让用户做选择：单选、多选、日期、地区、级联选择和列表顶部筛选。
- 弹出反馈：确认框、轻提示、菜单、动作面板、顶部/底部弹层。
- 处理列表手势：长列表索引、图片预览、滑动行操作和横向轮播。

相关 demo 页面统一放在：

```text
lib/pages/component_demo/
```

适合做这些事情：

- 组件回归验证
- 交互细节单测前的人眼验收
- 业务接入前先看组件最小行为

Auth 示例模块已接入 `/auth` route，当前作为账号能力入口页，包含启动鉴权、登录、注册、OTP、忘记密码、重置密码、修改密码、账号绑定/解绑、补全资料、权限申请说明、验证状态、MFA、会话过期、账号安全、登录设备管理、注销账号、条款隐私、第三方登录回调和异常状态等静态流程示例。Auth 页面只做本地表单校验、倒计时和状态演示，不接真实账号接口；业务登录页不要直接复用该示例模块。

虎扑登录页已独立放在 `lib/pages/hupu/hupu_login_page.dart`，路由为 `/hupu/login`。虎扑关注页的“立即登录”入口只跳转虎扑登录页，不再依赖 Auth 示例页。

虎扑“关注”页已接入关注流接口，默认展示未登录提示和“为你推荐”用户卡片，支持下拉刷新，推荐用户可进入用户详情，推荐帖子可进入帖子详情。

虎扑“体育”里的“中国篮球”和“国际足球”页已接入体育新闻流，tab 内展示置顶新闻、2 条热门资讯和普通新闻分页流，点击“查看更多”进入热门资讯详情页；详情页默认请求 hotList 第一页并支持上拉加载，列表项复用帖子详情跳转。“中国足球”和“英雄联盟”页分别接入 `csl`、`lol` 默认新闻流，新闻列表支持上拉分页且不展示置顶和热门资讯模块，其中“中国足球”顶部展示热门话题 tag。
- 桌面端和移动端交互差异排查

### route_page_header

目录：

```text
lib/components/route_page_header/
```

作用：

- 通用页面顶部 header
- 左侧返回按钮
- 中间标题
- 头像 + 标题 + 副标题组合
- follow / more / trailing 扩展区

项目中已经用于：

- 通用 `PageScaffold`
- Hupu 详情页和部分业务页
- `component_demo` 示例页

### route_bottom_nav_bar

目录：

```text
lib/components/route_bottom_nav_bar/
```

当前结构：

```text
lib/components/route_bottom_nav_bar/
├── index.dart
├── route_bottom_nav_bar_item.dart
├── route_bottom_nav_bar_item_state.dart
├── route_bottom_nav_bar_style.dart
└── route_bottom_nav_bar_tile.dart
```

这个组件最初来自 `hupu` 的底部导航实现，后来抽成公共组件。现在已经去掉业务命名，只保留通用展示、状态和交互钩子。

#### 当前保留的兼容能力

不改现有调用也能继续工作的基础能力：

- `items`
- `activeKey`
- `onTap`
- 中间主操作按钮 `isCenterAction`
- `activeIcon`
- 单个 item 的 `activeColor` / `inactiveColor`

#### 新增的通用扩展能力

- `onReselect`
  当前 tab 已经激活时再次点击的回调。
- `respectBottomSafeArea`
  控制底部安全区 inset 是否算进导航栏高度和 padding。
- `badgeText`
  数字提醒，例如未读数。
- `showDot`
  纯红点提醒，不展示数字。
- `enabled`
  允许临时禁用某个 tab，但不打乱布局。
- `onLongPress`
  只透出长按钩子，业务层自己决定是否弹 `bottom sheet` 或别的面板。
- `onDoubleTap`
  适合“回顶部”“重新刷新”“重新聚焦当前 tab”这类行为。
- `itemBuilder`
  对任意状态下的默认 item 渲染做外层包装或整体替换。
- `selectedBuilder`
  只对激活态做定制渲染，不影响普通态。
- `centerActionChild`
  中间按钮可以不再是固定加号，由业务传自定义内容。
- `semanticLabel`
  用于补充无障碍语义。

#### 样式系统

`RouteBottomNavBarStyle` 负责管理外观参数。当前可调项包括：

- 导航栏高度
- 内边距
- 背景色
- 顶部分割线颜色和宽度
- 激活 / 非激活 / 禁用颜色
- icon 大小
- 文案字号和字重
- 中间按钮尺寸与配色
- badge 配色
- 红点尺寸和偏移
- 动画开关、时长、曲线、激活缩放比例

#### Cupertino 化版本

当前不是单独维护两套组件，而是在同一个组件上提供两套风格参数：

- `const RouteBottomNavBarStyle()`
- `const RouteBottomNavBarStyle.cupertino()`

`cupertino()` 更偏 iOS 风格的默认高度、间距、颜色和中心按钮视觉，但仍然走同一套交互和同一套扩展点。

#### builder 能力说明

如果业务只是想加一个角标、额外文案、胶囊态背景，优先用 builder，而不是 fork 一个新底部导航组件。

`itemBuilder` 示例：

```dart
RouteBottomNavBarItem(
  key: 'mine',
  label: '我的',
  icon: Icons.person_outline,
  activeIcon: Icons.person,
  showDot: true,
  itemBuilder: (context, state, defaultChild) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        defaultChild,
        const SizedBox(height: 2),
        const Text('NEW'),
      ],
    );
  },
)
```

`selectedBuilder` 示例：

```dart
RouteBottomNavBarItem(
  key: 'explore',
  label: '探索',
  icon: Icons.explore_outlined,
  activeIcon: Icons.explore,
  selectedBuilder: (context, state, defaultChild) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x141F2329),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: defaultChild,
      ),
    );
  },
)
```

#### 组件边界

为了保持公共性，下面这些内容不应该内置进 `route_bottom_nav_bar`：

- 业务 `bottom sheet`
- 发帖逻辑
- 登录校验
- 页面切换实现
- 埋点
- 业务跳转

组件只负责：

- 渲染
- 激活态表达
- 交互事件透出

业务层负责：

- 点击后做什么
- 长按后弹什么
- 双击后做什么
- 当前 activeKey 如何维护

#### 项目内使用点

- 虎扑主页面：
  `lib/pages/hupu/index.dart`
- 组件示例页：
  `lib/pages/component_demo/route_bottom_nav_bar_demo_page.dart`

### gallery_preview

目录：

```text
lib/components/gallery_preview/
```

当前公共 API：

- `GalleryPreviewImage`
- `openGalleryPreview(...)`
- `wrapWithGalleryPreviewScrollBehavior(...)`

用途：

- 点击缩略图进入全屏图集
- 左右切图
- 双击放大
- 下滑关闭
- 兼容长图阅读
- 桌面端鼠标 / 触控板 / 触笔手势兼容

当前实现拆分为：

```text
lib/components/gallery_preview/
├── index.dart
├── gallery_preview_image.dart
├── gallery_preview_navigation.dart
├── gallery_preview_page.dart
└── gallery_zoomable_image.dart
```

交互细节：

- 普通图默认居中展示
- 真正长图在未缩放时优先按阅读模式处理
- 缩放后切回 `InteractiveViewer` 做平移
- 顶部关闭按钮和底部提示浮层由预览页内部维护

为了兼容旧引用，`lib/pages/video_tabs/short_video_gallery_preview.dart` 仍保留一层 deprecated 转发；新代码应直接引用 `lib/components/gallery_preview/`。

## 核心能力

### 状态管理

项目使用 `redux` 和 `flutter_redux` 做全局状态管理。根状态是强类型的 `AppState`，当前主要包含：

- `todos`
- `userInfo`
- `oolafMusic`
- `shortVideo`

状态更新通过 `copyWith` 和分领域 reducer 完成，例如：

- `todoListReducer`
- `userReducer`
- `oolafMusicReducer`
- `shortVideoReducer`

这部分已经不是早期那种 `Map<String, dynamic>` 挂全局数据的模式。

### 网络请求

项目封装了基于 Dio 的 `DioClient`，包含以下能力：

- 请求错误分类处理
- 请求和响应日志
- 请求取消
- 动态请求头
- 响应数据拦截处理
- 文件上传和下载
- 非 Web 平台 Cookie 持久化
- 401 token 刷新逻辑
- 请求锁和并发控制

### 路由

项目使用 Fluro 管理路由。路由路径集中定义在 `Routes` 中，并通过 `configureRoutes` 注册。不同页面通过独立 `Handler` 处理，支持查询参数、自定义转场动画和函数式弹窗处理。

### 主题和适配

项目使用 `AppTheme` 定义全局浅色主题，默认字体为 `NotoSansSC`。界面尺寸和字体大小使用 `flutter_screenutil` 做响应式适配。

## 配置文件

全局配置位于：

```text
lib/app.config.dart
```

示例：

```dart
class AppConfig {
  static const appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );
  static const customBaseUrl = String.fromEnvironment('BASE_URL');
  static const developmentBaseUrl = String.fromEnvironment(
    'DEV_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
  static const testBaseUrl = String.fromEnvironment('TEST_BASE_URL');
  static const productionBaseUrl = String.fromEnvironment(
    'PROD_BASE_URL',
    defaultValue: 'https://aphelios-api.oolaf.top',
  );
}
```

### API 环境变量

项目不在代码中固定线上 API 域名，通过 `--dart-define` 注入环境配置。

开发环境默认使用 Android 模拟器访问宿主机的地址：

```powershell
flutter run
```

等价于：

```powershell
flutter run --dart-define=APP_ENV=development --dart-define=DEV_BASE_URL=http://10.0.2.2:3000
```

测试环境：

```powershell
flutter run --dart-define=APP_ENV=test --dart-define=TEST_BASE_URL=https://test-api.example.com
```

生产环境：

```powershell
flutter run --dart-define=APP_ENV=production
```

生产环境也可以覆盖默认 API 地址：

```powershell
flutter run --dart-define=APP_ENV=production --dart-define=PROD_BASE_URL=https://api.example.com
```

临时覆盖任意环境的 API 地址：

```powershell
flutter run --dart-define=BASE_URL=https://mock-api.example.com
```

### Web 构建环境变量

Web 打包时同样通过 `--dart-define` 注入环境配置。生产环境构建：

```powershell
flutter build web --release --dart-define=APP_ENV=production
```

Web 平台如果需要通过代理服务转发接口请求，需要同时打开代理开关并传入代理地址。代理只在 Web 生效：

```powershell
flutter build web --release --dart-define=APP_ENV=production --dart-define=PROXY=true --dart-define=PROXY_BASE_URL=https://proxy.example.com
```

本地 Web 调试也可以带同样的代理参数运行：

```powershell
flutter run -d chrome --dart-define=PROXY=true --dart-define=PROXY_BASE_URL=http://101.200.123.220:9212/ --dart-define=PROXY_TOKEN=oolaf-oolaf-oolaf-oolaf
```

如果需要模拟子目录部署路径，可以同时加上 Web renderer 启动参数和页面路径调试，但多数接口、图片、音频代理问题只需要上面的 `flutter run -d chrome` 命令即可复现。

开启代理后，Web 端的接口请求、`CustomNetworkImage` 远端图片请求，以及 Oolaf 音乐远端音频播放请求都会改写到代理服务，路径格式为：

```text
{PROXY_BASE_URL}/proxy/{method}/{targetUrl}
```

Oolaf 自有音乐 CDN 不走 Web 代理，会保持直连。默认跳过的域名来自：

```text
OOLAF_MUSIC_CDN_BASE_URL=https://s1.oolaf.top
```

常见图片资源也不走 Web 代理，会按 URL path 扩展名直连，例如 `.png`、`.jpg`、`.jpeg`、`.webp`、`.gif`、`.svg`、`.avif`、`.apng`、`.bmp`、`.ico`。带查询参数的图片地址同样会按 path 判断，例如：

```text
https://i5.hoopchina.com.cn/news-editor/example.png?x-oss-process=image/resize,w_250/format,webp
```

代理服务需要 token 时，继续传入 `PROXY_TOKEN`。应用会把该值放到请求头 `x-proxy-token`：

```powershell
flutter build web --release --dart-define=APP_ENV=production --dart-define=PROXY=true --dart-define=PROXY_BASE_URL=https://proxy.example.com --dart-define=PROXY_TOKEN=your-proxy-token
```

当前也兼容旧参数名：`--dart-define=proxy=true`、`--dart-define=url=https://proxy.example.com`、`--dart-define=proxyToken=your-proxy-token`。新命令优先使用 `PROXY`、`PROXY_BASE_URL`、`PROXY_TOKEN`。

生产环境并覆盖默认 API 地址：

```powershell
flutter build web --release --dart-define=APP_ENV=production --dart-define=PROD_BASE_URL=https://api.example.com
```

测试环境构建：

```powershell
flutter build web --release --dart-define=APP_ENV=test --dart-define=TEST_BASE_URL=https://test-api.example.com
```

临时指定任意 API 地址：

```powershell
flutter build web --release --dart-define=BASE_URL=https://mock-api.example.com
```

### GitHub Actions 自动发布

仓库包含两个 GitHub Actions 工作流。

Web Pages 发布：

```text
.github/workflows/flutter-web-publish.yml
```

该工作流只会在 `main-v2` 分支收到 push 且本次提交包含 `.run-release` 文件改动时自动执行，也可以在 GitHub Actions 页面手动触发。它会执行带 Pages 子路径和 Web 代理参数的 Web 构建，并将产物发布到：

```text
dirkhe1051931999/dirkhe1051931999.github.io/flutter-template
```

Release 打包发布：

```text
.github/workflows/flutter-release.yml
```

该工作流只会在 `main-v2` 分支收到 push 且本次提交包含 `.run-release` 文件改动时自动执行，也可以在 GitHub Actions 页面手动触发。普通代码提交不会触发 Release 打包。

需要触发自动发布时，修改 `.run-release` 的内容并提交，例如写入版本号、时间或发布说明：

```bash
echo "release 2026-06-23 15:30" > .run-release
git add .run-release
git commit -m "chore: trigger release build"
git push
```

自动发布流程：

- 执行 `flutter pub get`
- 执行 `flutter build apk`
- 执行 `flutter build web`
- 在 Windows runner 执行 `flutter build windows`
- 自动计算下一个 `vX.Y.Z` tag
- 推送 tag 到远端
- 创建 GitHub Release
- 上传 APK、Web zip 包和 Windows zip 包

tag 自增规则会优先读取仓库里最新的 `vX.Y.Z` tag，并将 patch 版本加一。例如最新 tag 是 `v1.0.3`，下一次 `.run-release` 触发的 `main-v2` 提交成功构建后会发布 `v1.0.4`。如果仓库还没有符合规则的 tag，则从 `pubspec.yaml` 的 `version` 起步。

该工作流会分别在 Ubuntu runner 打 APK/Web 包、在 Windows runner 打 Windows 桌面包，不带 `--dart-define`、`--base-href` 或其他构建参数。

GitHub Actions 的海外 runner 访问腾讯云 Gradle 镜像可能出现网络问题；同时仓库本地开发配置中的 `127.0.0.1:7890` Gradle 代理在 runner 上不可用，会导致 `java.net.ConnectException: Connection refused`。Release 工作流会在构建 APK 前临时移除 `android/gradle.properties` 里的 Gradle 代理配置，把 Gradle JVM heap 调整为 `-Xmx4096M`，并把 `android/gradle/wrapper/gradle-wrapper.properties` 中的 Gradle 分发地址切换为 `https://services.gradle.org/distributions/gradle-8.11.1-all.zip`，这些修改只发生在 CI 工作区，不会提交回仓库。

## 注意事项

- 不要随意升级或降级 Flutter、Gradle、AGP、Kotlin 和 Android 插件依赖。
- 修改 `pubspec.yaml` 后需要执行 `flutter pub get`。
- 修改 Android Gradle 配置后建议执行 `flutter clean`。
- iOS/macOS 视频播放使用 `media_kit_video` 的默认 `libmpv` 输出配置，不要复用 Android 的 `gpu` 输出配置；远程视频会附带移动端 `User-Agent`、`Accept-Language` 和 `Referer` 请求头，便于兼容虎扑、凤凰短视频等媒体源。
- iOS 动感音频播放优先直连远程 HTTPS 音频，并附带移动端浏览器请求头；本地缓存代理只作为失败后的兜底，避免 iPhone 因 localhost 代理链路异常导致无声或一直缓冲。
- 排查 iOS 动感音频卡加载时，查看 `flutter run` 控制台里的 `audio setUrl start/ready` 日志：`source=ios-direct` 表示直连远程音频，`source=ios-localhost-proxy` 表示已经回退到本地缓存代理；本地代理还会输出 `audio cache proxy request/upstream` 和上游 HTTP 状态码。
- 动感音频没有当前播放内容且队列为空时，应立即清理播放持久化数据，不要启动延迟保存 timer，避免页面销毁或测试结束后仍有挂起任务。
- 如果遇到下载超时，优先检查镜像配置和 `FLUTTER_STORAGE_BASE_URL`。
- 如果遇到 Gradle 锁占用，先停止 Gradle daemon。
- Web 平台下 Cookie 持久化逻辑需要单独适配。
- 修改 `lib/model/` 下带 JSON 序列化注解的模型后，需要重新执行 `build_runner`。
