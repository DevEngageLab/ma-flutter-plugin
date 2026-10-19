# EngageLab MA Flutter Plugin API Documentation

## Table of Contents
- [EngageLab MA Flutter Plugin API Documentation](#engagelab-ma-flutter-plugin-api-documentation)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Initialization](#initialization)
  - [Data Collection Switch](#data-collection-switch)
  - [User Property Management](#user-property-management)
    - [Override Update User Properties](#override-update-user-properties)
    - [Increment User Properties](#increment-user-properties)
    - [Append User Properties](#append-user-properties)
    - [Manage object_array Elements](#manage-object_array-elements)
    - [Remove User Properties](#remove-user-properties)
    - [Delete User Properties](#delete-user-properties)
  - [Other Features](#other-features)
    - [Set User Identity](#set-user-identity)
    - [Set User Contact Information](#set-user-contact-information)
    - [Get EUID](#get-euid)
    - [Get MA RID](#get-ma-rid)
    - [Set Third-Party Push Channel](#set-third-party-push-channel)
    - [Set Report Interval](#set-report-interval)
    - [Set Event Cache Limit](#set-event-cache-limit)
    - [Set Session Timeout](#set-session-timeout)
    - [Set UTM Properties](#set-utm-properties)
    - [Custom Event Tracking](#custom-event-tracking)

## Installation

Add the dependency in your `pubspec.yaml` file:

Android and iOS MA 5.5.0 support standalone initialization. Add [flutter_plugin_engagelab](https://pub.dev/packages/flutter_plugin_engagelab) only when Push capabilities are required.

The plugin resolves Android MA 5.5.2 from Maven Central and iOS MTMA 5.5.1 from CocoaPods. Use the AppKey for your production-environment project.

```yaml
dependencies:
  flutter_plugin_engagelab_ma: ^1.0.5+552551
```

Navigate to the ios directory:
Run pod install

## Initialization

Pass the MA AppKey to `start`. Android and iOS MA 5.5.0 do not need to wait for Push initialization.

`appKey` is the MA project AppKey, independent from the Push AppKey, and must be 24 letters or digits. `userId`, `anonymousId`, `email`, and `phone` are all optional; their length and format rules match the native SDK. See the [Android API guide](../sdkdoc/android/API%20指南.md) and [iOS API guide](../sdkdoc/ios/API%20指南.md).

```dart
final result = await FlutterPluginEngagelabMa.start(
  appKey: "your_ma_app_key",
  userId: "your_user_id",
  anonymousId: "anon_id",
  email: "user@example.com",
  phone: "+8613800138000",
);

// result contains code, message, euid, maRid, and success
```

## Data Collection Switch

Set the user's current consent in every initialization, before automatic collection can start:

```dart
final result = await FlutterPluginEngagelabMa.start(
  appKey: 'your_ma_app_key',
  dataCollectionEnabled: false,
);
```

After initialization succeeds, submit the user's choice from your consent handler:

```dart
Future<void> onConsentChanged(bool consentGranted) async {
  await FlutterPluginEngagelabMa.setDataCollectionEnabled(consentGranted);
}

final bool? enabled = await FlutterPluginEngagelabMa.isDataCollectionEnabled();
```

`start(dataCollectionEnabled: ...)` accepts `true`, `false`, or an omitted/null value.
When omitted, Android keeps the saved choice for that MA AppKey (initially enabled);
iOS defaults to enabled for that initialization. Pass consent explicitly each time
to obtain the same behavior on both platforms. The plugin keeps no separate switch cache.

Call the runtime setter after successful initialization. Its `Future<void>` completes
when the native call returns, without acknowledging server synchronization or the end
of collection recovery. The query returns the native local state without a network
request: Android returns a boolean (true before the first start in the main process);
iOS returns null until initialization is ready. The iOS setter queues the switch on
the SDK thread, so an immediate query can still return the previous local state.

Disabling stops new behavior events, user properties, UTM and optional device collection.
The native SDK may send the final batch of data produced before disabling and the
session end event, then clear collection caches. Initialization, EUID/MA RID, user
identity, contact information and Push channel binding remain available. Re-enabling
restores collection and starts a new session; Android property calls during recovery
can return `-2`.

Property APIs, including object_array APIs, preserve native result maps. When disabled,
their `code` is `FlutterPluginEngagelabMa.codeCollectionDisabled` (`-8`). Existing
`eventRecord` and `setUtmProperties` return values only confirm that the bridge call
completed; they do not confirm collection or delivery. Their native calls are ignored
while disabled. `setCollectControl` continues to configure individual device fields;
use the new switch to control overall MA collection.

## User Property Management

### Override Update User Properties

Override update user properties. If the property already exists, it will be overwritten.

- Parameters are passed as a map whose keys are strings. Values support strings, finite numbers, booleans, string arrays, maps (`object`), and arrays of maps (`object_array`). Nested `object`/`object_array` values are not supported.
- If a user property already exists, it will be overwritten; if it doesn't exist, it will be created. For example: user membership level.

```dart
final result = await FlutterPluginEngagelabMa.setUserProperties({
  'name': 'John Doe',
  'devices': <Map<String, Object?>>[
    {'device_id': 'device_1', 'enabled': true},
  ],
});

// Return result
{
    'code': 0,  // 0 indicates success, non-0 indicates failure
    'message': ''
}
```

### Increment User Properties

- Add a value to a numeric user property, accumulating all reported data, such as total consumption amount.
- This interface can only be called for Number type user properties, otherwise it will be ignored. If the user property doesn't exist, the initial value will be treated as 0.

```dart
final result = await FlutterPluginEngagelabMa.incrementUserProperties({
    'loginCount': 1,
    'points': 100
});

// Return result
{
    'code': 0, // 0 indicates success, non-0 indicates failure
    'message': ''
}
```

### Append User Properties

Add new values to array type properties.

- Add some values to an array type property.
- As mentioned before, the elements of this array must be String, otherwise they will be ignored. Also, if the user property to be added doesn't exist, an empty array will be initialized.

```dart
final result = await FlutterPluginEngagelabMa.appendUserProperties(
          property: "interests", values: ['sports', 'music']);

// Return result
{
    'code': 0, // 0 indicates success, non-0 indicates failure
    'message': ''
}
```

### Manage object_array Elements

Android and iOS MA 5.5.0 and later support updating, appending, and removing individual `object_array` elements. Use `setUserProperties` with a non-empty array first when the property has not yet been created. The existing `appendUserProperties` and `removeUserProperties` APIs remain string-array-only APIs.

Update the fields of the uniquely matching object. `identifierValue` must be a string or finite number. A `null` value removes that field, and `values` cannot modify the identifier field.

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

Append one non-empty object without replacing existing elements:

```dart
final result = await FlutterPluginEngagelabMa.appendObjectArrayProperty(
  property: 'devices',
  object: <String, Object?>{
    'device_id': 'device_2',
    'year': 2026,
  },
);
```

Remove the complete object identified by a unique field:

```dart
final result = await FlutterPluginEngagelabMa.removeObjectArrayProperty(
  property: 'devices',
  identifierKey: 'device_id',
  identifierValue: 'device_2',
);
```

### Remove User Properties

- Remove specified values from array type properties.
- The values parameter is an array, and its internal elements must be String type.

```dart
final result = await FlutterPluginEngagelabMa.removeUserProperties(
          property: "interests", values: ['sports']);

// Return result
{
    'code': 0,
    'message': 'Successfully removed user property'
}
```

### Delete User Properties

- Delete all content of a user property
- If the user property doesn't exist, it will be ignored

```dart
final result =
          await FlutterPluginEngagelabMa.deleteUserProperty("interests");

// Return result
{
    'code': 0,
    'message': 'Successfully deleted user property'
}
```

## Other Features

### Set User Identity

Set user identity information.

```dart
final result = await FlutterPluginEngagelabMa.setUserIdentity(
    userId: "your_user_id",     // optional
    anonymousId: "anon_id",     // optional
    email: "user@example.com",  // optional
    phone: "+8613800138000",    // optional
);
```

### Set User Contact Information

Set user contact information.

Currently supports 4 types of contact information: email, mobile_phone, landline_phone, and whatsapp_phone.

```dart
final result = await FlutterPluginEngagelabMa.setUserContact({
    "email": "user@example.com",
    "mobile_phone": "1234567890"
});
```

### Get EUID

Get user's EUID.

Returns an empty string before initialization succeeds or before the identity is available.

```dart
final euid = await FlutterPluginEngagelabMa.getEuid();
```

### Get MA RID

Supported on Android and iOS 5.5.0 and later.

Returns an empty string before initialization succeeds or before the identity is available. MA RID and Push RID are different device identifiers and must not be used interchangeably.

```dart
final maRid = await FlutterPluginEngagelabMa.getMaRid();
```

### Set Third-Party Push Channel

Supported on Android and iOS 5.5.0 and later. Use this API to set a third-party Push RID or token. When EngageLab AppPush and MA are both integrated, MA automatically associates the AppPush AppKey/RID with the current MA identity after AppPush registration succeeds; do not call this API for AppPush. Other third-party Push providers still require an explicit call.

`channelId` must be greater than 0. Flutter trims leading and trailing whitespace from every RID/token on both platforms without modifying the input list. `values` and every trimmed string must be non-empty. Call the API again whenever the RID or token changes.

```dart
final result = await FlutterPluginEngagelabMa.setChannelValue(
  channelId: 1,
  values: ['third_party_push_token'],
);
```

### Set Report Interval

Set the data reporting time interval (in seconds).

- Set the reporting data interval. If this interface is not called, events will be reported every 10 seconds by default
- The reporting interval is cached in memory and needs to be called in each application lifecycle to take effect

```dart
await FlutterPluginEngagelabMa.setReportInterval(10);
```

### Set Event Cache Limit

Set the maximum number of locally cached events.

- Set the event cache limit. Default is 50 events, maximum cannot exceed 500 events
- When the cache limit is exceeded, all data will be reported

```dart
await FlutterPluginEngagelabMa.setMaxEventCacheCount(50);
```

### Set Session Timeout

Set session timeout duration (in seconds).

- Set session timeout duration, default is 1800 seconds
- When the App switches to background, the session timeout timer starts. If there's no activity within the timeout period, the current session ends

```dart
await FlutterPluginEngagelabMa.setNoActiveSessionEndDurationTime(1800);
```

### Set UTM Properties

Set UTM-related properties.

- UTM properties are standard event properties. If developers can identify which advertisement the user came from to access the App, it's recommended to set UTM information. We will pass this parameter during event reporting. Currently, the following UTM properties can be set:
         - utm_source: Advertising campaign source
         - utm_medium: Advertising campaign medium
         - utm_term: Advertising campaign terms
         - utm_content: Advertising campaign content
         - utm_campaign: Advertising campaign name
         - utm_id: Advertising campaign ID

```dart
await FlutterPluginEngagelabMa.setUtmProperties(
    utmSource: "google",
    utmMedium: "cpc",
    utmCampaign: "spring_sale"
);
```
```

### Set Collection Control

Set data collection control parameters to control whether certain types of data are collected. Call before initialization method.

```dart
// Set collection control
FlutterPluginEngagelabMa.setCollectControl({
    'idfa': true,         // Whether to collect IDFA (only ios)
    'idfv': true,         // Whether to collect IDFV (only ios)
    'carrier': true,      // Whether to collect carrier information
    'imei': true,         // Whether to collect IMEI (only android)
    'aaid': true,         // Whether to collect Android ID (only android)
    'gaid': true,         // Whether to collect GAID (only android)
    'oaid': true,         // Whether to collect OAID (only android)
    'macAddress': true,   // Whether to collect MAC address (only android)
});
```

### Custom Event Tracking

Record custom events

```dart
// Record event with properties
final result = await FlutterPluginEngagelabMa.eventRecord(
          eventName: "customevent", property: {"key1": "value1"});

// Return result
{
    'code': 0,  // 0 indicates success, non-0 indicates failure
    'message': 'Event recorded successfully'
}
```

## Results and Exceptions

Native business results keep their original `code` and `message`. A nonzero
code does not throw automatically; messages are not necessarily JSON and error
meanings can differ by platform. Check the business code instead of message text.

The new object-array update, append and remove methods follow existing property
APIs: a `PlatformException` becomes `{'code': -1, 'message': 'error description'}`.
`setChannelValue` follows the contact API: bridge exceptions keep their code and
are rethrown with an explanatory message. Dart argument validation throws
`ArgumentError`.

Initialization keeps the original exception behavior: native failures return a
Map, while bridge exceptions are rethrown with an explanatory message. Standalone
initialization requires `appKey` and adds `euid`, `maRid`, and `success` to the
existing `code`/`message` result. It does not introduce error-code remapping or
initialization queuing. Await each initialization before starting the next one.

## Android MA Debug Logging

Android MA 5.5.0+ exposes an independent logging switch, disabled by default.
Call before initialization to include initialization logs:

```dart
await FlutterPluginEngagelabMa.configDebugMode(true);
// Disable with configDebugMode(false).
```

This bridges MTMAApi.configDebugMode directly and does not change Push logging.
It is Android-only; iOS and other platforms throw UnsupportedError.
