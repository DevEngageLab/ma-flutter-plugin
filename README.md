# flutter_plugin_engagelab_ma

### Installation

Add the following dependencies to your `pubspec.yaml` file:

The flutter_plugin_engagelab_ma plugin cannot be used alone, it requires the [flutter_plugin_engagelab](https://pub.dev/packages/flutter_plugin_engagelab) plugin to be integrated simultaneously.

```yaml
dependencies:
  flutter_plugin_engagelab: ^1.3.4+523523
  flutter_plugin_engagelab_ma: ^1.0.1+523523
```

Navigate to the ios directory:
Run pod install

### Configuration

##### Android:

Add the following code to `/android/app/build.gradle`:

```groovy
android: {
  ....
  defaultConfig {
    applicationId "Replace with your application ID"
    ....
    manifestPlaceholders = [
                ENGAGELAB_PRIVATES_APPKEY : "Your appkey",
                ENGAGELAB_PRIVATES_CHANNEL: "developer",
                ENGAGELAB_PRIVATES_PROCESS: ":remote",
                XIAOMI_APPID            : "",//Xiaomi vendor, fill in MI- yours if available, leave empty if not
                XIAOMI_APPKEY           : "",//Xiaomi vendor, fill in MI- yours if available, leave empty if not
                MEIZU_APPID            : "",//Meizu vendor, fill in MZ- yours if available, leave empty if not
                MEIZU_APPKEY           : "",//Meizu vendor, fill in MZ- yours if available, leave empty if not
                OPPO_APPID             : "",//OPPO vendor, fill in OP- yours if available, leave empty if not
                OPPO_APPKEY            : "",//OPPO vendor, fill in OP- yours if available, leave empty if not
                OPPO_APPSECRET         : "",//OPPO vendor, fill in OP- yours if available, leave empty if not
                VIVO_APPID             : "",//VIVO vendor, fill in yours if available, leave empty if not
                VIVO_APPKEY            : "",//VIVO vendor, fill in yours if available, leave empty if not
                HONOR_APPID            : "",//Honor vendor, fill in yours if available, leave empty if not
                APP_TCP_SSL            : "",//Android TCP connection encryption, set to true for encryption, others for no encryption, can be left empty. This setting requires adding android:name="com.engagelab.privates.flutter_plugin_engagelab.MTApplication" in AndroidManifest.xml's application, or inheriting from this object
                APP_DEBUG            : "",//Android log debug mode, set to true for debug mode, others for non-debug mode, can be left empty. This setting requires adding android:name="com.engagelab.privates.flutter_plugin_engagelab.MTApplication" in AndroidManifest.xml's application, or inheriting from this object
                COUNTRY_CODE            : "",//For testing, can be left empty. This setting requires adding android:name="com.engagelab.privates.flutter_plugin_engagelab.MTApplication" in AndroidManifest.xml's application, or inheriting from this object
        ]
  }    
}
```

### Usage

```dart
import 'package:flutter_plugin_engagelab/flutter_plugin_engagelab.dart';
import 'package:flutter_plugin_engagelab_ma/flutter_plugin_engagelab_ma.dart';
```

### APIs

**Note**: 
The flutter_plugin_engagelab_ma plugin cannot be used alone, it requires the flutter_plugin_engagelab plugin to be integrated simultaneously.
Before calling the FlutterPluginEngagelabMa.start method to initialize the MA plugin, please initialize the flutter_plugin_engagelab plugin first.

[Reference](./documents/APIs.md)