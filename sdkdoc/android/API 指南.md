# Android SDK API

## SDK 接口说明

- MTMAApi，包含 MA 功能的所有接口。

> 本页为独立版原生 Android MA SDK 的接口参考，与 `android/doc/mt-sdk-push/ma/API 指南.md` 对齐。Flutter 对应接口、参数约束和示例见 [Flutter API 文档](../../cndocuments/APIs.md)。下文旧接口的“开始支持版本”表示首次引入时间，不表示独立初始化从 5.0.0 起可用。

## 获取 SDK 版本

开始支持的版本：5.5.0

- `MTMAApi.SDK_VERSION_CODE`：MA SDK 数字版本号。
- `MTMAApi.SDK_VERSION_NAME`：MA SDK 字符串版本号。

```java
int versionCode = MTMAApi.SDK_VERSION_CODE;
String versionName = MTMAApi.SDK_VERSION_NAME;
```

## 设置调试模式

开始支持的版本：5.5.0

- **_configDebugMode(boolean enable)_**
  - 接口说明：开启或关闭 MA SDK 调试日志。
  - 参数说明：`enable` 为 `true` 时开启，为 `false` 时关闭。
  - 调用说明：建议在调用 `start` 前设置；发布版本建议关闭调试日志。

```java
MTMAApi.configDebugMode(true);
```

## 启用 MA 功能（独立版 5.5.0）

开始支持的版本：5.5.0

#### 接口定义

- **_start(MTMAConfig config, MTMAInitResultCallback callback)_**
  - 接口说明：使用 MA AppKey 初始化独立版 MA SDK，无需集成或等待 Push。
  - 参数说明：
    - `config`：初始化配置。
      - `MTMAConfig(String appKey)`：仅设置 MA AppKey。
      - `MTMAConfig(String appKey, UserIdentity userIdentity)`：设置 MA AppKey，并可同时设置用户标识。
    - `callback`：初始化结果回调。
  - 返回说明：`onResult(MTMAInitResult result)`
    - `isSuccess()`：初始化是否成功。
    - `getCode()`：结果码，`0` 表示成功。
    - `getMessage()`：结果描述。
    - `getEuid()`：初始化成功后取得的 EUID。
    - `getMaRid()`：初始化成功后取得的 MA RID。
  - 调用说明：
    - 服务端身份请求最终失败时，本次初始化回调失败；只有初始化成功后，其他 MA 业务 API 及身份查询接口才可用。
    - Android MA SDK 只支持在宿主应用主进程初始化。在非主进程调用 `start` 会通过回调返回失败，不会发起网络请求。

#### 调用示例

```java
MTMAConfig config = new MTMAConfig("your MA AppKey");
MTMAApi.getInstance(this).start(config, new MTMAInitResultCallback() {
    @Override
    public void onResult(MTMAInitResult result) {
        if (result.isSuccess()) {
            String euid = result.getEuid();
            String maRid = result.getMaRid();
        } else {
            int code = result.getCode();
            String message = result.getMessage();
        }
    }
});
```

#### 运行时切换 MA AppKey

在同一主进程内，上一次初始化回调完成后，可使用新的 `MTMAConfig` 再次调用 `start`。切换期间其他 MA 业务 API 暂不可用；新 AppKey 初始化失败时不会自动回退到旧 AppKey。

#### 废弃接口

从 5.5.0 开始，以下接口已废弃，独立版 MA SDK 不再使用，调用会返回 `CODE_VALID (-3)`：

- `start(CallBack callBack)`
- `start(UserIdentity userIdentity, CallBack callBack)`

请改用 `start(MTMAConfig config, MTMAInitResultCallback callback)`，显式传入 MA AppKey。

### 独立版新增接口

