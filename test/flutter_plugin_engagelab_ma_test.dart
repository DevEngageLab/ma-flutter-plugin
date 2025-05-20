import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_plugin_engagelab_ma/flutter_plugin_engagelab_ma.dart';
import 'package:flutter_plugin_engagelab_ma/flutter_plugin_engagelab_ma_platform_interface.dart';
import 'package:flutter_plugin_engagelab_ma/flutter_plugin_engagelab_ma_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterPluginEngagelabMaPlatform
    with MockPlatformInterfaceMixin
    implements FlutterPluginEngagelabMaPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterPluginEngagelabMaPlatform initialPlatform = FlutterPluginEngagelabMaPlatform.instance;

  test('$MethodChannelFlutterPluginEngagelabMa is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterPluginEngagelabMa>());
  });

  test('getPlatformVersion', () async {
    FlutterPluginEngagelabMa flutterPluginEngagelabMaPlugin = FlutterPluginEngagelabMa();
    MockFlutterPluginEngagelabMaPlatform fakePlatform = MockFlutterPluginEngagelabMaPlatform();
    FlutterPluginEngagelabMaPlatform.instance = fakePlatform;

    expect(await flutterPluginEngagelabMaPlugin.getPlatformVersion(), '42');
  });
}
