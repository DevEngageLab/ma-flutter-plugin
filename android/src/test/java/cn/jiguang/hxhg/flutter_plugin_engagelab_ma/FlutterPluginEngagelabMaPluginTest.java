package cn.jiguang.hxhg.flutter_plugin_engagelab_ma;

import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;
import org.json.JSONObject;
import org.junit.Test;

/**
 * This demonstrates a simple unit test of the Java portion of this plugin's implementation.
 *
 * Once you have built the plugin's example app, you can run these tests from the command
 * line by running `./gradlew testDebugUnitTest` in the `example/android/` directory, or
 * you can run them directly from IDEs that support JUnit such as Android Studio.
 */

public class FlutterPluginEngagelabMaPluginTest {
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