| 原生接口 | 用途 |
| --- | --- |
| `configDebugMode(boolean)` | 独立 MA 日志开关，默认关闭 |
| `getMaRid()` | 获取 MA RID，与 Push RID 区分 |
| `setChannelValue(long, List<String>, CallBack)` | 第三方 Push 通道 RID/Token；AppPush 自动绑定 |
| `updateObjectArrayProperty(String, String, Object, JSONObject, CallBack)` | 按唯一标识更新对象数组元素 |
| `addObjectArrayProperty(String, JSONObject, CallBack)` | 追加对象数组元素 |
| `removeObjectArrayProperty(String, String, Object, CallBack)` | 按唯一标识移除对象数组元素 |

## 设置用户标识

>建议在用户登录、提供相关信息时设置该接口，获得与该用户匹配的 EUID

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **_setUserIdentity(UserIdentity userIdentity, CallBack callBack) _** 
   - 接口说明： 
      - 设置用户标识，如：用户会员卡号。
   - 参数说明： 
       - userIdentity：调用标识
           - setUserId(String userId)：去除首尾空格后不能为空，最长 255 个 Unicode 字符；不能为 `0`、`null`、`undefined`、`nan`（忽略大小写）
           - setAnonymousId(String anonymousId)：去除首尾空格后不能为空，最长 256 个 Unicode 字符
           - setEmail(String email)：不能为空，最长 256 个 Unicode 字符；必须包含且只能包含一个 `@`，`@` 前后都不能为空，且不能包含空格、换行或 Tab；5.5.0 版本开始支持
           - setPhone(String phone)：必须符合 E.164 格式，以 `+` 开头，国家码首位为 1–9，之后包含 1–14 位数字；5.5.0 版本开始支持
       - callBack：接口回调
   - 返回说明：<br />**_onCallBack(int code, String message)_** 
      - code: 返回码，0 代表获取成功，-1 为失败，详见 message 参数描述

用户标识字段校验失败时不发送网络请求，并通过回调返回 `code = -3`。

#### 调用示例

```     
                UserIdentity userIdentity = new UserIdentity();
                userIdentity.setUserId("您的userId");
                userIdentity.setAnonymousId("您的AnonymousId");
                userIdentity.setEmail("user@example.com");
                userIdentity.setPhone("+8613800138000");
                MTMAApi.getInstance(this).setUserIdentity(userIdentity, new CallBack() {
                    @Override
                    public void onCallBack(int code, String message) {
                        MTCommonLog.e(TAG, "setUserIdentity code:" + code);
                        MTCommonLog.e(TAG, "setUserIdentity message:" + message);
                    }
                });
```

## 设置用户联系方式

> 当用户的联系方式发生变更时，可使用本接口更新用户的「联系方式」。


#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **_setUserContact(JSONObject contacts, CallBack callBack)_** 
   - 接口说明： 
      - 设置用户的「联系方式」。
   - 参数说明： 
      - contacts：设置多个联系方式，Key 为联系方式的名称，value 为联系方式的值，目前支持 email、mobile_phone、landline_phone、whatsapp_phone 这 4 种联系方式
      - callBack：接口回调
   - 返回说明：<br />**_onCallBack(int code, String message)_** 
      - code: 返回码，0 代表获取成功，-1 为失败，详见 message 参数描述
      - message：原因描述

#### 调用示例

```
                JSONObject contacts = new JSONObject();
                try {
                    contacts.put("key1", "cc");
                    contacts.put("key2", "dd");
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                MTMAApi.getInstance(this).setUserContact(contacts, new CallBack() {
                    @Override
                    public void onCallBack(int code, String message) {
                        Log.e(TAG, "setUserContact code:" + code);
                        Log.e(TAG, "setUserContact message:" + message);
                    }
                });
```


## 获取 EUID

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **_getEuid()_** 
   - 接口说明： 
      - 获取 euid，表示用户唯一 id。仅初始化成功时返回当前值，未初始化、初始化中或初始化失败时返回空值。

#### 调用示例

```
MTMAApi.getInstance(this).getEuid();
```

## 获取 MA RID

#### 支持的版本

