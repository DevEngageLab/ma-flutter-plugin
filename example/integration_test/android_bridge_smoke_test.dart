import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_plugin_engagelab_ma/flutter_plugin_engagelab_ma.dart';

// Device smoke coverage without a project key or backend writes.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_plugin_engagelab_ma');

  testWidgets('Android published MA bridge toggles debug and validates input',
      (tester) async {
    expect(defaultTargetPlatform, TargetPlatform.android);
    await FlutterPluginEngagelabMa.configDebugMode(true);
    try {
      // Call native validation directly so Dart validation cannot mask a
      // missing plugin registration or incompatible native SDK.
      final result = await channel.invokeMapMethod<String, dynamic>(
          'start', <String, dynamic>{'appKey': ''});
      expect(result?['success'], false);
      expect(result?['code'], -3);
      expect(result?['euid'], '');
      expect(result?['maRid'], '');
      await expectLater(
          channel.invokeMethod<void>('configDebugMode'),
          throwsA(isA<PlatformException>()
              .having((error) => error.code, 'code', 'INVALID_ARGUMENT')));
      expect(await FlutterPluginEngagelabMa.getEuid(), isA<String>());
      expect(await FlutterPluginEngagelabMa.getMaRid(), isA<String>());
    } finally {
      await FlutterPluginEngagelabMa.configDebugMode(false);
    }
  });
}
