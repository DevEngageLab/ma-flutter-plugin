#import "FlutterPluginEngagelabMaPlugin.h"
#import "MTMAService.h"
#import <CoreFoundation/CoreFoundation.h>
#import <math.h>

static BOOL MTMAIsNonEmptyString(id value) {
    if (![value isKindOfClass:NSString.class]) {
        return NO;
    }
    NSString *trimmed = [(NSString *)value
        stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return trimmed.length > 0;
}

static BOOL MTMAIsBooleanNumber(NSNumber *value) {
    return CFGetTypeID((__bridge CFTypeRef)value) == CFBooleanGetTypeID();
}

static BOOL MTMAIsValidIdentifierValue(id value) {
    if ([value isKindOfClass:NSString.class]) {
        return YES;
    }
    if (![value isKindOfClass:NSNumber.class] || MTMAIsBooleanNumber(value)) {
        return NO;
    }
    return isfinite([(NSNumber *)value doubleValue]);
}

static BOOL MTMAIsValidChannelId(id value) {
    if (![value isKindOfClass:NSNumber.class] || MTMAIsBooleanNumber(value)) {
        return NO;
    }
    double number = [(NSNumber *)value doubleValue];
    return isfinite(number) && number > 0 && floor(number) == number &&
           number <= (double)NSIntegerMax;
}

static BOOL MTMAHasOnlyNonEmptyStrings(id value) {
    if (![value isKindOfClass:NSArray.class] || [(NSArray *)value count] == 0) {
        return NO;
    }
    for (id item in (NSArray *)value) {
        if (!MTMAIsNonEmptyString(item)) {
            return NO;
        }
    }
    return YES;
}

static BOOL MTMAHasNonNullField(NSDictionary *object) {
    for (id value in object.allValues) {
        if (value != NSNull.null) {
            return YES;
        }
    }
    return NO;
}

@implementation FlutterPluginEngagelabMaPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_plugin_engagelab_ma"
            binaryMessenger:[registrar messenger]];
  FlutterPluginEngagelabMaPlugin* instance = [[FlutterPluginEngagelabMaPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"start" isEqualToString:call.method]) {
        NSDictionary *args = [call.arguments isKindOfClass:NSDictionary.class] ? call.arguments : @{};
        NSString *appKey = [args[@"appKey"] isKindOfClass:NSString.class] ? args[@"appKey"] : nil;
        if (!MTMAIsNonEmptyString(appKey)) {
            result(@{
                @"code": @(-3),
                @"message": @"MA AppKey is required",
                @"euid": @"",
                @"maRid": @"",
                @"success": @NO
            });
            return;
        }

        MTMAConfig *config = [[MTMAConfig alloc] init];
        config.appKey = appKey;
        MTMAUserID *user = [[MTMAUserID alloc] init];
        NSString *anonymousId = [args[@"anonymousId"] isKindOfClass:NSString.class] ? args[@"anonymousId"] : nil;
        NSString *userId = [args[@"userId"] isKindOfClass:NSString.class] ? args[@"userId"] : nil;
        NSString *email = [args[@"email"] isKindOfClass:NSString.class] ? args[@"email"] : nil;
        NSString *phone = [args[@"phone"] isKindOfClass:NSString.class] ? args[@"phone"] : nil;
        if (anonymousId.length > 0) {
            user.anonymousID = anonymousId;
        }
        if (userId.length > 0) {
            user.userID = userId;
        }
        if (email.length > 0) {
            user.email = email;
        }
        if (phone.length > 0) {
            user.phone = phone;
        }
        if (anonymousId.length > 0 || userId.length > 0 || email.length > 0 || phone.length > 0) {
            config.userID = user;
        }
        config.resultCompletion = ^(MTMAInitResult *initResult) {
            if (initResult == nil) {
                result(@{
                    @"code": @(-1),
                    @"message": @"MA initialization returned no result",
                    @"euid": @"",
                    @"maRid": @"",
                    @"success": @NO
                });
                return;
            }
            result(@{
                @"code": @(initResult.code),
                @"message": initResult.message ?: @"",
                @"euid": initResult.EUID ?: @"",
                @"maRid": initResult.maRID ?: @"",
                @"success": @(initResult.success)
            });
        };
        [MTMAService start:config];
    } else if ([@"setUserContact" isEqualToString:call.method]) {
        NSDictionary *args = call.arguments;
        MTMAUserContact *contact = [[MTMAUserContact alloc] init];
        contact.contacts = args[@"contacts"];
        contact.completion = ^(NSInteger code, NSString * _Nonnull message) {
            result(@{@"code": @(code), @"message": message ?: @""});
        };
        [MTMAService setUserContact:contact];
    } else if ([@"setUserIdentity" isEqualToString:call.method]) {
        NSDictionary *args = call.arguments;
        MTMAUserID *userid = [[MTMAUserID alloc] init];
        NSString *anonymousId = args[@"anonymousId"];
        NSString *userId = args[@"userId"];
        NSString *email = [args[@"email"] isKindOfClass:NSString.class] ? args[@"email"] : nil;
        NSString *phone = [args[@"phone"] isKindOfClass:NSString.class] ? args[@"phone"] : nil;
        if (![anonymousId isKindOfClass:[NSNull class]] && anonymousId != nil && anonymousId.length > 0) {
            userid.anonymousID = anonymousId;
        }
        if (![userId isKindOfClass:[NSNull class]] &&userId != nil && userId.length > 0) {
            userid.userID = userId;
        }
        if (email.length > 0) {
            userid.email = email;
        }
        if (phone.length > 0) {
            userid.phone = phone;
        }
        userid.completion = ^(NSInteger code, NSString * _Nonnull message) {
            result(@{@"code": @(code), @"message": message ?: @""});
        };
        [MTMAService identifyAccount:userid];
    } else if ([@"setReportInterval" isEqualToString:call.method]) {
        NSDictionary *args = call.arguments;
        NSNumber *interval = args[@"interval"];
        [MTMAService setReportInterval:[interval integerValue]];
        result(@YES);
    } else if ([@"setMaxEventCacheCount" isEqualToString:call.method]) {
        NSDictionary *args = call.arguments;
        NSNumber *count = args[@"count"];
        [MTMAService setMaxEventCacheCount:[count integerValue]];
        result(@YES);
    } else if ([@"setNoActiveSessionEndDurationTime" isEqualToString:call.method]) {
        NSDictionary *args = call.arguments;
        NSNumber *interval = args[@"duration"];
        [MTMAService setNoActiveSessionEndDurationTime:[interval integerValue]];
        result(@YES);
    } else if ([@"getEuid" isEqualToString:call.method]) {
        result([MTMAService EUID] ?: @"");
    } else if ([@"getMaRid" isEqualToString:call.method]) {
        result([MTMAService maRID] ?: @"");
    } else if ([@"setChannelValue" isEqualToString:call.method]) {
        NSDictionary *args = [call.arguments isKindOfClass:NSDictionary.class] ? call.arguments : @{};
        NSNumber *channelId = [args[@"channelId"] isKindOfClass:NSNumber.class] ? args[@"channelId"] : nil;
        NSArray *values = [args[@"values"] isKindOfClass:NSArray.class] ? args[@"values"] : nil;
        if (!MTMAIsValidChannelId(channelId) || !MTMAHasOnlyNonEmptyStrings(values)) {
            result(@{
                @"code": @(-3),
                @"message": @"channelId must be a positive integer and values must contain non-empty strings"
            });
            return;
        }
        [MTMAService setChannelValueWithChannelId:channelId.integerValue
                                           values:values
                                       completion:^(NSInteger code, NSString *message) {
            result(@{
                @"code": @(code),
                @"message": message ?: @""
            });
        }];
    } else if ([@"updateObjectArrayProperty" isEqualToString:call.method]) {
        NSDictionary *args = [call.arguments isKindOfClass:NSDictionary.class] ? call.arguments : @{};
        NSString *property = [args[@"property"] isKindOfClass:NSString.class] ? args[@"property"] : nil;
        NSString *identifierKey = [args[@"identifierKey"] isKindOfClass:NSString.class] ? args[@"identifierKey"] : nil;
        id identifierValue = args[@"identifierValue"];
        NSDictionary *values = [args[@"values"] isKindOfClass:NSDictionary.class] ? args[@"values"] : nil;
        if (!MTMAIsNonEmptyString(property) || !MTMAIsNonEmptyString(identifierKey) ||
            !MTMAIsValidIdentifierValue(identifierValue) ||
            values.count == 0 || values[identifierKey] != nil) {
            result(@{
                @"code": @(-3),
                @"message": @"object_array update parameters are invalid"
            });
            return;
        }
        [MTMAService updateObjectArrayProperty:property
                                 identifierKey:identifierKey
                               identifierValue:identifierValue
                                        values:values
                                    completion:^(NSInteger code, NSString *message) {
            result(@{
                @"code": @(code),
                @"message": message ?: @""
            });
        }];
    } else if ([@"appendObjectArrayProperty" isEqualToString:call.method]) {
        NSDictionary *args = [call.arguments isKindOfClass:NSDictionary.class] ? call.arguments : @{};
        NSString *property = [args[@"property"] isKindOfClass:NSString.class] ? args[@"property"] : nil;
        NSDictionary *object = [args[@"object"] isKindOfClass:NSDictionary.class] ? args[@"object"] : nil;
        if (!MTMAIsNonEmptyString(property) || object.count == 0 ||
            !MTMAHasNonNullField(object)) {
            result(@{
                @"code": @(-3),
                @"message": @"object_array append parameters are invalid"
            });
            return;
        }
        [MTMAService addObjectArrayProperty:property
                                    object:object
                                completion:^(NSInteger code, NSString *message) {
            result(@{
                @"code": @(code),
                @"message": message ?: @""
            });
        }];
    } else if ([@"removeObjectArrayProperty" isEqualToString:call.method]) {
        NSDictionary *args = [call.arguments isKindOfClass:NSDictionary.class] ? call.arguments : @{};
        NSString *property = [args[@"property"] isKindOfClass:NSString.class] ? args[@"property"] : nil;
        NSString *identifierKey = [args[@"identifierKey"] isKindOfClass:NSString.class] ? args[@"identifierKey"] : nil;
        id identifierValue = args[@"identifierValue"];
        if (!MTMAIsNonEmptyString(property) || !MTMAIsNonEmptyString(identifierKey) ||
            !MTMAIsValidIdentifierValue(identifierValue)) {
            result(@{
                @"code": @(-3),
                @"message": @"object_array removal parameters are invalid"
            });
            return;
        }
        [MTMAService removeObjectArrayProperty:property
                                 identifierKey:identifierKey
                               identifierValue:identifierValue
                                    completion:^(NSInteger code, NSString *message) {
            result(@{
                @"code": @(code),
                @"message": message ?: @""
            });
        }];
    } else if ([@"setUtmProperties" isEqualToString:call.method]) {
        NSDictionary *property = call.arguments;
        [MTMAService setUtmProperties:property];
        result(@YES);
    }  else if ([@"setUserProperties" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        NSDictionary *properties = arguments[@"properties"];
        
        [MTMAService setProperty:properties completion:^(NSInteger code, NSString * _Nonnull message) {
            NSDictionary *response = @{
                @"code": @(code),
                @"message": message?:@""
            };
            result(response);
        }];
    } else if ([@"incrementUserProperties" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        NSDictionary *properties = arguments[@"properties"];
        
        [MTMAService increaseProperty:properties completion:^(NSInteger code, NSString * _Nonnull message) {
            NSDictionary *response = @{
                @"code": @(code),
                @"message": message?:@""
            };
            result(response);
        }];
    } else if ([@"appendUserProperties" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        NSString *property = arguments[@"property"];
        NSArray *value = arguments[@"value"];
        
        [MTMAService addProperty:property by:value completion:^(NSInteger code, NSString * _Nonnull message) {
            NSDictionary *response = @{
                @"code": @(code),
                @"message": message?:@""
            };
            result(response);
        }];
    } else if ([@"removeUserProperties" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        NSString *property = arguments[@"property"];
        NSArray *value = arguments[@"value"];
        
        [MTMAService removeProperty:property by:value completion:^(NSInteger code, NSString * _Nonnull message) {
            NSDictionary *response = @{
                @"code": @(code),
                @"message": message?:@""
            };
            result(response);
        }];
    } else if ([@"deleteUserProperty" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        NSString *property = arguments[@"property"];
        
        [MTMAService deleteProperty:property completion:^(NSInteger code, NSString * _Nonnull message) {
            NSDictionary *response = @{
                @"code": @(code),
                @"message": message?:@""
            };
            result(response);
        }];
        
    } else if ([@"eventRecord" isEqualToString:call.method]) {
            NSDictionary *args = call.arguments;
            MTMAEventObject *object = [[MTMAEventObject alloc] init];
            object.eventName = args[@"eventName"];
            object.property = args[@"property"];
            [MTMAService eventRecord:object];
            result(@YES);
    } else if ([@"setCollectControl" isEqualToString:call.method]) {
        NSDictionary *args = call.arguments;
        MTMACollectControl *control = [[MTMACollectControl alloc] init];
        if (args[@"idfa"]) {
            control.idfa = [args[@"idfa"] boolValue];
        }
        if (args[@"idfv"]) {
            control.idfv = [args[@"idfv"] boolValue];
        }
        if (args[@"carrier"]) {
            control.carrier = [args[@"carrier"] boolValue];
        }
        [MTMAService setCollectControl:control];
        result(@YES);
    } else {
        result(FlutterMethodNotImplemented);
    }
}


@end
