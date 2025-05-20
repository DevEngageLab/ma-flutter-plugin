# flutter_plugin_engagelab_ma


### 安装

在 `pubspec.yaml` 文件中添加依赖：

flutter_plugin_engagelab_ma 插件无法单独使用，需要同时集成[flutter_plugin_engagelab](https://pub.dev/packages/flutter_plugin_engagelab)插件。

```yaml
dependencies:
  flutter_plugin_engagelab: ^1.2.9+500500
  flutter_plugin_engagelab_ma: ^1.0.0+500500
```

cd 到 ios 目录下：
运行 pod install

### 配置

##### Android:

在 `/android/app/build.gradle` 中添加下列代码：

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
import 'package:flutter_plugin_engagelab/flutter_plugin_engagelab.dart';
import 'package:flutter_plugin_engagelab_ma/flutter_plugin_engagelab_ma.dart';
```

### APIs

**注意** : 
flutter_plugin_engagelab_ma 插件无法单独使用，需要同时集成flutter_plugin_engagelab插件。
调用 FlutterPluginEngagelabMa.start 方法初始化MA插件之前，请先初始化flutter_plugin_engagelab插件。

 [参考](./documents/APIs.md)

