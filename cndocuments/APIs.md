# EngageLab MA Flutter 插件 API 文档

## 目录
- [EngageLab MA Flutter 插件 API 文档](#engagelab-ma-flutter-插件-api-文档)
  - [目录](#目录)
  - [安装](#安装)
  - [初始化](#初始化)
  - [数据采集开关](#数据采集开关)
  - [用户属性管理](#用户属性管理)
    - [覆盖更新用户属性](#覆盖更新用户属性)
    - [累加更新用户属性](#累加更新用户属性)
    - [追加用户属性](#追加用户属性)
    - [操作 object_array 元素](#操作-object_array-元素)
    - [移除用户属性](#移除用户属性)
    - [删除用户属性](#删除用户属性)
  - [其他功能](#其他功能)
    - [设置用户身份](#设置用户身份)
    - [设置用户联系方式](#设置用户联系方式)
    - [获取 EUID](#获取-euid)
    - [获取 MA RID](#获取-ma-rid)
    - [获取 MA SDK 版本](#获取-ma-sdk-版本)
    - [设置第三方 Push 通道](#设置第三方-push-通道)
    - [设置上报间隔](#设置上报间隔)
    - [设置事件缓存上限](#设置事件缓存上限)
    - [设置会话超时时间](#设置会话超时时间)
    - [设置 UTM 属性](#设置-utm-属性)
    - [设置采集控制](#设置采集控制)
    - [自定义事件统计](#自定义事件统计)
  - [注意事项](#注意事项)

## 安装

在 `pubspec.yaml` 文件中添加依赖：

Android 和 iOS MA 5.5.0 均支持独立初始化；只有需要 Push 能力时才需要集成 [flutter_plugin_engagelab](https://pub.dev/packages/flutter_plugin_engagelab) 插件。

插件使用 Maven Central 的 Android MA 5.5.2 和 CocoaPods 的 iOS MTMA 5.5.1 正式依赖，连接生产环境；请配置对应项目的 AppKey。

```yaml
dependencies:
  flutter_plugin_engagelab_ma: ^1.0.5+552551
```

cd 到 ios 目录下：
运行 pod install

## 初始化

调用 `start` 时传入 MA AppKey。Android 和 iOS 5.5.0 均无需等待 Push 初始化完成。

`appKey` 为 MA 项目的 AppKey，与 Push AppKey 相互独立，必须为 24 位字母或数字。`userId`、`anonymousId`、`email`、`phone` 均为可选，字段长度与格式规则与原生一致，详见 [Android API 指南](../sdkdoc/android/API%20指南.md) 和 [iOS API 指南](../sdkdoc/ios/API%20指南.md)。

初始化沿用旧版异常规则：原生初始化失败返回结果 Map，仅桥接 `PlatformException` 补充文案后抛出。独立版增加必传 `appKey` 和结果字段 `euid/maRid/success`；不新增错误码映射或初始化排队层。重复初始化请等待前一次完成。

```dart
final result = await FlutterPluginEngagelabMa.start(
  appKey: "您的 MA AppKey",
  userId: "your_user_id",
  anonymousId: "anon_id",
  email: "user@example.com",
  phone: "+8613800138000",
);

// result 包含 code、message、euid、maRid、success
```

## 数据采集开关

每次初始化时按用户当前授权状态显式传入开关，避免初始化后才关闭导致提前采集：

```dart
final result = await FlutterPluginEngagelabMa.start(
  appKey: '您的 MA AppKey',
  dataCollectionEnabled: false,
);
```

初始化成功后，在业务授权变更回调中传入用户的实际选择：

```dart
Future<void> onConsentChanged(bool consentGranted) async {
  await FlutterPluginEngagelabMa.setDataCollectionEnabled(consentGranted);
}

final bool? enabled = await FlutterPluginEngagelabMa.isDataCollectionEnabled();
```

`start` 的 `dataCollectionEnabled` 为可选 `bool?`。不传或传 null 时沿用原生规则：Android
保留该 MA AppKey 最近保存的选择，首次默认开启；iOS 本轮初始化默认开启。为保证两端一致，
每次都应显式传入当前授权值。插件不另外缓存开关。

初始化成功后调用 `setDataCollectionEnabled(bool)`。返回的 `Future<void>` 完成仅表示
原生调用返回，不代表服务端状态同步或恢复采集已经完成。`isDataCollectionEnabled()`
返回原生本地状态，不发网络请求：Android 返回 bool（主进程首次 start 前为 true）；
iOS 未初始化就绪时返回 null，因此 Dart 返回类型为 `Future<bool?>`。iOS setter
将切换交给 SDK 线程执行，调用返回后立即查询仍可能读到切换前的本地状态。

关闭后停止新行为事件、用户属性、UTM 与非必要设备信息采集。原生 SDK 可能发送关闭前已产生的
最后一批数据及会话结束事件，随后清理采集缓存。初始化、EUID/MA RID、用户身份、联系方式和
Push 通道绑定仍可使用。重新开启后恢复采集并新建会话；Android 恢复期间属性调用可能返回 `-2`。

属性接口（包括 object_array）透传原生结果 Map，关闭时 `code` 为
`FlutterPluginEngagelabMa.codeCollectionDisabled`（`-8`）。既有 `eventRecord`、
`setUtmProperties` 的返回值只表示桥接调用完成，不代表采集或送达；关闭期间由原生 SDK 忽略。
`setCollectControl` 仍用于配置单个设备字段，总体采集请使用本节的新开关。

## 用户属性管理

### 覆盖更新用户属性

覆盖更新用户属性，如果属性已存在则会被覆盖。

- 参数传入 Map，key 必须是字符串。value 支持字符串、有限数字、布尔值、字符串数组、Map（`object`），以及 Map 数组（`object_array`）；不支持继续嵌套 `object`/`object_array`。
- 如果某个用户属性之前已经存在了，则这次会被覆盖掉；不存在，则会创建。如：用户会员等级。

```dart
final result = await FlutterPluginEngagelabMa.setUserProperties({
  'name': 'John Doe',
  'devices': <Map<String, Object?>>[
    {'device_id': 'device_1', 'enabled': true},
  ],
});

// 返回结果
{
    'code': 0,  // 0 表示成功，非 0 表示失败
    'message': ''
}
```

### 累加更新用户属性

- 给一个数值类型的用户属性增加一个数值，累加所有上报的数据，如累计消费金额。
- 只能对 Number 类型的用户属性调用这个接口，否则会被忽略, 如果这个用户属性之前不存在，则初始值当做 0 来处理。

```dart
final result = await FlutterPluginEngagelabMa.incrementUserProperties({
    'loginCount': 1,
    'points': 100
});

// 返回结果
{
    'code': 0, // 0 表示成功，非 0 表示失败
    'message': ''
}
```

### 追加用户属性

向数组类型的属性追加新的值。

- 向一个 数组 类型的属性添加一些值。
- 如前面所述，这个 数组 的元素必须是 String，否则，会忽略, 同时，如果要 add 的用户属性之前不存在，会初始化一个空的 数组。

```dart
final result = await FlutterPluginEngagelabMa.appendUserProperties(
          property: "interests", values: ['sports', 'music']);

// 返回结果
{
    'code': 0, // 0 表示成功，非 0 表示失败
    'message': ''
}
```

### 操作 object_array 元素

Android 和 iOS MA 5.5.0 及以上版本支持单独更新、追加和删除 `object_array` 元素。属性尚未创建时，需要先通过 `setUserProperties` 传入非空对象数组完成首次设置。原有 `appendUserProperties`、`removeUserProperties` 仍只用于字符串数组。

按唯一标识更新匹配对象的子字段。`identifierValue` 只支持字符串或有限数字；`values` 不能修改标识字段，其中 `null` 表示删除对应子字段。

```dart
final result = await FlutterPluginEngagelabMa.updateObjectArrayProperty(
  property: 'devices',
  identifierKey: 'device_id',
  identifierValue: 'device_1',
  values: <String, Object?>{
    'enabled': false,
    'legacy_name': null,
  },
);
```

追加一个非空对象，不影响已有元素：

```dart
final result = await FlutterPluginEngagelabMa.appendObjectArrayProperty(
  property: 'devices',
  object: <String, Object?>{
    'device_id': 'device_2',
    'year': 2026,
  },
);
```

按唯一标识删除整个对象元素：

```dart
final result = await FlutterPluginEngagelabMa.removeObjectArrayProperty(
  property: 'devices',
  identifierKey: 'device_id',
  identifierValue: 'device_2',
);
```

### 移除用户属性

- 从数组类型的属性中移除指定的值。
- values 参数为数组，内部元素必须是String类型。

```dart
 final result = await FlutterPluginEngagelabMa.removeUserProperties(
          property: "interests", values: ['sports']);

// 返回结果
{
    'code': 0,
    'message': '移除用户属性成功'
}
```

### 删除用户属性

- 删除某个用户属性的全部内容
- 如果这个用户属性之前不存在，则直接忽略

```dart
final result =
          await FlutterPluginEngagelabMa.deleteUserProperty("interests");

// 返回结果
{
    'code': 0,
    'message': '删除用户属性成功'
}
```

## 其他功能

### 设置用户身份

设置用户的身份信息。

```dart
final result = await FlutterPluginEngagelabMa.setUserIdentity(
    userId: "your_user_id",     // 可选
    anonymousId: "anon_id",     // 可选
    email: "user@example.com",  // 可选
    phone: "+8613800138000",    // 可选
);
```

### 设置用户联系方式

设置用户的联系方式。

目前支持 email、mobile_phone、landline_phone、whatsapp_phone 这 4 种联系方式设置。

```dart
final result = await FlutterPluginEngagelabMa.setUserContact({
    "email": "user@example.com",
    "mobile_phone": "1234567890"
});
```

### 获取 EUID

获取用户的 EUID。

SDK 尚未初始化成功或身份尚未生成时返回空字符串。

```dart
final euid = await FlutterPluginEngagelabMa.getEuid();
```

### 获取 MA RID

Android 和 iOS 5.5.0 及以上版本支持。

SDK 尚未初始化成功或身份尚未生成时返回空字符串。MA RID 与 Push RID 是两个不同的设备标识，不能混用。

```dart
final maRid = await FlutterPluginEngagelabMa.getMaRid();
```

### 获取 MA SDK 版本

Android MA 5.5.0 及以上版本支持，直接读取原生 `MTMAApi.SDK_VERSION_CODE` 与 `MTMAApi.SDK_VERSION_NAME`。两者是所依赖原生制品的编译期常量，因此可以在 `start` 之前调用，返回的也一定是应用实际编译进去的版本。

```dart
final version = await FlutterPluginEngagelabMa.getSdkVersion();
// version: {'versionCode': 552, 'versionName': '5.5.2'}
```

`versionCode` 为数字版本号，`versionName` 为字符串版本号。目前仅 Android 提供该接口，iOS 和其他平台抛出 `UnsupportedError`，与 `configDebugMode` 一致。

### 设置第三方 Push 通道

Android 和 iOS 5.5.0 及以上版本支持，用于设置第三方 Push 的 RID 或 Token。应用同时集成 EngageLab AppPush 和 MA 时，AppPush 注册成功取得 RID 后，MA SDK 会自动将 AppPush 的 AppKey/RID 与当前 MA 身份关联，无需调用此接口；其他第三方 Push 仍需主动设置。

`channelId` 必须大于 0；Flutter 在两端统一去除每个 RID/Token 的首尾空白，不修改传入列表。`values` 不能为空，且裁剪后的每个字符串都不能为空。RID 或 Token 发生变化后需要再次调用。

```dart
final result = await FlutterPluginEngagelabMa.setChannelValue(
  channelId: 1,
  values: ['third_party_push_token'],
);
```

### 设置上报间隔

设置数据上报的时间间隔（秒）。

- 设置上报数据间隔，不调用该接口时，默认为 10s 上报一次事件数据
- 上报间隔内存缓存，需要在应用程序每次生命周期中调用才会生效

```dart
await FlutterPluginEngagelabMa.setReportInterval(10);
```

### 设置事件缓存上限

设置本地缓存事件的最大数量。

- 设置事件缓存上限条数，默认 50 条，最高不能超过 500 条
- 当超出缓存数量时会上报报全部数据

```dart
await FlutterPluginEngagelabMa.setMaxEventCacheCount(50);
```

### 设置会话超时时间

设置会话超时时间（秒）。

- 设置会话超时时间，默认 1800 秒
- App 切换到后台，会话开始超时计时，超时时间内没有活动，就结束当前会话

```dart
await FlutterPluginEngagelabMa.setNoActiveSessionEndDurationTime(1800);
```

### 设置 UTM 属性

设置 UTM 相关属性。

- UTM 属性为标准事件属性，若开发者能识别用户是从哪一个广告跳转访问 App ，建议设置 UTM 信息，我们将在事件上报时传递该参数。目前能够设置 UTM 属性为：
         - utm_source 广告系列来源
         - utm_medium 广告系列媒介
         - utm_term 广告系列字词
         - utm_content 广告系列内容
         - utm_campaign 广告系列名称
         - utm_id 广告系列ID

```dart
await FlutterPluginEngagelabMa.setUtmProperties(
    utmSource: "google",
    utmMedium: "cpc",
    utmCampaign: "spring_sale"
);
```

### 设置采集控制

设置数据采集的控制参数，可以控制是否采集某些类型的数据。在初始化方法之前调用。

```dart
// 设置采集控制
 FlutterPluginEngagelabMa.setCollectControl({
    'idfa': true,         // 是否采集 IDFA  (only ios)
    'idfv': true,         // 是否采集 IDFV (only ios)
    'carrier': true,      // 是否采集运营商信息
    'imei': true,         // 是否采集 IMEI (only android)
    'aaid': true,         // 是否采集 Android ID (only android)
    'gaid': true,         // 是否采集GAID (only android)
    'oaid': true,         // 是否采集 OAID (only android)
    'macAddress': true,   // 是否采集 MAC 地址 (only android)
});
```

### 自定义事件统计

记录自定义事件

```dart

// 记录带属性的事件
final result = await FlutterPluginEngagelabMa.eventRecord(
          eventName: "customevent", property: {"key1": "value1"});

// 返回结果
{
    'code': 0,  // 0 表示成功，非 0 表示失败
    'message': '事件记录成功'
}
```

## 注意事项

1. 所有异步方法都返回 `Future`，需要使用 `async/await` 或 `.then()` 处理结果
2. 原生业务回调的 `code`、`message` 原样返回；非零 code 不会自动抛异常，message 不保证是 JSON，两端的错误码含义和文案也不保证相同。
3. 新增对象数组更新、追加、删除接口沿用旧属性接口：遇到 `PlatformException` 返回 `{'code': -1, 'message': '错误说明'}`。新增 `setChannelValue` 沿用联系方式接口：桥接异常保留异常 code，补充说明后抛出。`start`、身份接口维持原有异常处理。
4. 新接口的 Dart 参数校验失败抛出 `ArgumentError`；仅 Android 支持的 `configDebugMode`、`getSdkVersion` 在 iOS 抛出 `UnsupportedError`。原生初始化结果统一为 `code/message/euid/maRid/success`，不会额外映射业务错误码或解析 message。仅凭调用正常返回不能认定操作成功，应检查业务 code。
3. 用户属性相关的操作都支持批量处理，可以一次设置多个属性
4. 在进行用户属性操作之前，确保已经成功初始化 SDK

## Android MA 调试日志

Android MA 5.5.0+ 新增独立日志开关，默认关闭。建议在初始化前调用：

```dart
await FlutterPluginEngagelabMa.configDebugMode(true);
// 关闭时传 false。
```

直接桥接原生 MTMAApi.configDebugMode，不改变 Push 日志开关。
仅支持 Android；iOS 和其他平台抛出 UnsupportedError。
