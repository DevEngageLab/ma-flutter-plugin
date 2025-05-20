#import "FlutterPluginEngagelabMaPlugin.h"
#import "MTMAService.h"

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
        NSDictionary *args = call.arguments;
        MTMAConfig *config = [[MTMAConfig alloc] init];
        MTMAUserID *user = [[MTMAUserID alloc] init];
        user.userID = args[@"userId"];
        user.anonymousID =  args[@"anonymousId"];
        config.completion = ^(NSInteger code, NSString * _Nonnull message) {
            result(@{
                @"code": @(code),
                @"message": message?:@""
            });
        };
        [MTMAService start:config];
    } else if ([@"setUserContact" isEqualToString:call.method]) {
        NSDictionary *args = call.arguments;
        MTMAUserContact *contact = [[MTMAUserContact alloc] init];
        contact.contacts = args[@"contacts"];
        contact.completion = ^(NSInteger code, NSString * _Nonnull message) {
            result(@{@"code": @(code), @"message": message});
        };
        [MTMAService setUserContact:contact];
    } else if ([@"setUserIdentity" isEqualToString:call.method]) {
        NSDictionary *args = call.arguments;
        MTMAUserID *userid = [[MTMAUserID alloc] init];
        userid.anonymousID = args[@"anonymousId"];
        userid.userID = args[@"userId"];
        userid.completion = ^(NSInteger code, NSString * _Nonnull message) {
            result(@{@"code": @(code), @"message": message});
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
        NSString *euid = [MTMAService EUID];
        result(euid);
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
        NSDictionary *value = arguments[@"value"];
        
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
