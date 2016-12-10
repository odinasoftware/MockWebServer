//
//  MockWebServerTests.m
//  MockWebServerTests
//
//  Created by jaehan on 11/28/2016.
//  Copyright (c) 2016 jaehan. All rights reserved.
//

// https://github.com/Specta/Specta

SpecBegin(InitialSpecs)


describe(@"Mock server test with string", ^{
    
    __block MockServerManager *manager = nil;
    
    beforeEach(^{
        // This is run before each example.
        manager = [[MockServerManager alloc] init];
        [manager startServer];
    });
    
    afterEach(^{
        // This is run after each example.
        [manager stopServer];
    });

    
    it(@"will succeeded", ^{
        
        DispatchMap *dispatchMap = [[DispatchMap alloc] init];
        Dispatch *dispatch = [[Dispatch alloc] init];
        [dispatch requestContainString:@"test"];
        [dispatch setResponseCode:200];
        [dispatch responseString:@"test"];
        [dispatch responseHeaders:@{@"Accept-encoding": @"*.*"}];
        [dispatchMap addDispatch:dispatch];
        [manager setDispatch:dispatchMap];
        
        NSString *dataUrl = @"http://127.0.0.1:9000/test";
        NSURL *url = [NSURL URLWithString:dataUrl];
        
        waitUntil(^(DoneCallback done) {
            NSURLSessionDataTask *test = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              // 4: Handle response here
                                              NSLog(@"data=%@", [NSString stringWithUTF8String:[data bytes]]);
                                              
                                              XCTAssert([[NSString stringWithUTF8String:[data bytes]] compare:@"test"]==0, @"Body doesn't match.");
                                              done();
                                             
                                          }];
            
            // 3
            [test resume];
        });
    });
    
    it(@"will fail", ^{
        
        DispatchMap *dispatchMap = [[DispatchMap alloc] init];
        Dispatch *dispatch = [[Dispatch alloc] init];
        [dispatch requestContainString:@"test1"];
        [dispatch setResponseCode:200];
        [dispatch responseBodyForBundle:DEFAULT_BUNDLE fromFile:@"response.json"];
        [dispatch responseHeaders:@{@"Accept-encoding": @"*.*"}];
        [dispatchMap addDispatch:dispatch];
        [manager setDispatch:dispatchMap];
        
        
        NSString *dataUrl = @"http://127.0.0.1:9000/test1";
        NSURL *url = [NSURL URLWithString:dataUrl];
        
        waitUntil(^(DoneCallback done) {
            NSURLSessionDataTask *test = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              // 4: Handle response here
                                              NSLog(@"data=%@", [NSString stringWithUTF8String:[data bytes]]);
                                              
                                              XCTAssert([[NSString stringWithUTF8String:[data bytes]] compare:@"test"]==0, @"Body doesn't match.");
                                              done();
                                           
                                          }];
            
            // 3
            [test resume];
        });
    });
    
    it(@"Mulitpe request example", ^{
        DispatchMap *dispatchMap = [[DispatchMap alloc] init];
        Dispatch *dispatch = [[Dispatch alloc] init];
        [dispatch requestContainString:@"test2"];
        [dispatch setResponseCode:200];
        [dispatch responseString:@"test"];
        [dispatch responseHeaders:@{@"Accept-encoding": @"*.*"}];
        [dispatchMap addDispatch:dispatch];
        
        dispatch = [[Dispatch alloc] init];
        [dispatch requestContainString:@"test3"];
        [dispatch setResponseCode:200];
        [dispatch responseBodyForBundle:DEFAULT_BUNDLE fromFile:@"response.json"];
        [dispatch responseHeaders:@{@"Accept-encoding": @"*.*"}];
        [dispatchMap addDispatch:dispatch];
        
        [manager setDispatch:dispatchMap];
        
        NSString *dataUrl = @"http://127.0.0.1:9000/test2";
        NSURL *url = [NSURL URLWithString:dataUrl];
        
        waitUntil(^(DoneCallback done) {
            NSURLSessionDataTask *test = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              // 4: Handle response here
                                              NSLog(@"data=%@", [NSString stringWithUTF8String:[data bytes]]);
                                              
                                              XCTAssert([[NSString stringWithUTF8String:[data bytes]] compare:@"test"]==0, @"Body doesn't match.");
                                              done();
                                              
                                          }];
            
            // 3
            [test resume];
        });
        
        dataUrl = @"http://127.0.0.1:9000/test3";
        url = [NSURL URLWithString:dataUrl];
        
        waitUntil(^(DoneCallback done) {
            NSURLSessionDataTask *test = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              // 4: Handle response here
                                              NSLog(@"data=%@", [NSString stringWithUTF8String:[data bytes]]);
                                              
                                              XCTAssert([[NSString stringWithUTF8String:[data bytes]] compare:@"test"]==0, @"Body doesn't match.");
                                              done();
                                     
                                          }];
            
            // 3
            [test resume];
        });

        
    });

});

SpecEnd

