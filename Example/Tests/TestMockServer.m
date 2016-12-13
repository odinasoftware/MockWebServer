//
//  TestMockServer.m
//  MockWebServer
//
//  Created by Jae Han on 12/10/16.
//  Copyright © 2016 jaehan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MockWebServer/MockWebServer.h>

@interface TestMockServer : XCTestCase {

    MockWebServer *mockWebServer;
}

@end

@implementation TestMockServer

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    mockWebServer = [[MockWebServer alloc] init];
    [mockWebServer start];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [mockWebServer stop];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    DispatchMap *dispatchMap = [[DispatchMap alloc] init];
    Dispatch *dispatch = [[Dispatch alloc] init];
    [dispatch requestContainString:@"test"];
    [dispatch setResponseCode:200];
    [dispatch responseString:@"test"];
    [dispatch responseHeaders:@{@"Accept-encoding": @"*.*"}];
    [dispatchMap addDispatch:dispatch];
    [mockWebServer setDispatch:dispatchMap];
    
    TestConditionWait *testWait = [[TestConditionWait alloc] init];
    NSString *dataUrl = @"http://127.0.0.1:9000/test";
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    NSURLSessionDataTask *test = [[NSURLSession sharedSession]
                                  dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                      // 4: Handle response here
                                      NSLog(@"data=%@", [NSString stringWithUTF8String:[data bytes]]);
                                      
                                      XCTAssert([[NSString stringWithUTF8String:[data bytes]] compare:@"test"]==0, @"Body doesn't match.");
                                    
                                      [testWait wakeup];
                                  }];
    
    // 3
    [test resume];
    [testWait wait];

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
