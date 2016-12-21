//
//  LocalServer.h
//  NYTReader
//
//  Created by Jae Han on 9/21/08.
//  Copyright © 2016 Jae Han. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LOCAL_BUFFER_SIZE	1024

typedef enum {SEARCH_METHOD,
    SEARCH_REQUEST,
    BEGIN_NEW_LINE,
    SEARCH_REQUEST_FIELD,
    SEARCH_REQUEST_VALUE,
    SKIP_TO_NEXT_LINE,
    BODY_START
} request_parser_mode_t;

@class NetworkService;
@class WebCacheService;
@class MockWebServerManager;
@class HTTPUrlHelper;
@class Dispatch;

@interface MockServer : NSThread {
	BOOL	stopIt;
	NSString *localRequest;
	BOOL	isRequestValid;
	
	@private
	//int signal_pipe[2];
	int currentReadPtr;
	int currentWritePtr;
	int markIndex;
	request_parser_mode_t parserMode;
	NetworkService *theNetworkService;
	WebCacheService *theCacheService;
	NSData	*theNotFoundBody;
	NSData	*theNotFoundResHeader;
	BOOL needToDisplaySplash;
	int connectedFD;
    BOOL isRequestMatched;
    
	unsigned char local_buffer[LOCAL_BUFFER_SIZE];
}

@property (nonatomic, retain)   MockWebServerManager    *serverManager;
@property (assign)              BOOL                    stopIt;
@property (assign)              BOOL                    isRequestValid;
@property (nonatomic, retain)   NSString                *localRequest;
@property (nonatomic, retain)   NSMutableDictionary     *headers;
@property (nonatomic, retain)   Dispatch                *dispatch;

- (id)initWithManager:(MockWebServerManager*)manager connFD:(int)fd;
//- (void)startLocalServer;
- (void)stopLocalServer;
- (BOOL)readFromConnection:(int)connfd;
- (int)processRequestHeader:(ssize_t)count;
- (void)resetConnection;
- (void)initSignalHandler;

@end