开始支持的版本：5.5.0

#### 接口定义

- **_getMaRid()_**
  - 接口说明：获取当前 MA RID。仅初始化成功时返回当前值，未初始化、初始化中或初始化失败时返回空值。MA RID 与 Push RID 是两个不同的设备标识，不能混用。

#### 调用示例

```java
String maRid = MTMAApi.getInstance(this).getMaRid();
```

## 设置通道联系ID

#### 支持的版本

开始支持的版本：5.5.0

#### 接口定义

- **_setChannelValue(long channelId, List<String> values, CallBack callBack)_**
  - 接口说明：设置通道联系ID。AppPush 通道由 SDK 自动绑定，不需要调用该接口设置。
  - 参数说明：
    - `channelId`：MA 控制台配置的第三方 Push 通道 ID，必须大于 `0`。
    - `values`：通道联系ID的值列表（例如 RID 或 Token），不能为空，列表元素也不能为空。
    - `callBack`：结果回调，`code == 0` 表示成功。

#### 调用示例

```java
List<String> values = Collections.singletonList("push rid or token");
MTMAApi.getInstance(this).setChannelValue(136L, values, new CallBack() {
    @Override
    public void onCallBack(int code, String message) {
        // code == 0 表示成功
    }
});
```

## 设置上报数据间隔
> 和setMaxEventCacheCount接口共同生效，只需满足其中一个条件就会上报

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **_setReportInterval(int interval)_** 
   - 接口说明: 
      - 设置上报数据间隔，不调用该接口时，默认为10s上报一次事件数据
      - 上报间隔内存缓存，需要在应用程序每次生命周期中调用才会生效
   - 参数说明 
      - interval 上报间隔，单位s(秒)

#### 调用示例

```
	MTMAApi.getInstance(this).setReportInterval(10);
```

##  设置事件缓存上限条数
> 和 setReportInterval 接口共同生效，只需满足其中一个条件就会上报

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **_setMaxEventCacheCount(int count)_** 
   - 接口说明: 
      - 设置事件缓存上限条数，默认50条，最高不能超过500条
      - 当超出缓存数量时会上报报全部数据
   - 参数说明 
      - count 事件缓存条数上限

#### 调用示例

```
	MTMAApi.getInstance(this).setMaxEventCacheCount(50);
```

##  设置会话超时时间

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **_setNoActiveSessionEndDurationTime(int duration)_** 
   - 接口说明: 
      - 当 App 置于后台时，开始计算会话超时时间，超过所设置的时间（默认30分钟）后将会结束本次会话。
   - 参数说明 
      - duration 超时时长，单位s(秒)

#### 调用示例

```
	MTMAApi.getInstance(this).setNoActiveSessionEndDurationTime(5*60);
```

## 设置 UTM 属性

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **_setUtmProperties(UtmProperties utmProperties)_** 
   - 接口说明： 
      - 设置 UTM 属性，若开发者能识别用户是从哪一个广告跳转访问 App ，建议设置 UTM 信息，我们将在事件上报时传递该参数
   - 参数说明： 
      - utmProperties UTM属性对象
      - - utm_source 广告系列来源
      - - utm_medium 广告系列媒介
      - - utm_term 广告系列字词
      - - utm_content 广告系列内容
      - - utm_campaign 广告系列名称

#### 调用示例

