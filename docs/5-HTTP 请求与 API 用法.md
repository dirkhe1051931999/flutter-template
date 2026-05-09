# HTTP 请求与 API 用法

## 一、分层关系（先记住）

你项目里的网络调用链是：

- `utils/request.dart`：网络基础设施层（DioClient + 拦截器）
- `api/*.dart`：业务 API 层（路径、参数、返回值组织）
- `model/*.dart`：数据模型（`fromJson/toJson`）
- `pages/*.dart`：页面层（调用 API + 渲染）

## 二、统一请求实例

文件：`lib/utils/request.dart`

```dart
final httpClient = DioClient(baseUrl: AppConfig.baseUrl);
```

这代表：

- 业务 API 不要自己 new `Dio()`
- 全部走统一实例，才能共享拦截器/日志/token/cookie

## 三、DioClient 已有能力

`DioClient` 当前包含：

- 请求前 token 注入（`onRequest`）
- 异常处理与日志（`onError` + `_logDioError`）
- 401 自动 refresh + 重试
- 非 Web 平台 cookie 持久化
- 常见方法封装：`get/post/put/delete/upload/download`

## 四、API 层怎么写

示例：`lib/api/banner.dart`

```dart
dynamic commonGetRequest() async {
  var response = await httpClient.get('/guestbook/list', queryParameters: {
    'page': 1,
    'pageSize': 10,
    'sort': 'earliest',
  });
  return response.data;
}
```

你项目中还有更好的示例：`lib/api/news/index.dart`，它会把响应转成 model（如 `ListModel`）。

## 五、页面如何消费 API

示例：`lib/pages/request/index.dart`

1. 点击按钮触发请求
2. 调用 `commonGetRequest()`
3. 用 `IBanner.fromJson(result)` 转 model
4. `setState` 更新 `banner` 和列表长度
5. `ListView.builder` 渲染

## 六、推荐的调用模板（建议你后续逐步统一）

```dart
Future<IBanner?> getBannerList({required int page}) async {
  final response = await httpClient.get('/guestbook/list', queryParameters: {
    'page': page,
    'pageSize': 10,
    'sort': 'earliest',
  });

  if (response.statusCode == 200 && response.data != null) {
    return IBanner.fromJson(response.data);
  }
  return null;
}
```

优势：

- 返回类型清晰
- 页面层不处理裸 `dynamic`
- 更易维护与补全

## 七、常见问题

### 1) 为什么请求失败会重试？

因为 `request.dart` 的 `onError` 里对 401 做了 refresh + `_retry`。

### 2) 为什么 token 没带上？

检查：

- 构造 `DioClient` 时是否提供 `getAccessToken`
- token 返回是否为空

### 3) 为什么 cookie 没生效？

检查：

- 是否 Web 平台（Web 默认不走该 cookie 持久化逻辑）
- `MyAppCookieManager.create(baseUrl)` 是否成功
