package cn.jiguang.hxhg.flutter_plugin_engagelab_ma;

import static org.junit.Assert.assertTrue;
import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import com.engagelab.privates.push.oth.ma.api.MTMAApi;
import com.engagelab.privates.push.oth.ma.api.MTMAConfig;
import com.engagelab.privates.push.oth.ma.api.MTMAInitResultCallback;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;
import org.json.JSONObject;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.MockedStatic;

/**
 * This demonstrates a simple unit test of the Java portion of this plugin's implementation.
 *
 * Once you have built the plugin's example app, you can run these tests from the command
 * line by running `./gradlew testDebugUnitTest` in the `example/android/` directory, or
 * you can run them directly from IDEs that support JUnit such as Android Studio.
 */

public class FlutterPluginEngagelabMaPluginTest {
  private static final String COLLECTION_KEY = "dataCollectionEnabled";

  private FlutterPluginEngagelabMaPlugin pluginWithContext(Context context) throws Exception {
    FlutterPluginEngagelabMaPlugin plugin = new FlutterPluginEngagelabMaPlugin();
    FlutterPlugin.FlutterPluginBinding binding = mock(FlutterPlugin.FlutterPluginBinding.class);
    when(binding.getApplicationContext()).thenReturn(context);
    Field field = FlutterPluginEngagelabMaPlugin.class.getDeclaredField("flutterPluginBinding");
    field.setAccessible(true);
    field.set(plugin, binding);
    return plugin;
  }

  @Test
  public void start_passesExplicitCollectionChoiceAndPreservesUnsetDefault() throws Exception {
    Context context = mock(Context.class);
    FlutterPluginEngagelabMaPlugin plugin = pluginWithContext(context);
    Method choiceGetter = MTMAConfig.class.getDeclaredMethod("getDataCollectionEnabled");
    choiceGetter.setAccessible(true);
    for (Boolean enabled : new Boolean[] {null, false, true}) {
      MTMAApi api = mock(MTMAApi.class);
      try (MockedStatic<MTMAApi> factory = mockStatic(MTMAApi.class)) {
        factory.when(() -> MTMAApi.getInstance(context)).thenReturn(api);
        Map<String, Object> arguments = new HashMap<>();
        arguments.put("appKey", "0123456789abcdef01234567");
        if (enabled != null) arguments.put(COLLECTION_KEY, enabled);
        plugin.onMethodCall(new MethodCall("start", arguments), mock(MethodChannel.Result.class));
        ArgumentCaptor<MTMAConfig> config = ArgumentCaptor.forClass(MTMAConfig.class);
        verify(api).start(config.capture(), any(MTMAInitResultCallback.class));
        assertEquals(enabled, choiceGetter.invoke(config.getValue()));
      }
    }
  }

  @Test
  public void collectionSwitch_usesNativeSetterAndQueriesNativeState() throws Exception {
    Context context = mock(Context.class);
    FlutterPluginEngagelabMaPlugin plugin = pluginWithContext(context);
    MTMAApi api = mock(MTMAApi.class);
    try (MockedStatic<MTMAApi> factory = mockStatic(MTMAApi.class)) {
      factory.when(() -> MTMAApi.getInstance(context)).thenReturn(api);
      for (boolean enabled : new boolean[] {false, true}) {
        Map<String, Object> arguments = new HashMap<>();
        arguments.put(COLLECTION_KEY, enabled);
        MethodChannel.Result setterResult = mock(MethodChannel.Result.class);
        plugin.onMethodCall(new MethodCall("setDataCollectionEnabled", arguments), setterResult);
        verify(api).setDataCollectionEnabled(enabled);
        verify(setterResult).success(null);
        // The query must use the SDK result, rather than echo the last setter argument.
        when(api.isDataCollectionEnabled()).thenReturn(!enabled);
        MethodChannel.Result queryResult = mock(MethodChannel.Result.class);
        plugin.onMethodCall(new MethodCall("isDataCollectionEnabled", null), queryResult);
        verify(queryResult).success(!enabled);
      }
    }
  }

  @Test
  public void collectionSwitch_rejectsMissingOrNonBooleanValues() {
    FlutterPluginEngagelabMaPlugin plugin = new FlutterPluginEngagelabMaPlugin();
    for (Object value : new Object[] {null, 0, 1, "false"}) {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put(COLLECTION_KEY, value);
      MethodChannel.Result result = mock(MethodChannel.Result.class);
      plugin.onMethodCall(new MethodCall("setDataCollectionEnabled", arguments), result);
      verify(result).error("INVALID_ARGUMENT", "dataCollectionEnabled must be a boolean", null);
    }
  }

