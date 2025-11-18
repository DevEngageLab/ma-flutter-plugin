//
//  MTMAService.h
//  MTMA
//
//  Created by Shuni Huang on 2024/11/2.
//

#import <Foundation/Foundation.h>

#define MTMA_VERSION_NUMBER 5.2.2

NS_ASSUME_NONNULL_BEGIN
@class MTMAUserID;
@class MTMAUserContact;
@class MTMAEventObject;

@interface MTMAConfig : NSObject

/* 用户标识模型,当设置该属性时时会在初始化时进行设置用户标识 */
@property (nonatomic, strong) MTMAUserID *userID;

/* 请求结果回调, code:0为成功 */
@property (nonatomic, copy) void (^completion)(NSInteger code, NSString * message);

@end

@interface MTMACollectControl : NSObject

/* idfa idfa信息。设置为NO,不采集idfa信息。默认为NO。*/
@property (nonatomic, assign) BOOL idfa;
/* idfv idfv信息。设置为NO,不采集idfv信息。默认为NO。*/
@property (nonatomic, assign) BOOL idfv;
/* carrier 运营商信息。设置为NO,不采集运营商信息。默认为YES。 */
@property (nonatomic, assign) BOOL carrier;

@end


@interface MTMAService : NSObject

/*!
 * @abstract 初始化SDK
 *
 */
+ (void)start:(MTMAConfig *)config;

/**
 设置用户标识
 
 @param userID 用户标识模型
 */
+ (void)identifyAccount:(MTMAUserID *)userID;

/**
 设置用户联系方式
 
 @param contact 用户联系方式模型
 */
+ (void)setUserContact:(MTMAUserContact *)contact;

/*！自定义事件统计
 *
 * @param event 上报的自定义事件模型
 */
+ (void)eventRecord:(MTMAEventObject *)event;

/**
 设置上报数据间隔，不调用该接口时，默认为10s上报一次事件数据
 上报间隔内存缓存，需要在应用程序每次生命周期中调用才会生效
 
 @param interval 上报间隔，单位s(秒)
 */
+ (void)setReportInterval:(NSInteger)interval;

/**
    设置事件缓存上限条数，默认50条，最高不能超过500条
    当超出缓存数量时会上报全部数据
    @param count 事件缓存条数上限
 */
+ (void)setMaxEventCacheCount:(NSInteger)count;

/**
 设置会话超时时间
 APP切换到后台，会话开始超时计时，超时时间内没有活动，就结束当前会话
 
 @param interval 超时时长，单位s(秒)
 */
+ (void)setNoActiveSessionEndDurationTime:(NSInteger)interval;

/**
 获取运营增长EUID
 */
+ (NSString *)EUID;

/**
 * 设置UTM属性
 *
 * @discussion
 * UTM属性为预置属性
 * 目前能够设置UTM属性为
 * utm_source 广告系列来源
 * utm_medium 广告系列媒介
 * utm_term 广告系列字词
 * utm_content 广告系列内容
 * utm_campaign 广告系列名称
 * utm_id 广告系列ID
 *
 */
+ (void)setUtmProperties:(NSDictionary<NSString*, NSString *> *)property;

/**
 * @abstract
 * 设置用户属性
 *
 * 这些 用户属性 的内容用一个 NSDictionary 来存储
 * 其中的 key 是 用户属性 的名称，必须是 NSString
 * Value 则是 用户属性 的内容，只支持 NSString、NSNumber，NSSet、NSArray 这些类型
 * 特别的，NSSet 或者 NSArray 类型的 value 中目前只支持其中的元素是 NSString
 * 如果某个 用户属性 之前已经存在了，则这次会被覆盖掉；不存在，则会创建
 *
 * @param userinfo 要替换的那些 用户属性 的内容
 * @param completion 回调
 */
+ (void)setProperty:(NSDictionary *)userinfo completion:(void (^)(NSInteger code, NSString * message))completion;
 
/**
 * @abstract
 * 设置用户的单个 用户属性 的内容
 *
 * 如果这个 用户属性 之前已经存在了，则这次会被覆盖掉；不存在，则会创建
 * Value 是 用户属性 的内容，只支持 NSString、NSNumber，NSSet、NSArray 这些类型
 * 特别的，NSSet 或者 NSArray 类型的 value 中目前只支持其中的元素是 NSString
 *
 * @param key 用户属性 的名称
 * @param value 用户属性 的内容
 * @param completion 回调
 */
