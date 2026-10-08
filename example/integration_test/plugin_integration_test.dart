// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_plugin_engagelab_ma/flutter_plugin_engagelab_ma.dart';

const String maAppKeyOverride = String.fromEnvironment(
  'MA_APP_KEY',
);
const int channelIdOverride = int.fromEnvironment('MA_CHANNEL_ID');

String get maAppKey => maAppKeyOverride;

int get channelId => channelIdOverride;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MA APIs work through the native channel',
      (WidgetTester tester) async {
    expect(maAppKey, isNotEmpty, reason: 'Supply production MA_APP_KEY');
    expect(channelId, greaterThan(0),
        reason: 'Supply production MA_CHANNEL_ID');
    final result = await FlutterPluginEngagelabMa.start(
      appKey: maAppKey,
      userId: 'integration_test_user',
      anonymousId: 'integration_test_anonymous',
    );

    expect(result['success'], true, reason: '$result');
    expect(result['euid'], isNotEmpty);
    expect(result['maRid'], isNotEmpty);
    expect(await FlutterPluginEngagelabMa.getEuid(), result['euid']);
    expect(await FlutterPluginEngagelabMa.getMaRid(), result['maRid']);

    final channelResult = await FlutterPluginEngagelabMa.setChannelValue(
      channelId: channelId,
      values: <String>['integration-test-token'],
    );
    expect(channelResult.containsKey('code'), true);

    final setResult = await FlutterPluginEngagelabMa.setUserProperties(
      <String, Object?>{
        'devices': <Map<String, Object?>>[
          <String, Object?>{
            'device_id': 'flutter-device-1',
            'enabled': true,
          },
        ],
      },
    );
    expect(setResult['code'], 0, reason: '${setResult['message']}');

    final updateResult =
        await FlutterPluginEngagelabMa.updateObjectArrayProperty(
      property: 'devices',
      identifierKey: 'device_id',
      identifierValue: 'flutter-device-1',
      values: <String, Object?>{'enabled': false},
    );
    expect(updateResult['code'], 0, reason: '${updateResult['message']}');

    final appendResult =
        await FlutterPluginEngagelabMa.appendObjectArrayProperty(
      property: 'devices',
      object: <String, Object?>{
        'device_id': 'flutter-device-2',
        'year': 2026,
      },
    );
    expect(appendResult['code'], 0, reason: '${appendResult['message']}');

    final removeResult =
        await FlutterPluginEngagelabMa.removeObjectArrayProperty(
      property: 'devices',
      identifierKey: 'device_id',
      identifierValue: 'flutter-device-2',
    );
    expect(removeResult['code'], 0, reason: '${removeResult['message']}');
  });
}