  /**
   * 版本号是编译期常量，这里验证的是通道接线：方法被路由、两个 key 都在、且不是占位值。
   * 常量字面量本身由原生 SDK 决定，本测试无法独立复算。
   */
  @Test
  public void getSdkVersion_reportsNativeConstantsWithoutInitialization() {
    FlutterPluginEngagelabMaPlugin plugin = new FlutterPluginEngagelabMaPlugin();
    MethodChannel.Result result = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("getSdkVersion", null), result);

    Map<String, Object> expected = new HashMap<>();
    expected.put("versionCode", MTMAApi.SDK_VERSION_CODE);
    expected.put("versionName", MTMAApi.SDK_VERSION_NAME);
    verify(result).success(expected);
    assertTrue(MTMAApi.SDK_VERSION_CODE > 0);
    assertTrue(MTMAApi.SDK_VERSION_NAME != null && !MTMAApi.SDK_VERSION_NAME.isEmpty());
  }

  @Test
  public void start_rejectsNonBooleanCollectionChoiceBeforeCallingSdk() {
    FlutterPluginEngagelabMaPlugin plugin = new FlutterPluginEngagelabMaPlugin();
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("appKey", "0123456789abcdef01234567");
    arguments.put(COLLECTION_KEY, "false");
    MethodChannel.Result result = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("start", arguments), result);
    verify(result).error("INVALID_ARGUMENT", "dataCollectionEnabled must be a boolean", null);
  }

  private static Map<String, Object> errorResult(String message) {
    Map<String, Object> expected = new HashMap<>();
    expected.put("code", -3);
    expected.put("message", message);
    return expected;
  }

  @Test
  public void onMethodCall_startWithoutAppKey_returnsClearError() {
    FlutterPluginEngagelabMaPlugin plugin = new FlutterPluginEngagelabMaPlugin();

    final MethodCall call = new MethodCall("start", new HashMap<String, Object>());
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(call, mockResult);

    Map<String, Object> expected = new HashMap<>();
    expected.put("code", -3);
    expected.put("message", "MA AppKey is required");
    expected.put("euid", "");
    expected.put("maRid", "");
    expected.put("success", false);
    verify(mockResult).success(expected);
  }

  @Test
  public void onMethodCall_updateObjectArrayWithIdentifierMutation_returnsValidationError() {
    FlutterPluginEngagelabMaPlugin plugin = new FlutterPluginEngagelabMaPlugin();
    Map<String, Object> values = new HashMap<>();
    values.put("device_id", "device-2");
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("property", "devices");
    arguments.put("identifierKey", "device_id");
    arguments.put("identifierValue", "device-1");
    arguments.put("values", values);

    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("updateObjectArrayProperty", arguments), mockResult);

    verify(mockResult).success(
            errorResult("object_array update parameters are invalid"));
  }

  @Test
  public void onMethodCall_appendEmptyObjectArrayElement_returnsValidationError() {
    FlutterPluginEngagelabMaPlugin plugin = new FlutterPluginEngagelabMaPlugin();
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("property", "devices");
    arguments.put("object", new HashMap<String, Object>());

    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("appendObjectArrayProperty", arguments), mockResult);

    verify(mockResult).success(
            errorResult("object_array append parameters are invalid"));
  }

  @Test
  public void onMethodCall_removeObjectArrayWithBooleanIdentifier_returnsValidationError() {
    FlutterPluginEngagelabMaPlugin plugin = new FlutterPluginEngagelabMaPlugin();
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("property", "devices");
    arguments.put("identifierKey", "device_id");
    arguments.put("identifierValue", true);

    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("removeObjectArrayProperty", arguments), mockResult);

    verify(mockResult).success(
            errorResult("object_array removal parameters are invalid"));
  }

  @Test
  public void createJsonObject_preservesNullAsJsonNull() throws Exception {
    Map<String, Object> values = new HashMap<>();
    values.put("legacy_name", null);

    JSONObject jsonObject = FlutterPluginEngagelabMaPlugin.createJsonObject(values);

    assertTrue(jsonObject.has("legacy_name"));
    assertTrue(jsonObject.isNull("legacy_name"));
  }
}
