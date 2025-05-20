# iOS SDK API

## SDK 接口说明

1. MTMAService，包含 SDK 所有接口。
2. MTMAConfig，应用配置信息类。
3. MTMAUserID，用户标识模型。
4. MTMAUserContact, 用户联系方式模型。
5. MTMACollectControl, 数据采集控制模型。


## 启动 MA 业务功能 

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

-  **+ start:(MTMAConfig * )config;** 
   - 接口说明: 
      - 启用 EngageLab MA 功能。
      - start 接口是其他接口的开始接口，所以必须先调用 start 接口，才能调用其他接口
   - 参数说明 
      - config 配置类

#### 调用示例

```
    MTMAConfig *config = [[MTMAConfig alloc] init];
    [MTMAService start:config];
```


## 设置用户联系方式

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

-  **+ (void)setUserContact:(MTMAUserContact * )contact;** 
   - 接口说明: 
      - 设置用户联系方式
   - 参数说明 
      - contacts：设置多个联系方式，Key 为联系方式的名称，value 为联系方式的值，目前支持 email、mobile_phone、landline_phone、whatsapp_phone 这 4 种联系方式

#### 调用示例

```
    MTMAUserContact *contact = [[MTMAUserContact alloc] init];
    contact.contacts = @{@"工作手机":@"13*********"};
    contact.completion = ^(NSInteger code, NSString * _Nonnull message) { };
    [MTMAService setUserContact:contact];
```

## 事件上报

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

-  **+ (void)eventRecord:(MTMAEventObject *)event;** 
   - 接口说明: 
      - 上报事件
   - 参数说明 
      - 上报事件模型
      - eventName：上报的事件名称
      - property：事件属性，Key为属性名称，value为属性值

#### 调用示例

```
    MTMAEventObject *object = [[MTMAEventObject alloc] init];
    object.eventName = @"sndefineevent2";
    object.property = @{
        @"key1":@"value1",
        @"key2":@"value2",
    };
    [MTMAService eventRecord:object];
```


## 设置用户标识

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

-  **+ (void)identifyAccount:(MTMAUserID * )userID;** 
   - 接口说明: 
      - 设置用户标识
   - 参数说明 
      - 用户标识模型
      - userID：将唯一的登录用户标识设置在此
      - anonymousID：当用户未登录，但提供了其他可作为标识的信息时，可将其设置为匿名ID，如邮箱地址、第三方生成的标识ID

#### 调用示例

```
    MTMAUserID *userid = [[MTMAUserID alloc] init];
    userid.anonymousID = @"xxx";
    userid.userID = @"xxx";
    [MTMAService identifyAccount:userid];
```



## 设置上报数据间隔

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **+ (void)setReportInterval:(NSInteger)interval;** 
   - 接口说明: 
      - 设置上报数据间隔，不调用该接口时，默认为 10s 上报一次事件数据
      - 上报间隔内存缓存，需要在应用程序每次生命周期中调用才会生效
   - 参数说明 
      - interval 上报间隔，单位 s(秒)

#### 调用示例

```
	[MTMAService setReportInterval:10];
```

##  设置事件缓存上限条数

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **+ (void)setMaxEventCacheCount:(NSInteger)count;** 
   - 接口说明: 
      - 设置事件缓存上限条数，默认 50 条，最高不能超过 500 条
      - 当超出缓存数量时会上报报全部数据
   - 参数说明 
      - count 事件缓存条数上限

#### 调用示例

```
	[MTMAService setMaxEventCacheCount:50];
```

##  设置会话超时时间

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **+ (void)setNoActiveSessionEndDurationTime:(NSInteger)interval;** 
   - 接口说明: 
      - 设置会话超时时间，默认 30 分钟
      - App 切换到后台，会话开始超时计时，超时时间内没有活动，就结束当前会话
   - 参数说明 
      - interval 超时时长，单位s(秒)

#### 调用示例

```
    [MTMAService setNoActiveSessionEndDurationTime:50];
```

## 获取 EUID

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **+ (NSString * )EUID;** 
   - 接口说明: 
      - 获取 EngageLab MA 的 EUID

#### 调用示例

```
    [MTMAService EUID];
```

