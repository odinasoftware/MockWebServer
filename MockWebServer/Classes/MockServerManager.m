//
//  LocalServerManager.m
//  
//
//  Created by Jae Han on 12/29/08.
//  Copyright © 2016 Jae Han. All rights reserved.
//
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <fcntl.h>
#include <netinet/tcp.h>

#include "Common_Defs.h"

#import "MockServer.h"
#import "MockServerManager.h"
#import "DispatchMap.h"

#define MAX_LOCAL_SERVER_THREAD	1
#define INTERRUPT_SIGNAL        2
#define LISTENQ					32


@interface MockWebServerManager() {
    NSInteger	activeThread;
    NSCondition	*waitForThread;
    BOOL        isListening;
    BOOL        isStopped;
    int         listenfd;
    int         listeningPort;
}


- (void)startServer:(int)port;
- (void)stopServer;
- (void)startLocalServerManager;
- (void)exitConnThread:(id)thread;

- (void)setDispatch:(DispatchMap*)dispatch;

@end

@implementation MockWebServerManager

@synthesize dispatchMap;

- (id)init
{
	if ((self = [super init])) {
		waitForThread = [[NSCondition alloc] init];
		activeThread = 0;
        isListening = false;
//        self.requestHeaders = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (void)startServer:(int)port
{
    self->listeningPort = port;
    [self start];
    
    [waitForThread lock];
    while (isListening == false && isStopped == NO) {
        TRACE("%s, waiting for listening thread.\n", __func__);
        [waitForThread wait];
    }
    [waitForThread unlock];
    TRACE("%s, exit wait.", __func__);
}

- (void)startLocalServerManager
{
	int connfd=-1;
	struct sockaddr_in cliaddr, servaddr;
	unsigned int clilen = 0;
	int optval = 1;
	int onoff = 0;
	BOOL get_new_socket = NO;	
	
	
	//TRACE("%s, ttl: %d\n", __func__, ttl);
    
    self->listenfd = -1;
    self->isStopped = NO;
	
    listenfd = socket(AF_INET, SOCK_STREAM, 0);
    
    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servaddr.sin_port = htons(self->listeningPort);
    setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof(optval));
    if (bind(listenfd, (const struct sockaddr*)&servaddr, sizeof(servaddr)) < 0) {
        NSLog(@"%s: bind error=%s", __func__, strerror(errno));
        
        isStopped = YES;
        return;
    }
    
    
    if (listen(listenfd, LISTENQ) < 0) {
        NSLog(@"%s: listen error=%s", __func__, strerror(errno));
        
        isStopped = YES;
        
        return;
    }
    
    [waitForThread lock];
    isListening = true;
    [waitForThread broadcast];
    [waitForThread unlock];
    
    do {
        @try {
            
            TRACE("~~~~ before accept ~~~~~~\n");
            if ((connfd = accept(listenfd, (struct sockaddr*)&cliaddr, &clilen)) < 0) {
                if (errno == EINTR)
                    continue;
                else {
                    NSLog(@"%s, accept error: %s", __func__, strerror(errno));
                    get_new_socket = YES;
                    continue;
                }
            }
            
            TRACE("MockServerManager, accepting connection: %d from listening %d\n", connfd, listenfd);
            //setsockopt(connfd, SOL_SOCKET, SO_LINGER, &l_onoff, sizeof(l_onoff));
            if (setsockopt(connfd, IPPROTO_TCP, TCP_NODELAY, &onoff, sizeof(onoff)) < 0) {
                NSLog(@"%s, failed to set nodelay. %s", __func__, strerror(errno));
            }
            
            MockServer *server = [[MockServer alloc] initWithManager:self connFD:connfd];
            TRACE("Starting thread: %p\n", server);
            [server start];
            
            if (++activeThread >= MAX_LOCAL_SERVER_THREAD) {
                [waitForThread lock];
                TRACE("%s, waiting for available thread.\n", __func__);
                [waitForThread wait];
                [waitForThread unlock];
                TRACE("%s, thread is available.\n", __func__);
            }
            
        } @catch (NSException *exception) {
            NSLog(@"%s: main: %@: %@", __func__, [exception name], [exception reason]);
        }
    } while (get_new_socket == NO && self->isStopped == NO);
    
    if (self->isStopped == YES) {
        TRACE("Listening thread exiting.\n");
        return;
    }
    shutdown(listenfd, SHUT_RDWR);
    close(listenfd);
    NSLog(@"Close %d socket.\n", listenfd);
    get_new_socket = NO;
	
}

- (void)stopServer
{
    shutdown(self->listenfd, SHUT_RDWR);
    close(self->listenfd);
    self->dispatchMap = nil;
    
    TRACE("%s=%d", __func__, self->listenfd);
}

- (void)exitConnThread:(id)thread
{
    --activeThread;
	[waitForThread signal];
    TRACE("%s, id: %p, n=%d\n", __func__, thread, activeThread);
}
	
- (void)main 
{	
	[self startLocalServerManager];
	
}

- (void)setDispatch:(DispatchMap*)dispatch
{
    self->dispatchMap = dispatch;
}

@end

@interface MockWebServer()

@property(nonatomic, retain)    MockWebServerManager    *mockServerManager;
@end

@implementation MockWebServer
@synthesize mockServerManager;

- (id)init
{
    if ((self = [super init])) {
        self.mockServerManager = [[MockWebServerManager alloc] init];
    }
    
    return self;
}

- (void)start:(int)port
{
    [self.mockServerManager startServer:port];
}

- (void)stop
{
    [self.mockServerManager stopServer];
}

- (void)setDispatch:(DispatchMap *)dispatch
{
    [self.mockServerManager setDispatch:dispatch];
}

@end
