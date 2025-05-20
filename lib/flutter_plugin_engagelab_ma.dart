import 'package:flutter/services.dart';

class FlutterPluginEngagelabMa {
  static const MethodChannel _channel =
      MethodChannel('flutter_plugin_engagelab_ma');

  /// 启动 EngageLab MA 服务
  static Future<Map<dynamic, dynamic>> start(
      {String? userId, String? anonymousId}) async {
    try {
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('start', {
        'userId': userId,
        'anonymousId': anonymousId,
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
  static Future<Map<dynamic, dynamic>> setUserIdentity(
      {String? userId, String? anonymousId}) async {
    try {
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('setUserIdentity', {
        'userId': userId,
        'anonymousId': anonymousId,
      });
      return result;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: '设置用户身份失败: ${e.message}',
      );
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
      final String euid = await _channel.invokeMethod('getEuid');
      return euid;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: '获取 EUID 失败: ${e.message}',
      );
    }
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