## 设置 UTM 属性

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **+ (void)setUtmProperties:(NSDictionary * )property;** 
   - 接口说明: 
      - UTM 属性为标准事件属性，若开发者能识别用户是从哪一个广告跳转访问 App ，建议设置 UTM 信息，我们将在事件上报时传递该参数。目前能够设置 UTM 属性为：
         - utm_source 广告系列来源
         - utm_medium 广告系列媒介
         - utm_term 广告系列字词
         - utm_content 广告系列内容
         - utm_campaign 广告系列名称
         - utm_id 广告系列ID

#### 调用示例

```
   	[MTMAService setUtmProperties:@{@"utm_source":@"value"}];
```


## 设置用户属性

### 覆盖更新用户属性

- **+ (void)setProperty:(NSDictionary * )userinfo completion:(void (^)(NSInteger code, NSString * message))completion;** 
   - 接口说明: 
      - 这些用户属性的内容用一个 NSDictionary 来存储，其中的 key 是用户属性的名称，必须是 NSString，Value 则是用户属性的内容，只支持 NSString、NSNumber，NSSet、NSArray 这些类型。
      - NSSet 或者 NSArray 类型的 value 中目前只支持其中的元素是 NSString。
      - 如果某个用户属性之前已经存在了，则这次会被覆盖掉；不存在，则会创建。如：用户会员等级。
   - 调用示例:

```
   [MTMAService setProperty:@{@"key":@"value"} completion:^(NSInteger code, NSString * _Nonnull message) {
       
   }];
```

- **+ (void)setProperty:(NSString * )key to:(id)value completion:(void (^)(NSInteger code, NSString * message))completion;** 
   - 接口说明: 
      - 设置用户的单个用户属性的内容。
      - 这些用户属性的内容用一个 NSDictionary 来存储，其中的 key 是用户属性的名称，必须是 NSString，Value 则是用户属性的内容，只支持 NSString、NSNumber，NSSet、NSArray 这些类型。
      - NSSet 或者 NSArray 类型的 value 中目前只支持其中的元素是 NSString。
      - 如果某个用户属性之前已经存在了，则这次会被覆盖掉；不存在，则会创建。如：用户会员等级。
   - 调用示例:

```
   [MTMAService setProperty:@"key" to:@"value" completion:^(NSInteger code, NSString * _Nonnull message) {
       
   }];
```

### 累加更新用户属性

- **+ (void)increaseProperty:(NSString *)key by:(NSNumber *)amount completion:(void (^)(NSInteger code, NSString * message))completion;** 
   - 接口说明: 
      - 给一个数值类型的用户属性增加一个数值，累加所有上报的数据，如累计消费金额。
      - 只能对 NSNumber 类型的用户属性调用这个接口，否则会被忽略, 如果这个用户属性之前不存在，则初始值当做 0 来处理。
   - 调用示例:

```
    [MTMAService increaseProperty:@"key" by:@(2) completion:^(NSInteger code, NSString * _Nonnull message) {
    
    }];
```

- **+ (void)increaseProperty:(NSDictionary *)userinfo completion:(void (^)(NSInteger code, NSString * message))completion;** 
   - 接口说明: 
      - 给多个数值类型的用户属性增加数值，累加所有上报的数据，如累计消费金额。
      - 只能对 NSNumber 类型的用户属性调用这个接口，否则会被忽略, 如果这个用户属性之前不存在，则初始值当做 0 来处理。
   - 调用示例:

```
    [MTMAService increaseProperty:@{@"key1":@(5),@"key2":@(3)} completion:^(NSInteger code, NSString * _Nonnull message) {
    
    }];
```

### 追加用户属性

- **+ (void)addProperty:(NSString *)key by:(NSObject<NSFastEnumeration> *)content completion:(void (^)(NSInteger code, NSString * message))completion** 
   - 接口说明: 
      - 向一个 NSSet 或者 NSArray 类型的属性添加一些值。
      - 如前面所述，这个 NSSet 或者 NSArray 的元素必须是 NSString，否则，会忽略, 同时，如果要 add 的用户属性之前不存在，会初始化一个空的 NSSet 或者 NSArray。
   - 调用示例:

```
    [MTMAService addProperty:@"key" by:@[@"value"] completion:^(NSInteger code, NSString * _Nonnull message) {
    
    }];
```

