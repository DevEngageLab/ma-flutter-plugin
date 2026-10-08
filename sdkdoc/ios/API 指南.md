# iOS SDK API

## SDK 接口说明

1. MTMAService，包含 SDK 所有接口。
2. MTMAConfig，应用配置信息类。
3. MTMAInitResult，SDK 初始化结果类。
4. MTMAUserID，用户标识模型。
5. MTMAUserContact, 用户联系方式模型。
6. MTMACollectControl, 数据采集控制模型。


## 启动 MA 业务功能（独立版 5.5.0）

#### 支持的版本

开始支持的版本： 5.0.0

email、phone 标识开始支持的版本：5.5.0

独立初始化开始支持的版本： 5.5.0

#### 接口定义

- **+ (void)start:(MTMAConfig * )config;**
   - 接口说明:
      - 启用 EngageLab MA 功能。`config.appKey` 为必填 MA AppKey，初始化不依赖 AppPush 的注册结果。
      - start 接口是其他接口的开始接口，必须先调用 start 才能调用其他接口。
      - 同一个 App 进程内可以重复初始化或切换 MA AppKey，无需重启 App。每次有效调用都会单独执行并回调，不会合并。
      - `start:` 与 `identifyAccount:` 按调用顺序执行，前一次调用及其回调结束后才执行下一次；排队期间修改原配置对象不影响已提交的参数。
      - 每次初始化都需要联网确认用户身份，请以本次回调的 EUID 为准；失败结果见错误码说明。
   - 参数说明
      - config：配置类，通过 `config.resultCompletion` 获取 `MTMAInitResult` 的 `success`、`code`、`message`、`EUID` 和 `maRID`，初始化成功后再进行业务操作。无需先初始化 Push。

#### 调用示例

```
    MTMAConfig *config = [[MTMAConfig alloc] init];
    config.appKey = @"你的 MA AppKey";
    config.resultCompletion = ^(MTMAInitResult *result) {
        if (result.isSuccess) {
            NSLog(@"MTMA 初始化成功");
        } else {
            NSLog(@"MTMA 初始化失败，code=%ld，message=%@", (long)result.code, result.message);
        }
    };
    [MTMAService start:config];
```

完整代码见 [集成指南](./集成指南.md)。旧示例仅构造空 `MTMAConfig` 的方式不适用于独立接入；旧 `completion` 已弃用，请使用 `resultCompletion`。

### 独立版新增接口

| 原生接口 | 用途 |
| --- | --- |
| `maRID` | 获取 MA RID，与 Push RID 区分 |
| `setChannelValueWithChannelId:values:completion:` | 第三方 Push 通道 RID/Token；AppPush 自动绑定 |
| `updateObjectArrayProperty:identifierKey:identifierValue:values:completion:` | 按唯一标识更新对象数组元素 |
| `addObjectArrayProperty:object:completion:` | 追加对象数组元素 |
| `removeObjectArrayProperty:identifierKey:identifierValue:completion:` | 按唯一标识移除对象数组元素 |

Flutter 对应接口、参数约束和示例见 [Flutter API 文档](../../cndocuments/APIs.md)。下文旧接口的“开始支持版本”表示首次引入时间，不表示独立初始化从 5.0.0 起可用。

## 设置用户联系方式

#### 支持的版本

开始支持的版本： 5.0.0

#### 接口定义

-  **+ (void)setUserContact:(MTMAUserContact * )contact;** 
   - 接口说明: 
      - 设置用户联系方式
    - 参数说明
      - contacts：设置多个联系方式，目前支持 email、mobile_phone、landline_phone、whatsapp_phone。Key 必须为长度 1～256 的字符串；value 必须为字符串，`""` 表示清空该联系方式，非空但全是空白的字符串无效

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

email、phone 标识开始支持的版本：5.5.0

#### 接口定义

