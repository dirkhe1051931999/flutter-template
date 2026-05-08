# Flutter Template

Flutter Template 是一个用于快速启动 Flutter 应用开发的项目模板。项目已经预置路由、网络请求、Redux 状态管理、主题配置、响应式适配、JSON 序列化、本地存储、设备信息、应用信息等常见基础能力。

本项目已经在 Windows 环境下通过 Android 模拟器运行验证。由于 Flutter、Dart、Android Gradle Plugin、Kotlin、Gradle、Android SDK 之间存在较强的版本耦合，请不要随意升级或降级关键依赖版本。版本不匹配可能导致 `flutter run` 阶段出现 Gradle 编译失败、插件接口缺失、Kotlin 编译失败、JDK class file 不兼容、下载超时等问题。

## 平台支持

- Android
- iOS
- Web
- Windows
- macOS
- Linux

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
| Gradle Wrapper | `8.7` |
| Gradle 分发地址 | `https://mirrors.cloud.tencent.com/gradle/gradle-8.7-all.zip` |
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
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-8.7-all.zip
```

使用 Gradle 8.7 的原因：

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
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-8.7-all.zip
```

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

## 核心能力

### 状态管理

项目使用 `redux` 和 `flutter_redux` 做全局状态管理。根状态为 `AppState`，内部使用 `Map<String, dynamic>` 存储数据，并提供 `todos`、`userinfo` 等类型化访问方式。业务 reducer 按领域拆分，例如 `userReducer`、`todoListReducer`。

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

## 注意事项

- 不要随意升级或降级 Flutter、Gradle、AGP、Kotlin 和 Android 插件依赖。
- 修改 `pubspec.yaml` 后需要执行 `flutter pub get`。
- 修改 Android Gradle 配置后建议执行 `flutter clean`。
- 如果遇到下载超时，优先检查镜像配置和 `FLUTTER_STORAGE_BASE_URL`。
- 如果遇到 Gradle 锁占用，先停止 Gradle daemon。
- Web 平台下 Cookie 持久化逻辑需要单独适配。
- 修改 `lib/model/` 下带 JSON 序列化注解的模型后，需要重新执行 `build_runner`。