- **+ (void)addProperty:(NSDictionary *)userinfo completion:(void (^)(NSInteger, NSString * _Nonnull))completion;** 
   - 接口说明: 
      - 向多个 NSSet 或者 NSArray 类型的属性添加一些值。
      - 如前面所述，这个 NSSet 或者 NSArray 的元素必须是 NSString，否则，会忽略, 同时，如果要 add 的用户属性之前不存在，会初始化一个空的 NSSet 或者 NSArray。
   - 调用示例:

```
    [MTMAService addProperty:@{@"key1":@[@"value"],@"key2":@[@"value"]} completion:^(NSInteger code, NSString * _Nonnull message) {
    
    }];
```

### 移除用户属性

- **+ (void)removeProperty:(NSString * )key by:(NSObject<NSFastEnumeration> *)content completion:(void (^)(NSInteger code, NSString * message))completion;** 
   - 接口说明: 
      - 向一个 NSSet 或者 NSArray 类型的属性删除一些值。
      - 参数 content 类型为 NSSet 或者 NSArray，里面的元素必须是 NSString。
   - 调用示例:

```
    [MTMAService removeProperty:@"key" by:@[@"value"] completion:^(NSInteger code, NSString * _Nonnull message) {
    
    }];
```


## 删除用户属性

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **+ (void)deleteProperty:(NSString * )key completion:(void (^)(NSInteger code, NSString * message))completion;** 
   - 接口说明: 
      - 删除某个用户属性的全部内容
      - 如果这个用户属性之前不存在，则直接忽略

#### 调用示例

```
    [MTMAService deleteProperty:@"key" completion:^(NSInteger code, NSString * _Nonnull message) {
        
    }];
```

## 数据采集控制

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

- **+ (void)setCollectControl:(MTMACollectControl *)control;** 
   - 接口说明: 
      - 控制 MTMACollectControl 类中数据项是否采集

#### 调用示例

```
    MTMACollectControl *collectControl = [[MTMACollectControl alloc] init];
    collectControl.idfa = YES;
    collectControl.idfv = YES;
    collectControl.carrier = YES;
    [MTMAService setCollectControl:collectControl];
```




## MTMAConfig 类

应用配置信息类。以下是属性说明：

| 参数名称 | 参数类型 | 参数说明 |
| --- | --- | --- |
| userID | MTMAUserID | 用户标识模型,当设置该属性时时会在初始化时进行设置用户标识 |
| completion | (^)(NSInteger code, NSString * message) | 请求结果回调, code:0为成功 |


## MTMAUserID 类

用户标识模型类。以下是属性说明：

| 参数名称 | 参数类型 | 参数说明 |
| --- | --- | --- |
| userID | NSString | 将唯一的登录用户标识设置在此 |
| anonymousID | NSString | 当用户未登录，但提供了其他可作为标识的信息时，可将其设置为匿名ID，如邮箱地址、第三方生成的标识ID |
| completion | (^)(NSInteger code, NSString * message) | 请求结果回调, code:0 为成功 |


## MTMACollectControl 类

用户数据采集控制模型类。以下是属性说明：

| 参数名称 | 参数类型 | 参数说明 |
| --- | --- | --- |
| idfa | BOOL | 是否采集idfa信息。设置为NO,不采集idfa信息。默认为NO。 |
| idfv | BOOL | 是否采集idfv信息。设置为NO,不采集idfv信息。默认为NO。 |
| carrier | BOOL | 是否采集运营商信息。设置为NO,不采集运营商信息。默认为YES。 |


## MTMAUserContact 类

用户通道模型类。以下是属性说明：<br />如果不设置或者设置为 nil 则认为不修改，设置为 "" 空字符串的时候认为清空该联系方式

| 参数名称 | 参数类型 | 参数说明 |
| --- | --- | --- |
| contacts | NSDictionary | 联系方式字典，支持 email、mobile_phone、landline_phone、whatsapp_phone 这 4 种联系方式 |
| completion | (^)(NSInteger code, NSString * message) | 请求结果回调, code:0 为成功 |


## MTMAEventObject 类

自定义事件对象类。以下是属性说明：

| 参数名称 | 参数类型 | 参数说明 |
| --- | --- | --- |
| eventName | NSString | 事件 ID，必填，非空 |
| property | NSDictionary<NSString *, id> | 自定义属性 (小于等于500个) key 为 NSString，只能包含数字字母下划线；value 可以是 NSString/NSNumber |
