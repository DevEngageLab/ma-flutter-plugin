package cn.jiguang.hxhg.flutter_plugin_engagelab_ma;

import androidx.annotation.NonNull;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import org.json.JSONArray;
import org.json.JSONObject;

import com.engagelab.privates.push.oth.ma.api.MTMAApi;
import com.engagelab.privates.push.oth.ma.api.MTMACollectControl;
import com.engagelab.privates.push.oth.ma.api.UserIdentity;
import com.engagelab.privates.push.oth.ma.api.UtmProperties;
import com.engagelab.privates.push.oth.ma.api.CallBack;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/** FlutterPluginEngagelabMaPlugin */
public class FlutterPluginEngagelabMaPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private FlutterPluginBinding flutterPluginBinding;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.flutterPluginBinding = flutterPluginBinding;
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_plugin_engagelab_ma");
    channel.setMethodCallHandler(this);
  }

  private static class MTMACallBack extends CallBack {
    Result result;
    public MTMACallBack(Result result) {
      this.result = result;
    }
    @Override
    public void onCallBack(int i, String s) {
      Map<String, Object> resultMap = new HashMap<>();
      resultMap.put("code", i);
      resultMap.put("message", s);
      result.success(resultMap);
    }
  }



  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("start")) {
      UserIdentity userIdentity = new UserIdentity();
      String userId = call.argument("userId"); // 可能返回 null
      if (userId != null) {
        userIdentity.setUserId(userId);
      }
      String anonymousId = call.argument("anonymousId"); // 可能返回 null
      if (anonymousId != null) {
        userIdentity.setAnonymousId(anonymousId);
      }
      MTMAApi.getInstance(flutterPluginBinding.getApplicationContext()).start(userIdentity,new MTMACallBack(result));
    } else if (call.method.equals("setUserIdentity")) {
      UserIdentity userIdentity = new UserIdentity();
      String userId = call.argument("userId"); // 可能返回 null
      if (userId != null) {
        userIdentity.setUserId(userId);
      }
      String anonymousId = call.argument("anonymousId"); // 可能返回 null
      if (anonymousId != null) {
        userIdentity.setAnonymousId(anonymousId);
      }
      MTMAApi.getInstance(flutterPluginBinding.getApplicationContext()).setUserIdentity(userIdentity, new MTMACallBack(result));
    } else if (call.method.equals("setUserContact")) {
      try {
        Map<String, Object> arguments = call.arguments();
        JSONObject contacts = new JSONObject();
        // 遍历 Map
        for (Map.Entry<String, Object> entry : arguments.entrySet()) {
          String key = entry.getKey();
          Object value = entry.getValue();
          contacts.put(key, value);
        }
        MTMAApi.getInstance(flutterPluginBinding.getApplicationContext()).setUserContact(contacts, new MTMACallBack(result));
      } catch (Exception e) {
        result.error("ERROR", e.getMessage(), null);
      }
    } else if (call.method.equals("getEuid")) {
      String euid = MTMAApi.getInstance(flutterPluginBinding.getApplicationContext()).getEuid();
      result.success(euid);
    } else if (call.method.equals("setReportInterval")) {
      Integer interval = call.argument("interval");
      MTMAApi.getInstance(flutterPluginBinding.getApplicationContext()).setReportInterval(interval);
      result.success(true);
    } else if (call.method.equals("setMaxEventCacheCount")) {
      Integer count = call.argument("count");
      MTMAApi.getInstance(flutterPluginBinding.getApplicationContext()).setMaxEventCacheCount(count);
      result.success(true);
    } else if (call.method.equals("setNoActiveSessionEndDurationTime")) {
      Integer duration = call.argument("duration");
      MTMAApi.getInstance(flutterPluginBinding.getApplicationContext()).setNoActiveSessionEndDurationTime(duration);
      result.success(true);
    } else if (call.method.equals("setUtmProperties")) {
      UtmProperties utmProperties = new UtmProperties();
      utmProperties.setUtmSource((String) call.argument("utm_source"));
      utmProperties.setUtmMedium((String) call.argument("utm_medium"));
      utmProperties.setUtmTerm((String) call.argument("utm_term"));
      utmProperties.setUtmContent((String) call.argument("utm_content"));
      utmProperties.setUtmCampaign((String) call.argument("utm_campaign"));
      utmProperties.setUtmId((String) call.argument("utm_id"));
      MTMAApi.getInstance(flutterPluginBinding.getApplicationContext()).setUtmProperties(utmProperties);
      result.success(true);
    } else if (call.method.equals("setUserProperties")) {
      try {
        Map<String, Object> arguments = call.arguments();
        Map<String, Object> properties = (Map<String, Object>) arguments.get("properties");

        JSONObject jsonObject = new JSONObject();
        for (Map.Entry<String, Object> entry : properties.entrySet()) {
          String key = entry.getKey();
          Object value = entry.getValue();
          // 处理不同类型的值
          if (value instanceof List) {
            jsonObject.put(key, new JSONArray((List<?>) value));
          } else if (value instanceof Map) {
            jsonObject.put(key, new JSONObject((Map<?, ?>) value));
          } else {
            jsonObject.put(key, value);
          }
        }
        MTMAApi.getInstance(flutterPluginBinding.getApplicationContext())
                .propertySet(jsonObject, new MTMACallBack(result));
      } catch (Exception e) {
        Map<String, Object> response = new HashMap<>();
        response.put("code", -1);
        response.put("message", "覆盖更新用户属性失败: " + e.getMessage());
        result.success(response);
      }
    } else if (call.method.equals("incrementUserProperties")) {
      try {
        Map<String, Object> arguments = call.arguments();
        Map<String, Number> properties = (Map<String, Number>) arguments.get("properties");

        MTMAApi.getInstance(flutterPluginBinding.getApplicationContext())
                .propertyIncrease(properties, new MTMACallBack(result));
      } catch (Exception e) {
        Map<String, Object> response = new HashMap<>();
        response.put("code", -1);
        response.put("message", "累加更新用户属性失败: " + e.getMessage());
        result.success(response);
      }
    } else if (call.method.equals("appendUserProperties")) {
      try {
        Map<String, Object> arguments = call.arguments();
        String property = (String) arguments.get("property");
        List<String> valuelist = (List<String>) arguments.get("value");
        Set<String> value = new HashSet<>(valuelist);
        MTMAApi.getInstance(flutterPluginBinding.getApplicationContext())
                .propertyAdd(property,value, new MTMACallBack(result));
      } catch (Exception e) {
        Map<String, Object> response = new HashMap<>();
        response.put("code", -1);
        response.put("message", "追加用户属性失败: " + e.getMessage());
        result.success(response);
      }
    } else if (call.method.equals("removeUserProperties")) {
      try {
        Map<String, Object> arguments = call.arguments();
        String property = (String) arguments.get("property");
        List<String> valuelist = (List<String>) arguments.get("value");

        Set<String> value = new HashSet<>(valuelist);

        MTMAApi.getInstance(flutterPluginBinding.getApplicationContext())
                .propertyRemove(property,value, new MTMACallBack(result));
      } catch (Exception e) {
        Map<String, Object> response = new HashMap<>();
        response.put("code", -1);
        response.put("message", "移除用户属性失败: " + e.getMessage());
        result.success(response);
      }
    } else if (call.method.equals("deleteUserProperty")) {
      try {
        Map<String, Object> arguments = call.arguments();
        String property = (String) arguments.get("property");

        MTMAApi.getInstance(flutterPluginBinding.getApplicationContext())
                .propertyDelete(property, new MTMACallBack(result));
      } catch (Exception e) {
        Map<String, Object> response = new HashMap<>();
        response.put("code", -1);
        response.put("message", "删除用户属性失败: " + e.getMessage());
        result.success(response);
      }
    } else if (call.method.equals("eventRecord")) {
      try {
        Map<String, Object> arguments = call.arguments();
        String eventKey = (String) arguments.get("eventName");
        Map<String, Object> properties = (Map<String, Object>) arguments.get("property");
        JSONObject jsonObject = new JSONObject();
        for (Map.Entry<String, Object> entry : properties.entrySet()) {
          String key = entry.getKey();
          Object value = entry.getValue();
          // 处理不同类型的值
          if (value instanceof List) {
            jsonObject.put(key, new JSONArray((List<?>) value));
          } else if (value instanceof Map) {
            jsonObject.put(key, new JSONObject((Map<?, ?>) value));
          } else {
            jsonObject.put(key, value);
          }
        }
        MTMAApi.getInstance(flutterPluginBinding.getApplicationContext()).onEvent(eventKey, jsonObject);
        result.success(true);
      } catch (Exception e) {
        Map<String, Object> response = new HashMap<>();
        response.put("code", -1);
        response.put("message", "自定义事件上报失败: " + e.getMessage());
        result.success(response);
      }
    } else if (call.method.equals("setCollectControl")) {
      boolean imei = call.argument("imei");
      boolean aaid = call.argument("aaid");
      boolean oaid = call.argument("oaid");
      boolean gaid = call.argument("gaid");
      boolean mac_address = call.argument("macAddress");
      boolean carrier = call.argument("carrier");
      try {
        MTMACollectControl mtmaCollectControl = new MTMACollectControl();
        mtmaCollectControl.setIMEI(imei);
        mtmaCollectControl.setAAID(aaid);
        mtmaCollectControl.setOAID(oaid);
        mtmaCollectControl.setGAID(gaid);
        mtmaCollectControl.setMacAddress(mac_address);
        mtmaCollectControl.setCarrier(carrier);
        MTMAApi.getInstance(flutterPluginBinding.getApplicationContext()).setCollectControl(mtmaCollectControl);
      } catch (Throwable e) {e.printStackTrace();
      }
      result.success(true);

    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
