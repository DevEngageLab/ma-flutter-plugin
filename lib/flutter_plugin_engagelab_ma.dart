import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FlutterPluginEngagelabMa {
  static const MethodChannel _channel =
      MethodChannel('flutter_plugin_engagelab_ma');

  /// 设置独立 MA 调试日志（仅 Android MA 5.5.0+，默认关闭）。
  /// 在 start 前调用可观察初始化日志；此开关独立于 Push 日志。
  /// iOS 和其他平台抛出 UnsupportedError。
  static Future<void> configDebugMode(bool enable) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError('MA configDebugMode is only supported on Android');
    }
    await _channel.invokeMethod<void>('configDebugMode', {'enable': enable});
  }

  /// 启动 EngageLab MA 服务
  /// 原生初始化失败仍返回结果 Map；仅桥接异常补充文案后抛出。
  /// 独立版必须传 MA AppKey，结果增加 euid、maRid、success。
  static Future<Map<dynamic, dynamic>> start({
    required String appKey,
    String? userId,
    String? anonymousId,
    String? email,
    String? phone,
  }) async {
    if (appKey.trim().isEmpty) {
      throw ArgumentError.value(appKey, 'appKey', 'must not be empty');
    }
    try {
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('start', {
        'appKey': appKey,
        'userId': userId,
        'anonymousId': anonymousId,
        'email': email,
        'phone': phone,
      });
      return result;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: '启动 EngageLab MA 服务失败: ${e.message}',
      );
    }
  }

  /// 设置用户身份
  static Future<Map<dynamic, dynamic>> setUserIdentity({
    String? userId,
    String? anonymousId,
    String? email,
    String? phone,
  }) async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'setUserIdentity',
        {
          'userId': userId,
          'anonymousId': anonymousId,
          'email': email,
          'phone': phone,
        },
      );
      return result;
    } on PlatformException catch (e) {
      throw PlatformException(code: e.code, message: '设置用户身份失败: ${e.message}');
    }
  }

  /// 设置用户联系方式
  static Future<Map<dynamic, dynamic>> setUserContact(
      Map<String, String> contacts) async {
    try {
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('setUserContact', {
        'contacts': contacts,
      });
      return result;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: '设置用户联系方式失败: ${e.message}',
      );
    }
  }

  /// 获取 EUID
  static Future<String> getEuid() async {
    try {
      final String? euid = await _channel.invokeMethod('getEuid');
      return euid ?? '';
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: '获取 EUID 失败: ${e.message}',
      );
    }
  }

  /// 获取 MA RID（Android/iOS 5.5.0+）
  static Future<String> getMaRid() async {
    try {
      final String? maRid = await _channel.invokeMethod('getMaRid');
      return maRid ?? '';
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: '获取 MA RID 失败: ${e.message}',
      );
    }
  }

  /// 设置第三方 Push 渠道的 RID 或 Token（Android/iOS 5.5.0+）
  /// 两端统一去除每个值的首尾空白，不修改调用方的列表。
  static Future<Map<dynamic, dynamic>> setChannelValue({
    required int channelId,
    required List<String> values,
  }) async {
    if (channelId <= 0) {
      throw ArgumentError.value(
        channelId,
        'channelId',
        'must be greater than 0',
      );
    }
    final normalizedValues = values.map((value) => value.trim()).toList();
    if (normalizedValues.isEmpty ||
        normalizedValues.any((value) => value.isEmpty)) {
      throw ArgumentError.value(
        values,
        'values',
        'must contain non-empty values',
      );
    }
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'setChannelValue',
        {'channelId': channelId, 'values': normalizedValues},
      );
      return result;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: '设置渠道标识失败: ${e.message}',
      );
    }
  }

  /// 按唯一标识更新 object_array 中一个对象的子字段（Android/iOS 5.5.0+）。
  ///
  /// [values] 中的 `null` 表示删除对应子字段；不能修改 [identifierKey]。
  static Future<Map<dynamic, dynamic>> updateObjectArrayProperty({
    required String property,
    required String identifierKey,
    required Object identifierValue,
    required Map<String, Object?> values,
  }) async {
    _validateObjectArrayName(property, 'property');
    _validateObjectArrayName(identifierKey, 'identifierKey');
    _validateObjectArrayIdentifier(identifierValue);
    if (values.isEmpty) {
      throw ArgumentError.value(values, 'values', 'must not be empty');
    }
    if (values.containsKey(identifierKey)) {
      throw ArgumentError.value(
        values,
        'values',
        'must not modify identifierKey',
      );
    }
    try {
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('updateObjectArrayProperty', {
        'property': property,
        'identifierKey': identifierKey,
        'identifierValue': identifierValue,
        'values': values,
      });
      return result;
    } on PlatformException catch (e) {
      return {'code': -1, 'message': '更新对象数组元素失败: ${e.message}'};
    }
  }

  /// 向 object_array 追加一个对象元素（Android/iOS 5.5.0+）。
  static Future<Map<dynamic, dynamic>> appendObjectArrayProperty({
    required String property,
    required Map<String, Object?> object,
  }) async {
    _validateObjectArrayName(property, 'property');
    if (object.isEmpty || object.values.every((value) => value == null)) {
      throw ArgumentError.value(
        object,
        'object',
        'must contain at least one non-null field',
      );
    }
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'appendObjectArrayProperty',
        {'property': property, 'object': object},
      );
      return result;
    } on PlatformException catch (e) {
      return {'code': -1, 'message': '追加对象数组元素失败: ${e.message}'};
    }
  }

  /// 按唯一标识移除 object_array 中一个完整对象元素（Android/iOS 5.5.0+）。
  static Future<Map<dynamic, dynamic>> removeObjectArrayProperty({
    required String property,
    required String identifierKey,
    required Object identifierValue,
  }) async {
    _validateObjectArrayName(property, 'property');
    _validateObjectArrayName(identifierKey, 'identifierKey');
    _validateObjectArrayIdentifier(identifierValue);
    try {
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('removeObjectArrayProperty', {
        'property': property,
        'identifierKey': identifierKey,
        'identifierValue': identifierValue,
      });
      return result;
    } on PlatformException catch (e) {
      return {'code': -1, 'message': '移除对象数组元素失败: ${e.message}'};
    }
  }

  static void _validateObjectArrayName(String value, String argumentName) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, argumentName, 'must not be empty');
    }
  }

  static void _validateObjectArrayIdentifier(Object value) {
    if (value is String) {
      return;
    }
    if (value is num && value.isFinite) {
      return;
    }
    throw ArgumentError.value(
      value,
      'identifierValue',
      'must be a string or a finite number',
    );
  }

  /// 设置上报间隔
  static Future<bool> setReportInterval(int interval) async {
    try {
      await _channel.invokeMethod('setReportInterval', {
        'interval': interval,
      });
      return true;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: '设置上报间隔失败: ${e.message}',
      );
    }
  }

  /// 设置事件缓存上限
  static Future<bool> setMaxEventCacheCount(int count) async {
    try {
      await _channel.invokeMethod('setMaxEventCacheCount', {
        'count': count,
      });
      return true;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: '设置事件缓存上限失败: ${e.message}',
      );
    }
  }

  /// 设置会话超时时间
  static Future<bool> setNoActiveSessionEndDurationTime(int duration) async {
    try {
      await _channel.invokeMethod('setNoActiveSessionEndDurationTime', {
        'duration': duration,
      });
      return true;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: '设置会话超时时间失败: ${e.message}',
      );
    }
  }

  /// 设置 UTM 属性
  static Future<bool> setUtmProperties({
    String? utmSource,
    String? utmMedium,
    String? utmTerm,
    String? utmContent,
    String? utmCampaign,
    String? utmId,
  }) async {
    try {
      await _channel.invokeMethod('setUtmProperties', {
        'utm_source': utmSource,
        'utm_medium': utmMedium,
        'utm_term': utmTerm,
        'utm_content': utmContent,
        'utm_campaign': utmCampaign,
        'utm_id': utmId,
      });
      return true;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: '设置 UTM 属性失败: ${e.message}',
      );
    }
  }

  // 覆盖更新用户属性
  static Future<Map<dynamic, dynamic>> setUserProperties(properties) async {
    try {
      final Map<dynamic, dynamic> result = await _channel
          .invokeMethod('setUserProperties', {'properties': properties});
      return result;
    } on PlatformException catch (e) {
      return {'code': -1, 'message': '覆盖更新用户属性失败: ${e.message}'};
    }
  }

  // 累加更新用户属性
  static Future<Map<dynamic, dynamic>> incrementUserProperties(
      properties) async {
    try {
      final Map<dynamic, dynamic> result = await _channel
          .invokeMethod('incrementUserProperties', {'properties': properties});
      return result;
    } on PlatformException catch (e) {
      return {'code': -1, 'message': '累加更新用户属性失败: ${e.message}'};
    }
  }

  // 追加用户属性
  static Future<Map<dynamic, dynamic>> appendUserProperties(
      {required String property, required List values}) async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
          'appendUserProperties', {'property': property, "value": values});
      return result;
    } on PlatformException catch (e) {
      return {'code': -1, 'message': '追加用户属性失败: ${e.message}'};
    }
  }

  // 移除用户属性
  static Future<Map<dynamic, dynamic>> removeUserProperties(
      {required String property, required List values}) async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
          'removeUserProperties', {'property': property, "value": values});
      return result;
    } on PlatformException catch (e) {
      return {'code': -1, 'message': '移除用户属性失败: ${e.message}'};
    }
  }

  // 删除用户属性
  static Future<Map<dynamic, dynamic>> deleteUserProperty(
      String property) async {
    try {
      final Map<dynamic, dynamic> result = await _channel
          .invokeMethod('deleteUserProperty', {'property': property});
      return result;
    } on PlatformException catch (e) {
      return {'code': -1, 'message': '删除用户属性失败: ${e.message}'};
    }
  }

  // 自定义事件上报
  static Future<bool> eventRecord(
      {required String eventName, required Map property}) async {
    try {
      await _channel.invokeMethod('eventRecord', {
        'eventName': eventName,
        'property': property,
      });
      return true;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: '自定义事件上报失败: ${e.message}',
      );
    }
  }

// 设置采集权限
  static Future<bool> setCollectControl({
    bool idfa = false,
    bool idfv = false,
    bool carrier = true,
    bool imei = true,
    bool aaid = true,
    bool gaid = true,
    bool oaid = true,
    bool macAddress = true,
  }) async {
    try {
      await _channel.invokeMethod('setCollectControl', {
        'idfa': idfa,
        'idfv': idfv,
        'carrier': carrier,
        'imei': imei,
        'aaid': aaid,
        'gaid': gaid,
        'oaid': oaid,
        "macAddress": macAddress,
      });
      return true;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: '设置采集权限失败: ${e.message}',
      );
    }
  }
}
