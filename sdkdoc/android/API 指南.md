# Android SDK API

## SDK 接口说明

- MTMAApi，包含 SDK 所有接口。

## 启用MA功能

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **_start(UserIdentity userIdentity,CallBack callBack)_** 
   - 接口说明： 
      - 开始使用 MA 功能，启用时可以同时设置用户标识信息
    - 参数说明：
      - userIdentity：调用标识，如果没有可设置 null
        - setUserId(String userId)：userId，将唯一的登录用户标识设置在此
        - setAnonymousId(String anonymousId)：anonymousId，当用户未登录，但提供了其他可作为标识的信息时，可将其设置为匿名ID，如邮箱地址、第三方生成的标识ID
      - callBack：结果数据回调
   - 返回说明：<br />**_onCallBack(int code, String message)_** 
      - code: 返回码，0 代表获取成功，-1 为失败，详见 message 参数描述
      - message：原因描述

#### 调用示例

```
                MTMAApi.getInstance(this).start(new CallBack() {
                    @Override
                    public void onCallBack(int code, String message) {
                        Log.e(TAG, "start code:" + code);
                        Log.e(TAG, "startmessage:" + message);

                    }
                });
```


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
           - setUserId(String userId)：userId，将唯一的登录用户标识设置在此
           - setAnonymousId(String anonymousId)：anonymousId，当用户未登录，但提供了其他可作为标识的信息时，可将其设置为匿名ID，如邮箱地址、第三方生成的标识ID
       - callBack：接口回调
   - 返回说明：<br />**_onCallBack(int code, String message)_** 
      - code: 返回码，0 代表获取成功，-1 为失败，详见 message 参数描述

#### 调用示例

```     
                UserIdentity userIdentity = new UserIdentity();
                userIdentity.setUserId("您的userId");
                userIdentity.setAnonymousId("您的AnonymousId");
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
      - 获取 euid。表示用户唯一 id

#### 调用示例

```
MTMAApi.getInstance(this).getEuid();
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
## 设置 采集权限

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **_setCollectControl(MTMACollectControl control)_** 
   - 接口说明： 
      - 设置 采集权限，如果需要开启/关闭某些数据采集，请调用本接口
   - 参数说明： 
      - control： 权限设置，默认开

#### 调用示例

```
try {
MTMACollectControl mtmaCollectControl = new MTMACollectControl();
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

## 错误码：
| code               | 值  | 说明           |
|-------------------|-----|---------------|
| CODE_SUCCEED      | 0   | 成功         |
| CODE_UNKNOWN      | -1  | 未知错误      |
| CODE_START_FAIL   | -2  | 没有调用start或调用start还未成功或项目切换，再调用start  |
| CODE_VALID        | -3  | 参数校验失败   |
| CODE_ENABLE       | -4  | 项目关闭 |
| CODE_REGISTRATIONID| -5 | push没有注册成功  |
| CODE_SWITCH        | -6 | 项目切换，需要再次调用start |
