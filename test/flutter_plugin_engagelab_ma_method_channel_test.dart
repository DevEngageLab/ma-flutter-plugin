import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_plugin_engagelab_ma/flutter_plugin_engagelab_ma.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('flutter_plugin_engagelab_ma');
  MethodCall? lastCall;
  Object? response;

  setUp(() {
    lastCall = null;
    response = <String, dynamic>{'code': 0, 'message': 'success'};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      lastCall = call;
      if (response is PlatformException) {
        throw response!;
      }
      return response;
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  final throwingOperations = <String, Future<Map<dynamic, dynamic>> Function()>{
    '启动 EngageLab MA 服务失败': () =>
        FlutterPluginEngagelabMa.start(appKey: 'ma-key'),
    '设置用户身份失败': () => FlutterPluginEngagelabMa.setUserIdentity(userId: 'user'),
    '设置用户联系方式失败': () =>
        FlutterPluginEngagelabMa.setUserContact({'email': 'a@b.com'}),
  };
  for (final operation in throwingOperations.entries) {
    test(
        '${operation.key}: native failure is returned, bridge failure is thrown',
        () async {
      response = <String, dynamic>{
        'code': -3,
        'message': '{"email":{"code":3002}}',
      };
      expect(await operation.value(), response);
      response = PlatformException(code: 'BRIDGE_ERROR', message: 'failed');
      await expectLater(
          operation.value(),
          throwsA(isA<PlatformException>()
              .having((e) => e.code, 'code', 'BRIDGE_ERROR')
              .having(
                  (e) => e.message, 'message', '${operation.key}: failed')));
    });
  }

  final legacyProperties = <String, Future<Map<dynamic, dynamic>> Function()>{
    '覆盖更新用户属性失败': () =>
        FlutterPluginEngagelabMa.setUserProperties({'name': 'a'}),
    '累加更新用户属性失败': () =>
        FlutterPluginEngagelabMa.incrementUserProperties({'count': 1}),
    '追加用户属性失败': () => FlutterPluginEngagelabMa.appendUserProperties(
        property: 'tags', values: ['a']),
    '移除用户属性失败': () => FlutterPluginEngagelabMa.removeUserProperties(
        property: 'tags', values: ['a']),
    '删除用户属性失败': () => FlutterPluginEngagelabMa.deleteUserProperty('tags'),
  };
  for (final operation in legacyProperties.entries) {
    test(
        '${operation.key}: existing result and exception handling stays intact',
        () async {
      response = <String, dynamic>{'code': 3002, 'message': 'native failure'};
      expect(await operation.value(), response);
      response = PlatformException(code: 'BRIDGE_ERROR', message: 'failed');
      expect(await operation.value(),
          {'code': -1, 'message': '${operation.key}: failed'});
    });
  }

  final objectArrayOperations =
      <String, Future<Map<dynamic, dynamic>> Function()>{
    '更新对象数组元素失败': () => FlutterPluginEngagelabMa.updateObjectArrayProperty(
          property: 'devices',
          identifierKey: 'id',
          identifierValue: '1',
          values: <String, Object?>{'name': 'new'},
        ),
    '追加对象数组元素失败': () => FlutterPluginEngagelabMa.appendObjectArrayProperty(
          property: 'devices',
          object: <String, Object?>{'id': '1'},
        ),
    '移除对象数组元素失败': () => FlutterPluginEngagelabMa.removeObjectArrayProperty(
          property: 'devices',
          identifierKey: 'id',
          identifierValue: '1',
        ),
  };

  for (final operation in objectArrayOperations.entries) {
    test('${operation.key}: keeps native business results unchanged', () async {
      for (final nativeResult in <Map<String, dynamic>>[
        {'code': 0, 'message': ''},
        {'code': -1, 'message': '{"code":3002,"message":"rejected"}'},
        {'code': 3002, 'message': 'rejected'},
      ]) {
        response = nativeResult;
        expect(await operation.value(), nativeResult);
      }
    });

    test('${operation.key}: converts bridge exceptions like legacy properties',
        () async {
      response = PlatformException(code: 'ERROR', message: 'bridge failure');
      expect(await operation.value(), {
        'code': -1,
        'message': '${operation.key}: bridge failure',
      });
    });
  }

  test('channel keeps native errors and throws bridge errors like contact API',
      () async {
    Future<Map<dynamic, dynamic>> invoke() =>
        FlutterPluginEngagelabMa.setChannelValue(
          channelId: 7,
          values: ['token'],
        );
    response = <String, dynamic>{'code': -5, 'message': 'native failure'};
    expect(await invoke(), response);
    response = PlatformException(code: 'ERROR', message: 'bridge failure');
    await expectLater(
        invoke(),
        throwsA(isA<PlatformException>()
            .having((e) => e.code, 'code', 'ERROR')
            .having((e) => e.message, 'message', '设置渠道标识失败: bridge failure')));
  });

  test('Android debug mode forwards enable and disable', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    response = null;
    for (final enable in <bool>[true, false]) {
      await FlutterPluginEngagelabMa.configDebugMode(enable);
      expect(lastCall?.method, 'configDebugMode');
      expect(lastCall?.arguments, <String, bool>{'enable': enable});
    }
  });

  test('iOS debug mode reports unsupported without invoking native code',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await expectLater(
        FlutterPluginEngagelabMa.configDebugMode(true), throwsUnsupportedError);
    expect(lastCall, isNull);
  });

  test('start passes the MA AppKey and returns initialization fields',
      () async {
    response = <String, dynamic>{
      'code': 0,
      'message': 'success',
      'euid': 'euid-1',
      'maRid': 'ma-rid-1',
      'success': true,
    };

    final result = await FlutterPluginEngagelabMa.start(
      appKey: 'ma-app-key',
      userId: 'user-1',
      anonymousId: 'anonymous-1',
      email: 'user@example.com',
      phone: '+8613800138000',
    );

    expect(lastCall?.method, 'start');
    expect(lastCall?.arguments, <String, dynamic>{
      'appKey': 'ma-app-key',
      'userId': 'user-1',
      'anonymousId': 'anonymous-1',
      'email': 'user@example.com',
      'phone': '+8613800138000',
    });
    expect(result, response);
  });

  test('start keeps a native failure result', () async {
    response = <String, dynamic>{
      'code': -2,
      'message': 'invalid appKey',
      'euid': '',
      'maRid': '',
      'success': false,
    };

    final result = await FlutterPluginEngagelabMa.start(
      appKey: 'invalid-app-key',
    );

    expect(result, response);
  });

  test('start rejects an empty appKey', () {
    expect(FlutterPluginEngagelabMa.start(appKey: '  '), throwsArgumentError);
  });

  test('setUserIdentity forwards all supported identity fields', () async {
    await FlutterPluginEngagelabMa.setUserIdentity(
      userId: 'user-1',
      anonymousId: 'anonymous-1',
      email: 'user@example.com',
      phone: '+8613800138000',
    );

    expect(lastCall?.method, 'setUserIdentity');
    expect(lastCall?.arguments, <String, dynamic>{
      'userId': 'user-1',
      'anonymousId': 'anonymous-1',
      'email': 'user@example.com',
      'phone': '+8613800138000',
    });
  });

  test('getMaRid maps native null to an empty string', () async {
    response = null;

    expect(await FlutterPluginEngagelabMa.getMaRid(), '');
    expect(lastCall?.method, 'getMaRid');
  });

  test('getEuid maps native null to an empty string', () async {
    response = null;

    expect(await FlutterPluginEngagelabMa.getEuid(), '');
    expect(lastCall?.method, 'getEuid');
  });

  test('setChannelValue validates and forwards arguments', () async {
    response = <String, dynamic>{'code': 0, 'message': 'success'};

    final result = await FlutterPluginEngagelabMa.setChannelValue(
      channelId: 7,
      values: <String>['token-1'],
    );

    expect(lastCall?.method, 'setChannelValue');
    expect(lastCall?.arguments, <String, dynamic>{
      'channelId': 7,
      'values': <String>['token-1'],
    });
    expect(result, response);
    expect(
      FlutterPluginEngagelabMa.setChannelValue(
        channelId: 0,
        values: <String>['token-1'],
      ),
      throwsArgumentError,
    );
    expect(
      FlutterPluginEngagelabMa.setChannelValue(
        channelId: 7,
        values: <String>[],
      ),
      throwsArgumentError,
    );
    expect(
      FlutterPluginEngagelabMa.setChannelValue(
        channelId: 7,
        values: <String>['  '],
      ),
      throwsArgumentError,
    );
  });

  test('channel tokens are normalized consistently on both platforms',
      () async {
    for (final platform in <TargetPlatform>[
      TargetPlatform.android,
      TargetPlatform.iOS,
    ]) {
      debugDefaultTargetPlatformOverride = platform;
      final tokens = <String>[' token-1 ', '\ttoken-2\n'];
      await FlutterPluginEngagelabMa.setChannelValue(
        channelId: 4294967297,
        values: tokens,
      );
      expect(lastCall?.arguments, <String, dynamic>{
        'channelId': 4294967297,
        'values': <String>['token-1', 'token-2'],
      });
      expect(tokens, <String>[' token-1 ', '\ttoken-2\n']);
    }
  });

  test('updateObjectArrayProperty forwards identifier and nullable fields',
      () async {
    response = <String, dynamic>{'code': 0, 'message': 'success'};

    final result = await FlutterPluginEngagelabMa.updateObjectArrayProperty(
      property: 'devices',
      identifierKey: 'device_id',
      identifierValue: 'device-1',
      values: <String, Object?>{
        'enabled': false,
        'legacy_name': null,
      },
    );

    expect(lastCall?.method, 'updateObjectArrayProperty');
    expect(lastCall?.arguments, <String, dynamic>{
      'property': 'devices',
      'identifierKey': 'device_id',
      'identifierValue': 'device-1',
      'values': <String, Object?>{
        'enabled': false,
        'legacy_name': null,
      },
    });
    expect(result, response);
  });

  test('appendObjectArrayProperty forwards one object element', () async {
    final result = await FlutterPluginEngagelabMa.appendObjectArrayProperty(
      property: 'devices',
      object: <String, Object?>{
        'device_id': 'device-2',
        'year': 2026,
      },
    );

    expect(lastCall?.method, 'appendObjectArrayProperty');
    expect(lastCall?.arguments, <String, dynamic>{
      'property': 'devices',
      'object': <String, Object?>{
        'device_id': 'device-2',
        'year': 2026,
      },
    });
    expect(result, response);
  });

  test('removeObjectArrayProperty forwards a numeric identifier', () async {
    final result = await FlutterPluginEngagelabMa.removeObjectArrayProperty(
      property: 'devices',
      identifierKey: 'sequence',
      identifierValue: 2,
    );

    expect(lastCall?.method, 'removeObjectArrayProperty');
    expect(lastCall?.arguments, <String, dynamic>{
      'property': 'devices',
      'identifierKey': 'sequence',
      'identifierValue': 2,
    });
    expect(result, response);
  });

  test('object_array APIs reject invalid arguments', () {
    expect(
      FlutterPluginEngagelabMa.updateObjectArrayProperty(
        property: 'devices',
        identifierKey: 'device_id',
        identifierValue: 'device-1',
        values: <String, Object?>{'device_id': 'device-2'},
      ),
      throwsArgumentError,
    );
    expect(
      FlutterPluginEngagelabMa.appendObjectArrayProperty(
        property: 'devices',
        object: <String, Object?>{},
      ),
      throwsArgumentError,
    );
    expect(
      FlutterPluginEngagelabMa.appendObjectArrayProperty(
        property: 'devices',
        object: <String, Object?>{'legacy_name': null},
      ),
      throwsArgumentError,
    );
    expect(
      FlutterPluginEngagelabMa.removeObjectArrayProperty(
        property: 'devices',
        identifierKey: 'device_id',
        identifierValue: true,
      ),
      throwsArgumentError,
    );
    expect(
      FlutterPluginEngagelabMa.removeObjectArrayProperty(
        property: 'devices',
        identifierKey: 'sequence',
        identifierValue: double.infinity,
      ),
      throwsArgumentError,
    );
  });
}