```
                UtmProperties utmProperties = new UtmProperties();
                utmProperties.setUtmSource("你的utm_source");
                utmProperties.setUtmCampaign("您的utm_campaign");
                utmProperties.setUtmContent("您的utm_content");
                utmProperties.setUtmId("您的utm_id" );
                utmProperties.setUtmMedium("您的utm_medium");
                utmProperties.setUtmTerm("您的utm_term");
                MTMAApi.getInstance(this).setUtmProperties(utmProperties);
```
## 数据采集控制

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **_setCollectControl(MTMACollectControl control)_** 
   - 接口说明： 
      - 设置采集权限，如果需要开启/关闭某些数据采集，请调用本接口
   - 参数说明： 
      - control：采集权限设置；未显式设置的属性使用下列默认值
        - `setCarrier(boolean enable)`：是否采集运营商信息，默认开启
        - `setMacAddress(boolean enable)`：是否采集 MAC 地址，默认关闭
        - `setGAID(boolean enable)`：是否采集 GAID，默认关闭
        - `setOAID(boolean enable)`：是否采集 OAID，默认关闭
        - `setAAID(boolean enable)`：是否采集 AAID，默认关闭
        - `setIMEI(boolean enable)`：是否采集 IMEI，默认关闭；仅 Android 9及以下支持，宿主应用需要自行声明并获取 `READ_PHONE_STATE` 权限

#### 调用示例

```
try {
MTMACollectControl mtmaCollectControl = new MTMACollectControl();
        mtmaCollectControl.setCarrier(true);
        mtmaCollectControl.setMacAddress(true);
        mtmaCollectControl.setGAID(true);
        mtmaCollectControl.setOAID(true);
        mtmaCollectControl.setIMEI(true);
        mtmaCollectControl.setAAID(true);
    MTMAApi.getInstance(this).setCollectControl(mtmaCollectControl);
} catch (Throwable e) {e.printStackTrace();
}
```

## 设置用户属性

设置用户属性的值，若用户属性不存在，后台会自动创建。

### 覆盖更新用户属性

- **_propertySet(final JSONObject properties, final CallBack callBack)_** 
   - 接口说明： 
      - 批量覆盖更新用户属性的值
      - 仅保存最新上报的数据，覆盖历史数据，如：用户会员等级。
      - Value 支持字符串、数字、布尔值、字符串数组、`JSONObject`，以及元素全部为 `JSONObject` 的 `JSONArray`（object_array）。
   - 参数说明： 
      - properties: 用户属性
      - callBack：接口回调
   - 返回说明：<br />**_onCallBack(int code, String message)_** 
      - code: 返回码，0 代表获取成功，-1 为失败，详见错误码描述
      - message：原因描述
   - 调用示例：

```
try {JSONObject properties = new JSONObject();
    properties.put("你的用户属性名","你的属性值");
    properties.put("你的用户属性名 2","你的属性值 2");
    properties.put("你的用户属性名 3","你的属性值 3");
    MTMAApi.getInstance(this).propertySet(properties, new CallBack() {
        @Override
        public void onCallBack(int code, String message) {}});
} catch (Throwable e) {e.printStackTrace();
}
```

- **_propertySet(String property, Object value, CallBack callBack)_** 
   - 接口说明： 
      - 单个覆盖更新用户属性的值
      - 仅保存最新上报的数据，覆盖历史数据，如：用户会员等级。
      - Value 类型规则与批量 `propertySet` 一致。
   - 参数说明： 
      - property: 用户属性名
      - value: 用户属性值
      - callBack：接口回调
   - 返回说明：<br />**_onCallBack(int code, String message)_** 
      - code: 返回码，0 代表获取成功，-1 为失败，详见错误码描述
      - message：原因描述
   - 调用示例：

```
MTMAApi.getInstance(this).propertySet("你的用户属性名","你的属性值", new CallBack() {
    @Override
    public void onCallBack(int code, String message) {}});
```

### 累加更新用户属性

- **_propertyIncrease(final Map<String, ? extends Number> properties, CallBack callBack)_** 
   - 接口说明： 
      - 对用户属性的值设置累加，批量请求
      - 累加所有上报的数据，如累计消费金额。
      - 只能对数值类型的用户属性调用这个接口，否则会被忽略, 如果这个用户属性之前不存在，则初始值当做 0 来处理。
   - 参数说明： 
      - properties: 用户属性
      - callBack：接口回调
   - 返回说明：<br />**_onCallBack(int code, String message)_** 
      - code: 返回码，0 代表获取成功，-1 为失败，详见错误码描述
      - message：原因描述
   - 调用示例：

