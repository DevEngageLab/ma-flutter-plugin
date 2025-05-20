# EngageLab MA Flutter Plugin API Documentation

## Table of Contents
- [EngageLab MA Flutter Plugin API Documentation](#engagelab-ma-flutter-plugin-api-documentation)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Initialization](#initialization)
  - [User Property Management](#user-property-management)
    - [Override Update User Properties](#override-update-user-properties)
    - [Increment User Properties](#increment-user-properties)
    - [Append User Properties](#append-user-properties)
    - [Remove User Properties](#remove-user-properties)
    - [Delete User Properties](#delete-user-properties)
  - [Other Features](#other-features)
    - [Set User Identity](#set-user-identity)
    - [Set User Contact Information](#set-user-contact-information)
    - [Get EUID](#get-euid)
    - [Set Report Interval](#set-report-interval)
    - [Set Event Cache Limit](#set-event-cache-limit)
    - [Set Session Timeout](#set-session-timeout)
    - [Set UTM Properties](#set-utm-properties)
    - [Custom Event Tracking](#custom-event-tracking)

## Installation

Add the dependency in your `pubspec.yaml` file:

The flutter_plugin_engagelab_ma plugin cannot be used alone and requires integration with the [flutter_plugin_engagelab](https://pub.dev/packages/flutter_plugin_engagelab) plugin.

```yaml
dependencies:
  flutter_plugin_engagelab: ^1.2.9+500500
  flutter_plugin_engagelab_ma: ^1.0.0+500500
```

Navigate to the ios directory:
Run pod install

## Initialization

Initialize the MA SDK: This needs to be done after the successful initialization of the flutter_plugin_engagelab plugin.

For flutter_plugin_engagelab initialization, please refer to the demo example in [flutter_plugin_engagelab](https://github.com/DevEngageLab/push-flutter-plugin/blob/main/example/lib/main.dart).

```dart
// Initialize flutter_plugin_engagelab plugin
FlutterPluginEngagelab.addEventHandler(
        onMTCommonReceiver: (Map<String, dynamic> message) async {
      String event_name = message["event_name"];
      if (Comparable.compare(event_name, "onConnectStatus") == 0 ||
          Comparable.compare(event_name, "networkDidLogin") == 0) {
        // Initialize flutter_plugin_engagelab_ma plugin
        final result = await FlutterPluginEngagelabMa.start(
            userId: "your_user_id",     
            anonymousId: "anon_id"     
        );
      }
    });
if (Platform.isIOS) {
      FlutterPluginEngagelab.initIos(
        appKey: "your_appkey", 
        channel: "testChannel",
      );
      FlutterPluginEngagelab.checkNotificationAuthorizationIos();
} else if (Platform.isAndroid) {
      FlutterPluginEngagelab.initAndroid();
}
```

## User Property Management

### Override Update User Properties

Override update user properties. If the property already exists, it will be overwritten.

- Parameters are passed as a dictionary. The key must be of String type. The value supports String/Number/List types, and the internal values of List type must be String type.
- If a user property already exists, it will be overwritten; if it doesn't exist, it will be created. For example: user membership level.

```dart
final result = await FlutterPluginEngagelabMa.setUserProperties({
    'name': 'John Doe'
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
    anonymousId: "anon_id"      // optional
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

```dart
final euid = await FlutterPluginEngagelabMa.getEuid();
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

