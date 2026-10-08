# flutter_plugin_engagelab_ma


### 安装

在 `pubspec.yaml` 文件中添加依赖：

Android 和 iOS MA 5.5.0 均支持独立初始化；只有需要 Push 能力时才需要同时集成 [flutter_plugin_engagelab](https://pub.dev/packages/flutter_plugin_engagelab) 插件。

插件通过 Maven Central 引入 Android MA 5.5.0，通过 CocoaPods 引入 iOS MTMA 5.5.0，无需本地 SDK 制品。

```yaml
dependencies:
  flutter_plugin_engagelab_ma: ^1.0.4+550550
```

cd 到 ios 目录下：
运行 pod install

### 配置

##### Android:

接口使用方式见 [Flutter API 文档](./APIs.md)。

最低支持 Android API 23。MA 依赖 `com.engagelab.plugin:oth_ma:5.5.0`
从 Maven Central 获取，无需本地构建 SDK。插件已声明联网权限，支持独立 MA 的 release 构建。

AppPush 自动绑定需要原生 Push SDK 5.5.0 或以上版本。如果 Flutter Push 插件仍依赖旧版本，
在应用的 Gradle 文件中添加：

```groovy
dependencies {
  implementation 'com.engagelab:engagelab:5.5.0'
}
```

同时集成 Push 时，在 `/android/app/build.gradle` 中添加下列配置：

```groovy
android: {
  ....
  defaultConfig {
    applicationId "替换成自己应用 ID"
    ....
    manifestPlaceholders = [
                ENGAGELAB_PRIVATES_APPKEY : "你的appkey",
                ENGAGELAB_PRIVATES_CHANNEL: "developer",
                ENGAGELAB_PRIVATES_PROCESS: ":remote",
                XIAOMI_APPID            : "",//小米厂商，有就填MI-自己的，没有就不用填，保留为""
                XIAOMI_APPKEY           : "",//小米厂商，有就填MI-自己的，没有就不用填，保留为""
                MEIZU_APPID            : "",//魅族厂商，有就填MZ-自己的，没有就不用填，保留为""
                MEIZU_APPKEY           : "",//魅族厂商，有就填MZ-自己的，没有就不用填，保留为""
                OPPO_APPID             : "",//OPPO厂商，有就填OP-自己的，没有就不用填，保留为""
                OPPO_APPKEY            : "",//OPPO厂商，有就填OP-自己的，没有就不用填，保留为""
                OPPO_APPSECRET         : "",//OPPO厂商，有就填OP-自己的，没有就不用填，保留为""
                VIVO_APPID             : "",//VIVO厂商，有就填自己的，没有就不用填，保留为""
                VIVO_APPKEY            : "",//VIVO厂商，有就填自己的，没有就不用填，保留为""
                HONOR_APPID            : "",//荣耀厂商，有就填自己的，没有就不用填，保留为""
                APP_TCP_SSL            : "",//android tcp连接是否加密，填true为加密，其他为不加密，可保留为""，这个数据要生效需在AndroidManifest.xml中的application添加android:name="com.engagelab.privates.flutter_plugin_engagelab.MTApplication"，或继承该对象
                APP_DEBUG            : "",//android log debug模式，填true为debug模式，其他为非debug模式，可保留为""，这个数据要生效需在AndroidManifest.xml中的application添加android:name="com.engagelab.privates.flutter_plugin_engagelab.MTApplication"，或继承该对象
                COUNTRY_CODE            : "",//测试用，可保留为""，这个数据要生效需在AndroidManifest.xml中的application添加android:name="com.engagelab.privates.flutter_plugin_engagelab.MTApplication"，或继承该对象
        ]
  }    
}
```

### 使用

```dart
import 'package:flutter_plugin_engagelab_ma/flutter_plugin_engagelab_ma.dart';
```

### APIs

Android 和 iOS 端均直接使用 MA AppKey 初始化，Push 初始化为可选项：

```dart
final result = await FlutterPluginEngagelabMa.start(
  appKey: '您的 MA AppKey',
);
```

[API 文档](./APIs.md) · [示例与集成测试](../example/README.md)
