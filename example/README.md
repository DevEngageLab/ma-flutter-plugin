# EngageLab MA example

Demonstrates standalone MA initialization, user properties, `object_array`
operations, and explains optional AppPush auto-binding. See the [API reference](../documents/APIs.md).

The plugin resolves official MA 5.5.0 dependencies from Maven Central and
CocoaPods. Use AppKeys for the production environment.

## Run

From this directory:

```shell
flutter run -d <device-id> --dart-define=MA_APP_KEY=your_ma_app_key --dart-define=MA_CHANNEL_ID=your_channel_id
```

`MA_APP_KEY` must be supplied explicitly for your project. `MA_CHANNEL_ID` is
optional for the UI and required when exercising third-party channel APIs.

The iOS plugin resolves MTMA 5.5.0 from CocoaPods. On macOS, run
`flutter pub get`, then `cd ios && pod install`, and select your development team
and bundle identifier in Xcode.

## Optional AppPush association

MA runs independently. If the host app separately integrates and initializes
AppPush, the native MA SDK automatically associates the Push AppKey/RID once both
MA and Push identities are ready. Do not call `setChannelValue` for this association;
that API is for third-party Push channels.

The example uses standalone MA 5.5.0 from Maven Central and CocoaPods.
To try AppPush association, add and initialize Push in your host application
with its matching AppKey.

## Tests

Run an Android device bridge smoke test without project credentials:

```shell
flutter test integration_test/android_bridge_smoke_test.dart -d <android-device-id>
```

This checks native debug switching, argument validation, and identity getter
bridges. It does not initialize a production project or verify backend writes.

Run the MA bridge test on a device:

```shell
flutter test integration_test/plugin_integration_test.dart -d <device-id> --dart-define=MA_APP_KEY=your_ma_app_key --dart-define=MA_CHANNEL_ID=your_channel_id
```

Run the Objective-C bridge validation tests in `ios/RunnerTests/RunnerTests.m`
from the Runner scheme in Xcode.