+ (void)setProperty:(NSString *)key to:(id)value completion:(void (^)(NSInteger code, NSString * message))completion;
 
/**
 * @abstract
 * 给一个数值类型的 用户属性 增加一个数值
 *
 * 只能对 NSNumber 类型的 用户属性 调用这个接口，否则会被忽略
 * 如果这个 用户属性 之前不存在，则初始值当做 0 来处理
 *
 * @param key  待增加数值的 用户属性 的名称
 * @param amount   要增加的数值
 * @param completion 回调
 */
+ (void)increaseProperty:(NSString *)key by:(NSNumber *)amount completion:(void (^)(NSInteger code, NSString * message))completion;
 
/**
 * @abstract
 * 给多个数值类型的 用户属性 增加数值
 *
 * userinfo 中，key 是 NSString ，value 是 NSNumber
 * 其它与 - (void)increase:by: 相同
 *
 * @param userinfo 多个
 * @param completion 回调
 */
+ (void)increaseProperty:(NSDictionary *)userinfo completion:(void (^)(NSInteger code, NSString * message))completion;
 
/**
 * @abstract
 * 向一个 NSSet 或者 NSArray 类型的属性 添加一些值
 *
 * 如前面所述，这个 NSSet 或者 NSArray 的元素必须是 NSString，否则，会忽略
 * 同时，如果要 append 的 用户属性 之前不存在，会初始化一个空的 NSSet 或者 NSArray
 *
 * @param key key
 * @param content  NSSet 或者 NSArray
 * @param completion 回调
 */
+ (void)addProperty:(NSString *)key by:(NSObject<NSFastEnumeration> *)content completion:(void (^)(NSInteger code, NSString * message))completion;

/**
 * @abstract
 * 向多个 NSSet 或者 NSArray 类型的属性 添加一些值
 *
 * userinfo 中，key 是 NSString ，value 是 NSSet 或者 NSArray
 * 其它与 - (void)append:by: 相同
 *
 * @param userinfo 多个
 * @param completion 回调
 */
+ (void)addProperty:(NSDictionary *)userinfo completion:(void (^)(NSInteger code, NSString * message))completion;


/**
 * @abstract
 * 向一个 NSSet 或者 NSArray 类型的属性 删除一些值
 *
 * @param key key
 * @param content NSSet 或者 NSArray 类型，里面的元素必须是 NSString
 * @param completion 回调
 */
+ (void)removeProperty:(NSString * )key by:(NSObject<NSFastEnumeration> *)content completion:(void (^)(NSInteger code, NSString * message))completion;

     
/**
 * @abstract
 * 删除某个 用户属性 的全部内容
 * 如果这个 用户属性 之前不存在，则直接忽略
 *
 * @param key 用户属性 的名称
 * @param completion 回调
 */
+ (void)deleteProperty:(NSString *)key completion:(void (^)(NSInteger code, NSString * message))completion;

/**
 数据采集控制
 
 @param control 数据采集配置。
 */
+ (void)setCollectControl:(MTMACollectControl *)control;


@end

//用户标识模型
@interface MTMAUserID : NSObject

/* userID，将唯一的登录用户标识设置在此 */
@property (nonatomic, copy) NSString *userID;

/* anonymousId，当用户未登录，但提供了其他可作为标识的信息时，可将其设置为匿名ID，如邮箱地址、第三方生成的标识ID */
@property (nonatomic, copy) NSString *anonymousID;

/* 请求结果回调, code:0为成功 */
@property (nonatomic, copy) void (^completion)(NSInteger code, NSString * message);

@end


/**
 * @abstract 自定义事件对象
 *
 * @discussion 所有的字符串属性长度不能超过256字节（包括extra的key）
 *
 */
@interface MTMAEventObject : NSObject
//事件ID，必填，非空，不能使用el前缀
@property (nonatomic, copy, nonnull) NSString * eventName;
//自定义属性（<=500个）key为NSString，只能包含数字小写字母下划线，以及以字母开头
@property (nonatomic, strong, nonnull) NSDictionary<NSString *, id> * property;

@end


//用户联系方式模型
@interface MTMAUserContact: NSObject

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *contacts;

/* 请求结果回调, code:0为成功 */
@property (nonatomic, copy) void (^completion)(NSInteger code, NSString * message);

@end


NS_ASSUME_NONNULL_END
