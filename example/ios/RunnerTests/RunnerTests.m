#import <Flutter/Flutter.h>
#import <XCTest/XCTest.h>
#import <math.h>

@import flutter_plugin_engagelab_ma;

// This demonstrates a simple unit test of the Objective-C portion of this plugin's implementation.
//
// See https://developer.apple.com/documentation/xctest for more information about using XCTest.

@interface RunnerTests : XCTestCase

@end

@implementation RunnerTests

- (void)testCollectionSwitchRejectsNonBooleanValues {
  FlutterPluginEngagelabMaPlugin *plugin = [[FlutterPluginEngagelabMaPlugin alloc] init];
  for (id value in @[NSNull.null, @0, @1, @"false"]) {
    for (NSString *method in @[@"start", @"setDataCollectionEnabled"]) {
      FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:method
                                                                arguments:@{
        @"appKey": @"0123456789abcdef01234567",
        @"dataCollectionEnabled": value
      }];
      // A null initialization choice means omitted; a runtime setter requires a bool.
      if ([method isEqualToString:@"start"] && value == NSNull.null) continue;
      XCTestExpectation *expectation = [self expectationWithDescription:method];
      [plugin handleMethodCall:call result:^(id result) {
        XCTAssertTrue([result isKindOfClass:FlutterError.class]);
        XCTAssertEqualObjects(((FlutterError *)result).code, @"INVALID_ARGUMENT");
        [expectation fulfill];
      }];
      [self waitForExpectationsWithTimeout:1 handler:nil];
    }
  }
}

- (void)testStartWithoutAppKeyReturnsValidationError {
  FlutterPluginEngagelabMaPlugin *plugin = [[FlutterPluginEngagelabMaPlugin alloc] init];
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"start"
                                                              arguments:@{}];
  XCTestExpectation *expectation = [self expectationWithDescription:@"result block must be called"];
  [plugin handleMethodCall:call
                    result:^(id result) {
                      NSDictionary *response = (NSDictionary *)result;
                      XCTAssertEqualObjects(response[@"code"], @(-3));
                      XCTAssertEqualObjects(response[@"success"], @NO);
                      [expectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testUpdateObjectArrayIdentifierMutationReturnsValidationError {
  FlutterPluginEngagelabMaPlugin *plugin = [[FlutterPluginEngagelabMaPlugin alloc] init];
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"updateObjectArrayProperty"
                     arguments:@{
                       @"property" : @"devices",
                       @"identifierKey" : @"device_id",
                       @"identifierValue" : @"device-1",
                       @"values" : @{ @"device_id" : @"device-2" }
                     }];
  XCTestExpectation *expectation = [self expectationWithDescription:@"result block must be called"];
  [plugin handleMethodCall:call
                    result:^(id result) {
                      NSDictionary *response = (NSDictionary *)result;
                      XCTAssertEqualObjects(response[@"code"], @(-3));
                      XCTAssertEqualObjects(response[@"message"],
                                            @"object_array update parameters are invalid");
                      [expectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testObjectArrayBooleanIdentifierReturnsValidationError {
  FlutterPluginEngagelabMaPlugin *plugin = [[FlutterPluginEngagelabMaPlugin alloc] init];
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"removeObjectArrayProperty"
                     arguments:@{
                       @"property" : @"devices",
                       @"identifierKey" : @"enabled",
                       @"identifierValue" : @YES
                     }];
  XCTestExpectation *expectation = [self expectationWithDescription:@"result block must be called"];
  [plugin handleMethodCall:call
                    result:^(id result) {
                      NSDictionary *response = (NSDictionary *)result;
                      XCTAssertEqualObjects(response[@"code"], @(-3));
                      XCTAssertEqualObjects(response[@"message"],
                                            @"object_array removal parameters are invalid");
                      [expectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testObjectArrayNonFiniteIdentifierReturnsValidationError {
  FlutterPluginEngagelabMaPlugin *plugin = [[FlutterPluginEngagelabMaPlugin alloc] init];
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"updateObjectArrayProperty"
                     arguments:@{
                       @"property" : @"devices",
                       @"identifierKey" : @"sequence",
                       @"identifierValue" : @(NAN),
                       @"values" : @{ @"enabled" : @NO }
                     }];
  XCTestExpectation *expectation = [self expectationWithDescription:@"result block must be called"];
  [plugin handleMethodCall:call
                    result:^(id result) {
                      NSDictionary *response = (NSDictionary *)result;
                      XCTAssertEqualObjects(response[@"code"], @(-3));
                      [expectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAppendObjectArrayWithOnlyNullFieldsReturnsValidationError {
  FlutterPluginEngagelabMaPlugin *plugin = [[FlutterPluginEngagelabMaPlugin alloc] init];
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"appendObjectArrayProperty"
                     arguments:@{
                       @"property" : @"devices",
                       @"object" : @{ @"legacy_name" : NSNull.null }
                     }];
  XCTestExpectation *expectation = [self expectationWithDescription:@"result block must be called"];
  [plugin handleMethodCall:call
                    result:^(id result) {
                      NSDictionary *response = (NSDictionary *)result;
                      XCTAssertEqualObjects(response[@"code"], @(-3));
                      XCTAssertEqualObjects(response[@"message"],
                                            @"object_array append parameters are invalid");
                      [expectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testChannelValuesMustBeNonEmptyStrings {
  FlutterPluginEngagelabMaPlugin *plugin = [[FlutterPluginEngagelabMaPlugin alloc] init];
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"setChannelValue"
                     arguments:@{
                       @"channelId" : @136,
                       @"values" : @[ @"token", @"  " ]
                     }];
  XCTestExpectation *expectation = [self expectationWithDescription:@"result block must be called"];
  [plugin handleMethodCall:call
                    result:^(id result) {
                      NSDictionary *response = (NSDictionary *)result;
                      XCTAssertEqualObjects(response[@"code"], @(-3));
                      XCTAssertEqualObjects(
                          response[@"message"],
                          @"channelId must be a positive integer and values must contain non-empty strings");
                      [expectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