```
Map<String,Number> properties = new HashMap();
properties.put("你的用户属性名",1);
properties.put("你的用户属性名 2",2);
properties.put("你的用户属性名 3",3);
MTMAApi.getInstance(this).propertyIncrease(properties, new CallBack() {
    @Override
    public void onCallBack(int code, String message) {}});
```

- **_propertyIncrease(final String property, final Number value, CallBack callBack)_** 
   - 接口说明： 
      - 对用户属性的值设置累加，单次请求
      - 累加所有上报的数据，如累计消费金额。
      - 只能对数值类型的用户属性调用这个接口，否则会被忽略, 如果这个用户属性之前不存在，则初始值当做 0 来处理。
   - 参数说明： 
      - property: 用户属性名
      - value: 用户属性值
      - callBack：接口回调
   - 返回说明：<br />**_onCallBack(int code, String message)_** 
      - code: 返回码，0 代表获取成功，-1 为失败，详见错误码描述
      - message：原因描述
   - 调用示例：

```
MTMAApi.getInstance(this).propertyIncrease("你的用户属性名",1, new CallBack() {
    @Override
    public void onCallBack(int code, String message) {}});
```

### 追加用户属性

- **_propertyAdd(final String property, final String value, CallBack callBack)_** 
   - 接口说明： 
      - 对用户属性的值进行追加，单次请求
      - 可持续增加该集合元素，元素入库去重处理，若已存在ABC，追加CD，最终为ABCD。
   - 参数说明： 
      - property: 用户属性名
      - value: 用户属性值
      - callBack：接口回调
   - 返回说明：<br />**_onCallBack(int code, String message)_** 
      - code: 返回码，0 代表获取成功，-1 为失败，详见错误码描述
      - message：原因描述
   - 调用示例：

```
MTMAApi.getInstance(this).propertyAdd("你的用户属性名","你的用户属性值", new CallBack() {
    @Override
    public void onCallBack(int code, String message) {}});
```

- **_propertyAdd(final String property, final Set values, CallBack callBack)_** 
   - 接口说明： 
      - 对用户属性的值进行追加，一次添加多个值
      - 可持续增加该集合元素，元素入库去重处理，若已存在ABC，追加CD，最终为ABCD。
   - 参数说明： 
      - property: 用户属性名
      - value: 用户属性值
      - callBack：接口回调
   - 返回说明：<br />**_onCallBack(int code, String message)_** 
      - code: 返回码，0 代表获取成功，-1 为失败，详见错误码描述
      - message：原因描述
   - 调用示例：

```
Set<String> properties = new HashSet<>();
properties.add("你的用户属性值");
properties.add("你的用户属性值 2");
properties.add("你的用户属性值 3");
MTMAApi.getInstance(this).propertyAdd("你的用户属性名",properties, new CallBack() {
    @Override
    public void onCallBack(int code, String message) {}});
```

### 操作 object_array 元素

以下接口从 5.5.0 开始支持。它们只用于 `object_array` 用户属性；原有 `propertyAdd`、`propertyRemove` 仍用于字符串数组，行为保持不变。属性尚未创建时，需要先通过 `propertySet` 传入非空对象数组完成首次设置。

- **_updateObjectArrayProperty(String property, String identifierKey, Object identifierValue, JSONObject values, CallBack callBack)_**
  - 根据唯一标识更新一个对象元素的子字段。
  - `identifierValue` 支持字符串或有限数字；`values` 不能修改标识字段。
  - `values` 中使用 `JSONObject.NULL` 可删除对应子字段。

```java
JSONObject values = new JSONObject().put("enabled", false);
MTMAApi.getInstance(this).updateObjectArrayProperty(
        "devices", "device_id", "device_1", values, callBack);
```

- **_addObjectArrayProperty(String property, JSONObject object, CallBack callBack)_**
  - 向 `object_array` 追加一个非空对象元素，不影响已有元素。

