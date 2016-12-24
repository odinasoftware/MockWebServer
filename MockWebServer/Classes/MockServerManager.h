//
//  LocalServerManager.h
//
//
//  Created by Jae Han on 12/29/08.
//  Copyright © 2016 Jae Han. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_BUNDLE [NSBundle bundleForClass:[self class]]

@class MockServer;
@class DispatchMap;

@interface MockWebServerManager : NSThread

@property(nonatomic, readonly)    DispatchMap     *dispatchMap;
@end

@interface MockWebServer : NSObject

- (void)start:(int)port;
- (void)stop;

- (void)setDispatch:(DispatchMap*)dispatch;
@end
