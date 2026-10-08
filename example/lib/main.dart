import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_plugin_engagelab_ma/flutter_plugin_engagelab_ma.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String _maAppKeyOverride = String.fromEnvironment(
    'MA_APP_KEY',
  );
  static const int _channelIdOverride = int.fromEnvironment('MA_CHANNEL_ID');
  String get _maAppKey {
    if (_maAppKeyOverride.isNotEmpty) {
      return _maAppKeyOverride;
    }
    return '';
  }

  int get _channelId {
    if (_channelIdOverride > 0) {
      return _channelIdOverride;
    }
    return 0;
  }

  String _euid = 'Unknown';
  String _maRid = 'Unknown';
  bool _isInitialized = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeEngageLabMA();
  }

  Future<void> _initializeEngageLabMA() async {
    if (_maAppKey.isEmpty) {
      _statusMessage =
          '请通过 --dart-define=MA_APP_KEY=... 配置当前 SDK 环境对应的 MA AppKey';
      return;
    }
    try {
      // 设置采集权限
      FlutterPluginEngagelabMa.setCollectControl(
        idfa: false,
        idfv: false,
        carrier: true,
      );

      // Start the service
      final result = await FlutterPluginEngagelabMa.start(
        appKey: _maAppKey,
        userId: "test_user_123",
        anonymousId: "anon_456",
      );
      final msg =
          "MA启动结果: code=${result['code']}, message=${result['message']}, "
          "euid=${result['euid']}, maRid=${result['maRid']}";
      debugPrint(msg);
      final ret = result['success'] == true;

      setState(() {
        _isInitialized = ret;
        _euid = result['euid'] ?? '';
        _maRid = result['maRid'] ?? '';
        _statusMessage = msg;
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '初始化失败: ${e.message}';
      });
    }
  }

  // 设置用户身份
  Future<void> _setUserIdentity() async {
    try {
      final result = await FlutterPluginEngagelabMa.setUserIdentity(
        userId: "test_user_123",
        anonymousId: "anon_456",
      );
      final ret =
          'setUserIdentity结果: code=${result['code']}, message=${result['message']}';
      debugPrint(ret);

      setState(() {
        _statusMessage = ret;
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '设置用户身份失败: ${e.message}';
      });
    }
  }

  // 设置用户联系方式
  Future<void> _setUserContact() async {
    try {
      final result = await FlutterPluginEngagelabMa.setUserContact({
        "email": "test@example.com",
        "mobile_phone": "1234567890",
      });
      final ret =
          'setUserContact结果: code=${result['code']}, message=${result['message']}';
      debugPrint(ret);
      setState(() {
        _statusMessage = ret;
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '设置用户联系方式失败: ${e.message}';
      });
    }
  }

  // 获取 EUID
  Future<void> _getEuid() async {
    try {
      final euid = await FlutterPluginEngagelabMa.getEuid();
      setState(() {
        _euid = euid;
        _statusMessage = '获取 EUID 成功';
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '获取 EUID 失败: ${e.message}';
      });
    }
  }

  // 获取 MA RID
  Future<void> _getMaRid() async {
    try {
      final maRid = await FlutterPluginEngagelabMa.getMaRid();
      setState(() {
        _maRid = maRid;
        _statusMessage = '获取 MA RID 成功';
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '获取 MA RID 失败: ${e.message}';
      });
    }
  }

  // 设置第三方 Push 渠道。EngageLab AppPush 集成后由 MA 自动绑定。
  Future<void> _setChannelValue() async {
    try {
      final result = await FlutterPluginEngagelabMa.setChannelValue(
        channelId: _channelId,
        values: const <String>['flutter-demo-token'],
      );
      setState(() {
        _statusMessage = '设置第三方 Push 渠道结果: channelId=$_channelId, '
            'code=${result['code']}, message=${result['message']}';
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '设置第三方 Push 渠道失败: ${e.message}';
      });
    }
  }

  // 设置上报间隔
  Future<void> _setReportInterval() async {
    try {
      await FlutterPluginEngagelabMa.setReportInterval(10);
      setState(() {
        _statusMessage = '设置上报间隔成功';
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '设置上报间隔失败: ${e.message}';
      });
    }
  }

  // 设置事件缓存上限
  Future<void> _setMaxEventCacheCount() async {
    try {
      await FlutterPluginEngagelabMa.setMaxEventCacheCount(50);
      setState(() {
        _statusMessage = '设置事件缓存上限成功';
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '设置事件缓存上限失败: ${e.message}';
      });
    }
  }

  // 设置会话超时时间
  Future<void> _setNoActiveSessionEndDurationTime() async {
    try {
      await FlutterPluginEngagelabMa.setNoActiveSessionEndDurationTime(1800);
      setState(() {
        _statusMessage = '设置会话超时时间成功';
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '设置会话超时时间失败: ${e.message}';
      });
    }
  }

  // 设置 UTM 属性
  Future<void> _setUtmProperties() async {
    try {
      await FlutterPluginEngagelabMa.setUtmProperties(
        utmSource: "google",
        utmMedium: "cpc",
        utmCampaign: "spring_sale",
      );
      setState(() {
        _statusMessage = '设置 UTM 属性成功';
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '设置 UTM 属性失败: ${e.message}';
      });
    }
  }

  // 覆盖更新用户属性
  Future<void> _setUserProperties() async {
    try {
      final result = await FlutterPluginEngagelabMa.setUserProperties({
        'name': 'John Doe',
        'devices': <Map<String, Object?>>[
          <String, Object?>{
            'device_id': 'device_1',
            'enabled': true,
            'year': 2026,
          },
        ],
      });
      setState(() {
        _statusMessage =
            '覆盖更新用户属性结果: code=${result['code']}, message=${result['message']}';
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '覆盖更新用户属性失败: ${e.message}';
      });
    }
  }

  // 累加更新用户属性
  Future<void> _incrementUserProperties() async {
    try {
      final result = await FlutterPluginEngagelabMa.incrementUserProperties({
        'loginCount': 1,
        'points': 100,
      });
      setState(() {
        _statusMessage =
            '累加更新用户属性结果: code=${result['code']}, message=${result['message']}';
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '累加更新用户属性失败: ${e.message}';
      });
    }
  }

  // 追加用户属性
  Future<void> _appendUserProperties() async {
    try {
      final result = await FlutterPluginEngagelabMa.appendUserProperties(
        property: "interests",
        values: ['sports', 'music'],
      );
      setState(() {
        _statusMessage =
            '追加用户属性结果: code=${result['code']}, message=${result['message']}';
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '追加用户属性失败: ${e.message}';
      });
    }
  }

  // 移除用户属性
  Future<void> _removeUserProperties() async {
    try {
      final result = await FlutterPluginEngagelabMa.removeUserProperties(
        property: "interests",
        values: ['sports'],
      );
      setState(() {
        _statusMessage =
            '移除用户属性结果: code=${result['code']}, message=${result['message']}';
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '移除用户属性失败: ${e.message}';
      });
    }
  }

  Future<void> _updateObjectArrayProperty() async {
    try {
      final result = await FlutterPluginEngagelabMa.updateObjectArrayProperty(
        property: 'devices',
        identifierKey: 'device_id',
        identifierValue: 'device_1',
        values: <String, Object?>{'enabled': false, 'legacy_name': null},
      );
      setState(() {
        _statusMessage =
            '更新 object_array 元素结果: code=${result['code']}, message=${result['message']}';
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '更新 object_array 元素失败: ${e.message}';
      });
    }
  }

  Future<void> _appendObjectArrayProperty() async {
    try {
      final result = await FlutterPluginEngagelabMa.appendObjectArrayProperty(
        property: 'devices',
        object: <String, Object?>{'device_id': 'device_2', 'year': 2026},
      );
      setState(() {
        _statusMessage =
            '追加 object_array 元素结果: code=${result['code']}, message=${result['message']}';
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '追加 object_array 元素失败: ${e.message}';
      });
    }
  }

  Future<void> _removeObjectArrayProperty() async {
    try {
      final result = await FlutterPluginEngagelabMa.removeObjectArrayProperty(
        property: 'devices',
        identifierKey: 'device_id',
        identifierValue: 'device_2',
      );
      setState(() {
        _statusMessage =
            '删除 object_array 元素结果: code=${result['code']}, message=${result['message']}';
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '删除 object_array 元素失败: ${e.message}';
      });
    }
  }

  // 删除用户属性
  Future<void> _deleteUserProperties() async {
    try {
      final result = await FlutterPluginEngagelabMa.deleteUserProperty(
        "interests",
      );
      setState(() {
        _statusMessage =
            '删除用户属性结果: code=${result['code']}, message=${result['message']}';
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '删除用户属性失败: ${e.message}';
      });
    }
  }

  Future<void> _eventRecord() async {
    try {
      final result = await FlutterPluginEngagelabMa.eventRecord(
        eventName: "customevent",
        property: {"key1": "value1"},
      );
      setState(() {
        _statusMessage = '自定义事件成功: code=$result';
      });
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '自定义事件失败: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('EngageLab MA 示例')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 状态显示
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'EngageLab MA 状态:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isInitialized ? '已初始化' : '未初始化',
                        style: TextStyle(
                          color: _isInitialized ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('EUID: $_euid'),
                      const SizedBox(height: 8),
                      Text('MA RID: $_maRid'),
                      const SizedBox(height: 8),
                      const Text('如业务方另行集成并初始化 AppPush，MA 会在双方身份就绪后自动关联'),
                      const SizedBox(height: 8),
                      Text('第三方 Push Channel ID: $_channelId'),
                      const SizedBox(height: 8),
                      Text(
                        _statusMessage,
                        style: TextStyle(
                          color: _statusMessage.contains('失败')
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // API 按钮
              ElevatedButton(
                onPressed: _isInitialized ? _setUserIdentity : null,
                child: const Text('设置用户身份'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _setUserContact : null,
                child: const Text('设置用户联系方式'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _getEuid : null,
                child: const Text('获取 EUID'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _getMaRid : null,
                child: const Text('获取 MA RID'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed:
                    _isInitialized && _channelId > 0 ? _setChannelValue : null,
                child: const Text('设置第三方 Push 渠道'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _setReportInterval : null,
                child: const Text('设置上报间隔 (10秒)'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _setMaxEventCacheCount : null,
                child: const Text('设置事件缓存上限 (50条)'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed:
                    _isInitialized ? _setNoActiveSessionEndDurationTime : null,
                child: const Text('设置会话超时时间 (30分钟)'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _setUtmProperties : null,
                child: const Text('设置 UTM 属性'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _setUserProperties : null,
                child: const Text('覆盖更新用户属性'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _incrementUserProperties : null,
                child: const Text('累加更新用户属性'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _appendUserProperties : null,
                child: const Text('追加用户属性'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _removeUserProperties : null,
                child: const Text('移除用户属性'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _updateObjectArrayProperty : null,
                child: const Text('更新 object_array 元素'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _appendObjectArrayProperty : null,
                child: const Text('追加 object_array 元素'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _removeObjectArrayProperty : null,
                child: const Text('删除 object_array 元素'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _deleteUserProperties : null,
                child: const Text('删除用户属性'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _eventRecord : null,
                child: const Text('上报自定义事件'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