```java
JSONObject device = new JSONObject()
        .put("device_id", "device_2")
        .put("year", 2026);
MTMAApi.getInstance(this).addObjectArrayProperty("devices", device, callBack);
```

- **_removeObjectArrayProperty(String property, String identifierKey, Object identifierValue, CallBack callBack)_**
  - 根据唯一标识删除整个对象元素。

```java
MTMAApi.getInstance(this).removeObjectArrayProperty(
        "devices", "device_id", "device_2", callBack);
```

### 移除用户属性

- **_propertyRemove(final String property, String values, final CallBack callBack)_** 
   - 接口说明： 
      - 对用户属性的值操作移除。
      - 该值为集合元素，元素入库去重处理，若已存在ABCD，删除D，最终为ABC。
   - 参数说明： 
      - property: 用户属性名
      - value: 用户属性值
      - callBack：接口回调
   - 返回说明：<br />**_onCallBack(int code, String message)_** 
      - code: 返回码，0 代表获取成功，-1 为失败，详见错误码描述
      - message：原因描述
   - 调用示例：

```
MTMAApi.getInstance(this).propertyRemove("你的用户属性名","你的用户属性值", new CallBack() {
    @Override
    public void onCallBack(int code, String message) {}});
```

- **_propertyRemove(final String property, Set<String> values, final CallBack callBack)_** 
   - 接口说明： 
      - 对用户属性的值操作移除，一次移除多个值。
      - 该值为集合元素，元素入库去重处理，若已存在ABCD，删除CD，最终为AB。
   - 参数说明： 
      - property: 用户属性名
      - value: 用户属性值
      - callBack：接口回调
   - 返回说明：<br />**_onCallBack(int code, String message)_** 
      - code: 返回码，0 代表获取成功，-1 为失败，详见错误码描述
      - message：原因描述
   - 调用示例：

```
Set<String> properties = new HashSet<>();
properties.add("你的用户属性值");
properties.add("你的用户属性值 2");
properties.add("你的用户属性值 3");
MTMAApi.getInstance(this).propertyRemove("你的用户属性名",properties, new CallBack() {
    @Override
    public void onCallBack(int code, String message) {}});
```

## 删除用户属性

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **_propertyDelete(final String property, final CallBack callBack)_** 
   - 接口说明： 
      - 删除某个用户属性的所有 value 值
   - 参数说明： 
      - property: 用户属性名
      - callBack：接口回调
   - 返回说明：<br />**_onCallBack(int code, String message)_** 
      - code: 返回码，0 代表获取成功，-1 为失败，详见错误码描述
      - message：原因描述

#### 调用示例

```
MTMAApi.getInstance(this).propertyDelete("你的用户属性名", new CallBack() {
    @Override
    public void onCallBack(int code, String message) {}});
```
## 自定义事件上报

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **_onEvent(String eventKey, JSONObject property)_** 
   - 接口说明： 
      - 自定义事件上报
   - 参数说明： 
      - eventKey: 事件名称
      - property：事件属性，Key为属性名称，value为属性值

#### 调用示例

```
JSONObject property = new JSONObject();
properties.put("key1","v1");
properties.put("key2","v2");
MTMAApi.getInstance(this).onEvent("你的事件名称",property );
```

## 错误码

| code               | 值  | 说明           |
|-------------------|-----|---------------|
| CODE_SUCCEED      | 0   | 成功         |
| CODE_UNKNOWN      | -1  | 未知错误      |
| CODE_START_FAIL   | -2  | 初始化未完成、初始化失败或当前操作依赖的 MA 配置未就绪 |
| CODE_VALID        | -3  | 参数校验失败   |
| CODE_ENABLE       | -4  | MA 项目已关闭 |
| CODE_REGISTRATIONID| -5 | MA RID 缺失或不合法 |
| CODE_SWITCH        | -6 | MA 项目配置已切换，需要再次调用 `start` |
