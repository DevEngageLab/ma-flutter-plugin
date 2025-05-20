# EngageLab MA Flutter 插件 API 文档

## 目录
- [EngageLab MA Flutter 插件 API 文档](#engagelab-ma-flutter-插件-api-文档)
  - [目录](#目录)
  - [安装](#安装)
  - [初始化](#初始化)
  - [用户属性管理](#用户属性管理)
    - [覆盖更新用户属性](#覆盖更新用户属性)
    - [累加更新用户属性](#累加更新用户属性)
    - [追加用户属性](#追加用户属性)
    - [移除用户属性](#移除用户属性)
    - [删除用户属性](#删除用户属性)
  - [其他功能](#其他功能)
    - [设置用户身份](#设置用户身份)
    - [设置用户联系方式](#设置用户联系方式)
    - [获取 EUID](#获取-euid)
    - [设置上报间隔](#设置上报间隔)
    - [设置事件缓存上限](#设置事件缓存上限)
    - [设置会话超时时间](#设置会话超时时间)
    - [设置 UTM 属性](#设置-utm-属性)
    - [设置采集控制](#设置采集控制)
    - [自定义事件统计](#自定义事件统计)
  - [注意事项](#注意事项)

## 安装

在 `pubspec.yaml` 文件中添加依赖：

flutter_plugin_engagelab_ma 插件无法单独使用，需要同时集成[flutter_plugin_engagelab](https://pub.dev/packages/flutter_plugin_engagelab)插件。

```yaml
dependencies:
  flutter_plugin_engagelab: ^1.2.9+500500
  flutter_plugin_engagelab_ma: ^1.0.0+500500
```

cd 到 ios 目录下：
运行 pod install

## 初始化

初始化 MA SDK：需要在 flutter_plugin_engagelab 插件初始化成功之后进行。

flutter_plugin_engagelab 的初始化请参考 [flutter_plugin_engagelab](https://github.com/DevEngageLab/push-flutter-plugin/blob/main/example/lib/main.dart) 的demo示例。

```dart

// 初始化 flutter_plugin_engagelab 插件
FlutterPluginEngagelab.addEventHandler(
        onMTCommonReceiver: (Map<String, dynamic> message) async {
      String event_name = message["event_name"];
      if (Comparable.compare(event_name, "onConnectStatus") == 0 ||
          Comparable.compare(event_name, "networkDidLogin") == 0) {
        // 初始化flutter_plugin_engagelab_ma 插件
        final result = await FlutterPluginEngagelabMa.start(
            userId: "your_user_id",     
            anonymousId: "anon_id"     
        );
      }
    });
if (Platform.isIOS) {
      FlutterPluginEngagelab.initIos(
        appKey: "您的appkey", 
        channel: "testChannel",
      );
      FlutterPluginEngagelab.checkNotificationAuthorizationIos();
} else if (Platform.isAndroid) {
      FlutterPluginEngagelab.initAndroid();
}


```

## 用户属性管理

### 覆盖更新用户属性

覆盖更新用户属性，如果属性已存在则会被覆盖。

- 参数传入字典。key值必须是String类型。value值支持String/Number/List类型， List类型的内部数值必须是String类型。
- 如果某个用户属性之前已经存在了，则这次会被覆盖掉；不存在，则会创建。如：用户会员等级。

```dart
final result = await FlutterPluginEngagelabMa.setUserProperties({
    'name': 'John Doe'
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
    anonymousId: "anon_id"      // 可选
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

```dart
final euid = await FlutterPluginEngagelabMa.getEuid();
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
2. 所有方法都可能抛出 `PlatformException`，建议使用 try-catch 进行错误处理
3. 用户属性相关的操作都支持批量处理，可以一次设置多个属性
4. 在进行用户属性操作之前，确保已经成功初始化 SDK