-  **+ (void)identifyAccount:(MTMAUserID * )userID;** 
   - 接口说明: 
      - 设置用户标识
    - 参数说明
      - 用户标识模型
      - userID：将唯一的登录用户标识设置在此
      - anonymousID：当用户未登录，但提供了其他可作为标识的信息时，可将其设置为匿名ID，如邮箱地址、第三方生成的标识ID
      - email：用户的邮箱地址，用于识别用户身份
      - phone：用户的手机号码，需包含国家或地区代码，如 +8613800000000
      - 至少提供一个有效标识，无需全部填写。详细要求见 [MTMAUserID 类](#mtmauserid-类)

回调 `code=0` 表示已取得可用 EUID，不代表所有标识都设置成功。`message` 中的 JSON 包含本地和服务端的逐项结果，key 为 `user_id`、`anonymous_id`、`email`、`phone`；请按对应字段的 `code` 判断结果，缺少字段不代表成功。失败 message 不保证是 JSON。

#### 调用示例

```
    MTMAUserID *userid = [[MTMAUserID alloc] init];
    userid.userID = @"member_10001";
    userid.anonymousID = @"anonymous_10001";
    userid.email = @"member_10001@example.com";
    userid.phone = @"+8613800000000";
    userid.completion = ^(NSInteger code, NSString *message) {
        NSLog(@"result：%ld - %@", code, message);
    };
    [MTMAService identifyAccount:userid];
```



## 设置通道联系ID

#### 支持的版本

开始支持的版本： 5.5.0

#### 接口定义

- **+ (void)setChannelValueWithChannelId:(NSInteger)channelId values:(NSArray<NSString *> *)values completion:(void (^)(NSInteger code, NSString *message))completion;**
   - 接口说明:
      - 为第三方 Push 通道设置 RID 或 Token
      - EngageLab AppPush 的通道关系由 SDK 自动处理，不需要调用该接口设置
      - 未集成 AppPush 或 AppPush 注册失败，不影响 MA 其他功能使用
      - 连续调用时，SDK 按调用顺序依次请求，并分别回调结果
      - 排队期间 MA AppKey、项目或身份发生变化时，对应请求返回 -2
   - 参数说明
      - channelId：MA 控制台中的第三方 Push 通道 ID，必须大于 0
      - values：当前通道的 RID 或 Token 数组。SDK 去除每个值的首尾空白后发送，数组及裁剪后的元素均不能为空
      - completion：请求结果回调，code 为 0 表示成功

#### 调用示例

```
    [MTMAService setChannelValueWithChannelId:136
                                       values:@[@"第三方 Push RID 或 Token"]
                                   completion:^(NSInteger code, NSString *message) {
    }];
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

- **+ (nullable NSString * )EUID;**
   - 接口说明: 
      - 获取 EngageLab MA 的 EUID
      - SDK 未初始化成功时返回 nil

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
      - 批量设置用户属性；一次最多 100 个。任意一个属性在 SDK 校验失败时，整批请求都不会发送。
      - 属性名必须是 `NSString`：以小写字母开头，只能包含小写字母、数字、下划线，最长 50 个 UTF-8 字节，且不能以 `el`、`engagelab`、`metaverse` 开头。
      - Value 支持 `NSString`、有限值 `NSNumber`、字符串 `NSSet/NSArray`、`NSDictionary`（object）和 `NSArray<NSDictionary *>`（object_array）。
      - 普通类型已存在时覆盖，不存在时创建；object 使用子字段合并语义；object_array 使用整体替换语义并保持数组顺序。
   - 调用示例:

```
   [MTMAService setProperty:@{
       @"level": @"gold",
       @"profile": @{ @"city": @"Singapore", @"score": @100 },
       @"addresses": @[
           @{ @"id": @"home", @"city": @"Singapore" },
           @{ @"id": @"office", @"city": @"Tokyo" }
       ]
   } completion:^(NSInteger code, NSString * _Nonnull message) {
       // code == 0 表示服务端处理成功
   }];
```

- **+ (void)setProperty:(NSString * )key to:(id)value completion:(void (^)(NSInteger code, NSString * message))completion;** 
   - 接口说明: 
      - 设置用户的单个用户属性的内容。
      - 属性名、Value 类型和更新语义与批量接口完全一致。
   - 调用示例:

```
   [MTMAService setProperty:@"profile"
                         to:@{ @"city": @"Singapore", @"score": @100 }
                 completion:^(NSInteger code, NSString * _Nonnull message) {
   }];
```

#### object / object_array 规则

- object 必须是非空 `NSDictionary`。子字段名必须是非空 `NSString`，不能包含 `.` 或 `$`。
- object 子字段值支持 `NSString`、有限值 `NSNumber`、字符串 `NSSet/NSArray` 和 `NSNull`；不支持继续嵌套 object 或 object_array。
- 再次对 object 调用 `setProperty` 时，只合并本次传入的子字段；未传子字段保持不变。子字段值传 `NSNull` 表示移除该子字段。
- object_array 必须是 `NSArray<NSDictionary *>`；每个对象都必须非空，并遵守相同的子字段规则。再次调用 `setProperty` 会整体替换数组。
- object_array 的每个元素必须至少保留一个非 `NSNull` 子字段，不能传入所有子字段值均为 `NSNull` 的对象。
- 空数组可用于清空一个已经存在的数组属性，但首次创建时无法仅根据空数组区分字符串列表和 object_array；首次创建 object_array 请传非空对象数组。
- `NSNull` 只允许作为 object/object_array 的子字段值。不能用顶层 `NSNull` 删除完整属性；删除完整属性请调用 `deleteProperty:completion:`。

### 局部更新 object_array 元素

开始支持的版本：5.5.0

- **+ (void)updateObjectArrayProperty:(NSString *)key identifierKey:(NSString *)identifierKey identifierValue:(id)identifierValue values:(NSDictionary<NSString *, id> *)values completion:(void (^)(NSInteger code, NSString * message))completion;**
   - 接口说明:
      - 在 object_array 中通过唯一子字段定位一个对象，然后合并 `values` 中的子字段。
      - `identifierKey` 对应的子字段必须已经在服务端元数据中定义，类型只能是 string 或 number；`identifierValue` 必须是相同类型的 `NSString` 或非布尔、有限值 `NSNumber`，并且在当前数组中只能匹配一项。
      - `values` 必须是非空字典，不能包含 `identifierKey`，也不能嵌套 object/object_array。未传字段保持不变；值传 `NSNull` 时移除该子字段。
      - 该属性必须已经在服务端元数据中定义为 object_array，且当前用户已有该属性值。首次创建可用 `setProperty:to:` 传入非空对象数组。
      - 属性尚未定义或当前用户还没有值时，服务端返回 `code=0` 但不产生修改；已有数组但没有匹配项、匹配多项、标识字段类型不一致或子字段不符合元数据定义时，由服务端返回失败码。
   - 调用示例:

```
// id == home 的对象：把 city 更新为 Tokyo，同时移除 zip
[MTMAService updateObjectArrayProperty:@"addresses"
                         identifierKey:@"id"
                       identifierValue:@"home"
                                values:@{
                                    @"city": @"Tokyo",
                                    @"zip": NSNull.null
                                }
                            completion:^(NSInteger code, NSString *message) {
}];
```

### 追加 object_array 元素

开始支持的版本：5.5.0

- **+ (void)addObjectArrayProperty:(NSString *)key object:(NSDictionary<NSString *, id> *)object completion:(void (^)(NSInteger code, NSString * message))completion;**
   - 接口说明:
      - 往 object_array 末尾追加**一个**对象元素，不影响已有元素。与 `setProperty:to:` 传整个数组的整体替换语义不同。
      - `object` 必须是非空 `NSDictionary`，至少保留一个非 `NSNull` 子字段，子字段规则与 object 一致，不支持嵌套 object/object_array。
      - 该属性必须已经在服务端元数据中定义为 object_array；尚未定义时服务端返回 `code=0` 但不产生修改。属性已定义但当前用户还没有值时，本接口会用这一个元素创建数组。
   - 调用示例:

```
[MTMAService addObjectArrayProperty:@"addresses"
                               object:@{
                                   @"id": @"school",
                                   @"city": @"Osaka"
                               }
                           completion:^(NSInteger code, NSString *message) {
}];
```

### 移除 object_array 元素

开始支持的版本：5.5.0

- **+ (void)removeObjectArrayProperty:(NSString *)key identifierKey:(NSString *)identifierKey identifierValue:(id)identifierValue completion:(void (^)(NSInteger code, NSString * message))completion;**
   - 接口说明:
      - 通过唯一子字段定位并移除**整个数组元素**。只想移除元素里的某个子字段，请用 `updateObjectArrayProperty:` 把该子字段传 `NSNull`。
      - `identifierKey` / `identifierValue` 的约束与 `updateObjectArrayProperty:` 完全一致。
      - 属性尚未定义、当前用户没有该属性值或没有匹配项时，服务端忽略本次请求并返回 `code=0`；匹配多项或标识字段类型不一致时返回失败码。
   - 调用示例:

```
// 删掉 id == office 的那个地址
[MTMAService removeObjectArrayProperty:@"addresses"
                        identifierKey:@"id"
                      identifierValue:@"office"
                           completion:^(NSInteger code, NSString *message) {
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
      - 删除某个用户属性的全部内容，适用于普通类型、object 和 object_array。
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
| appKey | NSString | MA AppKey，独立版必填，必须为 24 位字母或数字，与 Push AppKey 相互独立 |
| userID | MTMAUserID | 用户标识模型，设置后会在初始化时提交用户标识 |
| resultCompletion | ^(MTMAInitResult *result) | 主线程异步回调，返回 MTMAInitResult，优先于 completion |
| completion | (^)(NSInteger code, NSString * message) | 旧版初始化结果回调，已废弃，请使用 resultCompletion |


## MTMAInitResult 类

resultCompletion 返回的 SDK 初始化结果对象，不需要单独创建或调用。以下是属性说明：

| 参数名称 | 参数类型 | 参数说明 |
| --- | --- | --- |
| code | NSInteger | 初始化结果码，仅用于问题定位，不建议根据具体的服务端业务码编写业务分支 |
| message | NSString | 初始化结果说明，非预期失败时可与 code 一并提供给技术支持 |
| EUID | NSString | 初始化成功后的 MA EUID，失败时为 nil |
| maRID | NSString | 初始化成功后的 MA Registration ID，失败时为 nil |
| success | BOOL | 初始化是否成功，请通过 isSuccess 获取并据此判断初始化结果 |


## MTMAUserID 类

用户标识模型类。初始化时通过 `MTMAConfig.userID` 传入，运行期通过 `identifyAccount:` 传入。

四个标识均为可选字段，统一去除首尾空格；空值及 `0/null/undefined/nan`（忽略大小写）按未传处理，不参与匹配，也不产生逐字段结果。以下约束适用于清洗后保留的值：

| 参数名称 | 参数类型 | 参数说明 |
| --- | --- | --- |
| userID | NSString | 最长 255 个 Unicode 字符；空值和保留值按上述统一规则处理 |
| anonymousID | NSString | 最长 256 个 Unicode 字符；空值和保留值按上述统一规则处理 |
| email | NSString | 去除首尾空格后非空，最长 256 个 Unicode 字符，须匹配 `\A[^@\s]+@[^@\s]+\z`；5.5.0 版本开始支持 |
| phone | NSString | 须匹配 E.164 格式 `\A\+[1-9]\d{1,14}\z`；5.5.0 版本开始支持 |
| completion | (^)(NSInteger code, NSString * message) | 主线程异步回调；初始化时返回初始化结果，运行期返回 `identifyAccount:` 的身份处理结果 |

非 `NSString` 或格式不合法的字段按 `3013`、超长字段按 `3003` 剔除并记录结果，其余合法字段继续提交。没有合法字段时，初始化按未传身份继续，`identifyAccount:` 返回 `-3` 且不发送请求。SDK 不修改调用方对象；email 由服务端转为小写。


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
| eventName | NSString | 事件 ID，必填，非空；以小写字母开头，只能包含小写字母、数字、下划线，最长 50 个 UTF-8 字节，且不能以 `el`、`engagelab`、`metaverse` 开头 |
| property | NSDictionary<NSString *, id> | 自定义属性（小于等于 100 个）。key 为 NSString，命名规则与 eventName 一致；value 可以是 NSString、NSNumber 或元素为 NSString 的 NSSet/NSArray |
