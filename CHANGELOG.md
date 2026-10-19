## 1.0.5+552551

* upgrade published native dependencies to Android MA 5.5.2 and iOS MTMA 5.5.1
* add optional `start(dataCollectionEnabled: ...)`, runtime `setDataCollectionEnabled`, and nullable `isDataCollectionEnabled`
* preserve native defaults, not-ready query results, and disabled property result code -8 (`codeCollectionDisabled`)
* add collection switching to the example and document consent initialization and native recovery behavior

## 1.0.4+550550

* preserve native business codes/messages for new APIs; handle object-array bridge exceptions like existing property APIs and channel bridge exceptions like contact APIs
* support Android and iOS standalone initialization with MA AppKey
* add getMaRid and setChannelValue on Android and iOS, with consistent channel token whitespace handling
* add object_array element update, append, and remove APIs; map append to native addObjectArrayProperty
* bridge the standalone Android MA configDebugMode API (Android only)
* use published MA 5.5.0 dependencies; the example runs without Push
* require Android API 23 and declare iOS 10 as the minimum deployment target, matching the native MTMA SDK
* declare Internet permission for standalone MA and exclude build caches, examples, and tests from the published package

### Upgrading from 1.0.3

`start()` now requires the MA project's `appKey`. Pass it explicitly even when
AppPush is also integrated. The MA AppKey and Push AppKey are configured
independently.

Before:

```dart
await FlutterPluginEngagelabMa.start(userId: 'user_id');
```

After:

```dart
await FlutterPluginEngagelabMa.start(
  appKey: 'your_ma_app_key',
  userId: 'user_id',
);
```

Set the Android application's minimum SDK to API 23 or later. The iOS plugin
now declares a minimum deployment target of iOS 10, matching the native MTMA
requirement; the host application must also meet its Flutter version's minimum.

MA can initialize independently. Keep the Push plugin only when Push capabilities
are needed, and initialize MA and Push separately.

## 1.0.3+530532

* fix ios setUserIdentity api issuue

## 1.0.2+530532

* update android sdk 5.3.0, ios sdk 5.3.2

## 1.0.1+523523

* ma first version, android sdk 5.2.3, ios sdk 5.2.3

## 1.0.0+500500

* ma first version, android sdk 5.0.0, ios sdk 5.0.0
