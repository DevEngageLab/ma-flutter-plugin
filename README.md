# flutter_plugin_engagelab_ma

### Installation

Add the following dependencies to your `pubspec.yaml` file:

On Android and iOS, MA 5.5.0 can be initialized independently. Add the [flutter_plugin_engagelab](https://pub.dev/packages/flutter_plugin_engagelab) plugin only when Push capabilities are also required.

The plugin resolves Android MA 5.5.2 from Maven Central and iOS MTMA 5.5.1 from CocoaPods. No local SDK artifacts are required.

```yaml
dependencies:
  flutter_plugin_engagelab_ma: ^1.0.5+552551
```

Navigate to the ios directory:
Run pod install

### Configuration

##### Android:

See the [API reference](./documents/APIs.md) for usage.

Requires Android API 23 or later. The plugin resolves
`com.engagelab.plugin:oth_ma:5.5.2` from Maven Central and declares the Internet
permission for standalone MA.

For AppPush auto-binding, use native Push SDK `5.5.0` or later. If the Flutter
Push plugin still requests an older version, add this to the app's Gradle file:

```groovy
dependencies {
  implementation 'com.engagelab:engagelab:5.5.0'
}
```

When Push is also integrated, add its configuration to `/android/app/build.gradle`:

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

##### iOS:

Requires iOS 10 or later, matching the native standalone MTMA 5.5.0 SDK.
The plugin resolves `MTMA` 5.5.1 from CocoaPods. Set your development team and
bundle identifier in Xcode before running.

### Usage

```dart
import 'package:flutter_plugin_engagelab_ma/flutter_plugin_engagelab_ma.dart';
```

### APIs

On Android and iOS, initialize MA directly with its MA AppKey. Push initialization is optional:

```dart
final result = await FlutterPluginEngagelabMa.start(
  appKey: 'your_ma_app_key',
  dataCollectionEnabled: false, // Set the user's current consent on every start.
);
```

[API reference](./documents/APIs.md) · [Example and integration tests](./example/README.md)

After initialization succeeds, use `setDataCollectionEnabled(bool)` to change
consent and `isDataCollectionEnabled()` to query local state. See the
[collection switch contract](./documents/APIs.md#data-collection-switch), including
platform defaults and the nullable iOS query before initialization is ready.
