//
//  MockWebServerTests.m
//  MockWebServerTests
//
//  Created by jaehan on 11/28/2016.
//  Copyright (c) 2016 jaehan. All rights reserved.
//

// https://github.com/Specta/Specta

SpecBegin(InitialSpecs)

describe(@"these will fail", ^{
    
    it(@"Expect test response", ^{
        MockServerManager *manager = [[MockServerManager alloc] init];
        [manager requestContains:@"test"];
        [manager requestHeader:@"none" forKey:@"content-encoding"];
        [manager responseCode:200];
        [manager responseHeaders:@{@"Accept-encoding": @"*.*"}];
        [manager responseBody:@"test"];
        
        // TODO: need to start local server in thread.
        [manager startAndWait];
        
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
});

//describe(@"these will pass", ^{
//    
//    it(@"can do maths", ^{
//        expect(1).beLessThan(23);
//    });
//    
//    it(@"can read", ^{
//        expect(@"team").toNot.contain(@"I");
//    });
//    
//    it(@"will wait and succeed", ^{
//        waitUntil(^(DoneCallback done) {
//            done();
//        });
//    });
//});

SpecEnd

