# Redux 状态管理用法

这份文档基于你当前项目的实现，讲「怎么读、怎么用、怎么扩展」。

## 一、当前实现总览

关键文件：

- `lib/store/action.dart`
- `lib/store/index.dart`
- `lib/store/todolist/type.dart`
- `lib/store/todolist/reducer.dart`
- `lib/store/user/type.dart`
- `lib/store/user/reducer.dart`
- `lib/bootstrap.dart`

你当前已经是强类型 action 边界：

- 所有 action 继承 `AppAction`
- reducer 接收 `AppAction`，不再使用 `dynamic`

## 二、最重要的 4 个概念

### 1) `AppState`

在 `lib/store/index.dart`：

- 定义全局状态结构（`todos`、`userInfo`）
- 提供 `copyWith()` 实现不可变更新
- `AppState.initial()` 提供初始状态

### 2) `AppAction`

在 `lib/store/action.dart`：

- 所有业务 action 的基类
- 统一 reducer 的类型边界

### 3) 分域 reducer

- `todoListReducer` 处理 todo 相关 action
- `userReducer` 处理 user 相关 action
- 在 `appReducer` 中串起来

### 4) Store 创建

在 `lib/bootstrap.dart` 的 `createAppStore()`：

- 外部接收 Redux 的 action
- 通过 `action is! AppAction` 做类型守卫
- 再调用你的强类型 `appReducer`

## 三、页面里怎么用 Redux

### 读取状态：`StoreConnector`

例子：`lib/components/todolist_detail/list.dart`

```dart
StoreConnector<AppState, List<String>>(
  converter: (store) => store.state.todos,
  builder: (context, todos) {
    ...
  },
)
```

### 派发 action：`store.dispatch(...)`

例子：`lib/components/todolist_detail/add.dart`

```dart
store.dispatch(AddTodoAction(controller!.text));
```

例子：`lib/pages/profile/index.dart`

```dart
store.dispatch(UpdateUserInfoAction(age: age));
```

## 四、todolist 的完整数据流

1. 用户点击 Add
2. `AddWidget` 调用 `dispatch(AddTodoAction(name))`
3. `todoListReducer` 命中 action 类型
4. 返回新 `AppState`：`state.copyWith(todos: [...])`
5. `StoreConnector` 监听到状态变化并重建 UI

## 五、如何新增一个 Redux 字段（模板）

假设新增 `themeMode`：

1. 在 `AppState` 增加字段与 `copyWith` 参数
2. 在 `AppState.initial()` 初始化默认值
3. 新建 action（继承 `AppAction`）
4. 在对应 reducer 里处理这个 action
5. 页面 `StoreConnector` 读取并 `dispatch`

## 六、排错速查

### 问题 1：dispatch 了但 UI 不刷新

排查：

- reducer 是否真的返回了「新对象」
- `StoreConnector.converter` 是否取到了正确字段
- 是否在错误的 `BuildContext` 里取 store

### 问题 2：action 不生效

排查：

- action 是否继承 `AppAction`
- reducer 是否写了该 action 分支
- `createAppStore()` 是否使用了你的 `appReducer`

### 问题 3：字段更新错乱

排查：

- `copyWith` 是否漏传字段
- 是否在 reducer 中写错目标字段
