//
//  LocalServerManager.h
//  BBCReader
//
//  Created by Jae Han on 12/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_BUNDLE [NSBundle bundleForClass:[self class]]

@class MockServer;
@class DispatchMap;

@interface MockWebServer : NSThread {
	NSInteger	activeThread;
	NSCondition	*waitForThread;
    BOOL        isListening;
    BOOL        isStopped;
    int         listenfd;
}

@property(nonatomic, retain)    DispatchMap     *dispatchMap;

- (void)startServer;
- (void)stopServer;
- (void)startLocalServerManager;
- (void)exitConnThread:(id)thread;
- (void)requestContains:(NSString*)request;
- (void)requestHeader:(NSString*)value forKey:(NSString*)key;
- (void)requestHeaders:(NSDictionary*)headers;
- (void)responseHeaders:(NSDictionary*)headers;
- (void)responseBody:(NSString*)body;
- (void)responseCode:(NSInteger)code;
- (void)setDispatch:(DispatchMap*)dispatch;
@end
