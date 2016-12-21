//
//  LocalServer.m
//  NYTReader
//
//  Created by Jae Han on 9/21/08.
//  Copyright © 2016 Jae Han. All rights reserved.
//
//#define _DEBUG 
#include <sys/socket.h>
#include <sys/select.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <fcntl.h>

#import "Common_defs.h"
#import "MockServer.h"
#import "MockServerManager.h"
#import "DispatchMap.h"

#define STOP_LOCAL_SERVER	"stop"
#define CARRIAGE_RETURN		0x0d
#define LINE_FEED			0x0a
#define CHUNKED_SIZE		1500

static const char *Response200 = "HTTP/1.1 200 OK";
static const char *Response404 = "HTTP/1.1 404 Not Found";
static const char *Response500 = "HTTP/1.1 500 Internal Server Error";

static const char *notFoundResponse = "HTTP/1.1 404 Not Found\r\nContent-length: 56\r\nConnection: close\r\n\r\n";
							     //          11        21        31        41        51 
								 //012345678901234567890123456789012345678901234567890123456789
//static const char *notFoundBody = "<script language='JavaScript'> /*Not Found*/ </script>\r\n";
static const char *NOT_FOUND_BODY = "Can't find any matching request. \r\n";
static const char *SERVER_ERROR_BODY = "Internal server error occurred.\r\n";
BOOL localServerStarted = NO;
int broken_pipe_count = 0;

//extern pthread_mutex_t network_mutex;

void sigpipe_handler(int sig)
{
	//NSLog(@"%s", __func__);
	broken_pipe_count++;
}

@interface MockWebServerManager()
- (void)exitConnThread:(id)thread;
@end

@implementation MockServer

@synthesize stopIt;
@synthesize isRequestValid;
@synthesize localRequest;
@synthesize serverManager;
@synthesize headers;

- (id)init
{
	if ((self = [super init])) {
		currentReadPtr = currentWritePtr = markIndex = 0;
		localRequest = nil;
		isRequestValid = NO;
		
//		theNotFoundBody = [[NSData alloc] initWithBytes:notFoundBody length:strlen(notFoundBody)];
		theNotFoundResHeader = [[NSData alloc] initWithBytes:notFoundResponse length:strlen(notFoundResponse)];
		[self initSignalHandler];
		needToDisplaySplash = YES;
	}
	
	return self;
}

- (id)initWithManager:(MockWebServerManager*)manager connFD:(int)fd
{
	if ((self = [super init])) {
		currentReadPtr = currentWritePtr = markIndex = 0;
		localRequest = nil;
		isRequestValid = NO;
        isRequestMatched = NO;
	
//		theNotFoundBody = [[NSData alloc] initWithBytes:notFoundBody length:strlen(notFoundBody)];
		theNotFoundResHeader = [[NSData alloc] initWithBytes:notFoundResponse length:strlen(notFoundResponse)];
		[self initSignalHandler];
		needToDisplaySplash = YES;
		connectedFD = fd;
		self.serverManager = manager;
	}
	
	return self;
}

- (void)initSignalHandler
{
	struct sigaction sa;
	
	sa.sa_flags = 0;
	
	sigemptyset(&sa.sa_mask);
	sigaddset(&sa.sa_mask, SIGPIPE);
	
	sa.sa_handler = sigpipe_handler;
	sigaction(SIGPIPE, &sa, nil);
}

- (void)stopLocalServer
{
	localServerStarted = NO;
	//if (write(signal_pipe[1], STOP_LOCAL_SERVER, strlen(STOP_LOCAL_SERVER)) < 0) {
	//	NSLog(@"%s: %s", __func__, strerror(errno));
	//}
}

- (int)processRequestHeader:(ssize_t)count
{
    int res = -1;
    NSString *field = nil;
    
	do {
		switch (parserMode) {
			case SEARCH_METHOD:
				markIndex = 0;
			
				if (local_buffer[currentReadPtr] == ' ') {
					NSString *method = [[NSString alloc] initWithBytes:&local_buffer[markIndex] length:currentReadPtr-markIndex encoding:NSUTF8StringEncoding];
					if ([method compare:@"GET"] == NSOrderedSame) {
						currentReadPtr++;
						markIndex = currentReadPtr;
						parserMode = SEARCH_REQUEST;
						continue;
					}
					else {
						NSLog(@"Unsupported method found: %@", method);
						return -1;
					}

				}
				currentReadPtr++;
				break;
			case SEARCH_REQUEST:
				if (local_buffer[currentReadPtr] == ' ') {
					localRequest = [[NSString alloc] initWithBytes:&local_buffer[markIndex] length:currentReadPtr-markIndex encoding:NSUTF8StringEncoding];
					currentReadPtr++;
					markIndex = currentReadPtr;
					parserMode = SEARCH_REQUEST_FIELD;
                    if ((self.dispatch = [self doesRequestMatch:localRequest]) != nil) {
                        TRACE("Request matched: %s from request=%s\n", [self.dispatch.request UTF8String], [localRequest UTF8String]);
                        isRequestMatched = YES;
                        self.headers = [[NSMutableDictionary alloc] initWithDictionary:self.dispatch.requestHeaders];
                    }
					TRACE(">>>>>> found request: %s\n", [localRequest UTF8String]);
					isRequestValid = YES;
					continue;
				}
				currentReadPtr++;
				break;
			case BEGIN_NEW_LINE:
				markIndex = currentReadPtr;
				if (((currentReadPtr + 2) <= currentWritePtr) &&
					((local_buffer[currentReadPtr] == CARRIAGE_RETURN) && (local_buffer[currentReadPtr+1] == LINE_FEED))) {
					currentReadPtr += 2;
                    parserMode = BODY_START;
					return 0;
				}
				else {
					parserMode = SEARCH_REQUEST_FIELD;
				}
				break;
			case SEARCH_REQUEST_FIELD:
				if (local_buffer[currentReadPtr] == ' ') {
					field = [[NSString alloc] initWithBytes:&local_buffer[markIndex] length:currentReadPtr-markIndex encoding:NSUTF8StringEncoding];
					if ([field compare:@"Host:"] == NSOrderedSame) {
						currentReadPtr++;
						markIndex = currentReadPtr;
						parserMode = SEARCH_REQUEST_VALUE;
                    
						continue;
					}
					else {
						parserMode = SKIP_TO_NEXT_LINE;
					}
					
				}
				currentReadPtr++;
				break;
			case SEARCH_REQUEST_VALUE:
				if (local_buffer[currentReadPtr] == ' ') {
					NSString *value = [[NSString alloc] initWithBytes:&local_buffer[markIndex] length:currentReadPtr-markIndex encoding:NSUTF8StringEncoding];
					TRACE("field=%s, value=%s\n", [field UTF8String], [value UTF8String]);
					if ([value compare:@"localhost"] == NSOrderedSame) {
						currentReadPtr++;
						markIndex = currentReadPtr;
					
						continue;
					}
                    NSString *valueInHeaderPatterns = [self.headers objectForKey:field];
                    if (valueInHeaderPatterns != nil &&
                        [value compare:valueInHeaderPatterns options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                        TRACE("found matching header=%s, value=%s\n", [field UTF8String], [valueInHeaderPatterns UTF8String]);
                        [self.headers removeObjectForKey:field];
                    }
				}
				currentReadPtr++;
				break;
			case SKIP_TO_NEXT_LINE:
				if (((currentReadPtr + 2) < currentWritePtr) && 
					((local_buffer[currentReadPtr] == CARRIAGE_RETURN) && (local_buffer[currentReadPtr+1] == LINE_FEED))) {
					currentReadPtr += 2;
					markIndex = currentReadPtr;
					parserMode = BEGIN_NEW_LINE;
					continue;
				}
				currentReadPtr++;
				break;
			default:
				NSLog(@"Unknown parser mode: %d", parserMode);
		}
	} while (currentReadPtr < currentWritePtr);
	
    res = 0;
    
	return res;
}

- (Dispatch*)doesRequestMatch:(NSString*)request
{
    return [self.serverManager.dispatchMap dispatchForRequest:request];
}

- (void)resetConnection
{
	currentReadPtr = currentWritePtr = markIndex = 0;
	parserMode = SEARCH_METHOD;
	isRequestValid = NO;
	if (localRequest != nil) {
		
		localRequest = nil;
	}
}

- (NSData*)constructHeader:(NSDictionary*)resHeaders
{
    NSMutableString *data = [[NSMutableString alloc] initWithUTF8String:Response200];
    for (NSString *k in resHeaders.allKeys) {
        NSString *v = [resHeaders objectForKey:k];
        
        if (v != nil) {
            NSString *field = [NSString stringWithFormat:@"\r\n%@: %@", k, v];
            [data appendString:field];
        }
    }
    
    [data appendString:@"\r\n\r\n"];
    return [data dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData*)construct404Header
{
    NSMutableString *data = [[NSMutableString alloc] initWithUTF8String:Response404];
    [data appendString:[NSString stringWithFormat:@"\r\n%@: %@", @"Connection", @"Close"]];
    [data appendString:@"\r\n\r\n"];
    return [data dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData*)construct500Header
{
    NSMutableString *data = [[NSMutableString alloc] initWithUTF8String:Response500];
    [data appendString:[NSString stringWithFormat:@"\r\n%@: %@", @"Connection", @"Close"]];
    [data appendString:@"\r\n\r\n"];
    return [data dataUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)readFromConnection:(int)connfd
{
	BOOL ret = NO;
	ssize_t read_cnt = -1;
	NSData *header=nil, *body=nil;
	ssize_t writ = 0;
	ssize_t body_size = 0;
	ssize_t write_size = 0;
	const char *body_ptr = nil;
    BOOL isServerError = NO;
	
	do {
		read_cnt = -1;
		writ = 0;
		[self resetConnection];
		
		do {
			read_cnt = read(connfd, local_buffer+currentWritePtr, (LOCAL_BUFFER_SIZE-currentWritePtr));
			if (read_cnt < 0) {
				NSLog(@"%s:read %d, %s, %d", __func__, connfd, strerror(errno), broken_pipe_count);
				goto clean;
			}
			if (read_cnt > 0) {
				currentWritePtr += read_cnt;
				if ([self processRequestHeader:read_cnt] < 0) {
					isServerError = YES;
                    break;
                }
                else if (parserMode == BODY_START){
                    TRACE("Body detected.");
                    break;
                }
				
			}
			else if (read_cnt == 0) {
				TRACE(">>>>> connection close: %d\n", connfd);
                goto clean;
			}
		} while (read_cnt > 0);
		
			
        /**
         construct header based on user's template.
         */
        if (self.dispatch != nil) {
            TRACE("Found matching request.");
            header = [self constructHeader:self.dispatch.responseField];
            body = [self.dispatch.responseString dataUsingEncoding:NSUTF8StringEncoding];
        }
        else if (isRequestValid == YES) {
            TRACE("No matching request found.");
            header = [self construct404Header];
            body = [NSData dataWithBytes:NOT_FOUND_BODY length:strlen(NOT_FOUND_BODY)];
        }
        else {
            TRACE("Something wrong with request or we have an error in the server.");
            header = [self construct500Header];
            body = [NSData dataWithBytes:SERVER_ERROR_BODY length:strlen(SERVER_ERROR_BODY)];
        }
        
        if (header != nil && body != nil) {
            // write the header and body
            const char *h_ptr = [header bytes];
            
            if ((writ = write(connfd, h_ptr, [header length])) != [header length]) {
                NSLog(@"%s:write header %d, %s, writ=%ld, len=%ld", __func__, connfd, strerror(errno),(unsigned long)writ, (unsigned long)[header length]);
                goto clean;
            }
            
            if (body != nil) {
                body_size = [body length];
                body_ptr = [body bytes];
                while (body_size > 0) {
                    if (body_size > CHUNKED_SIZE)
                        write_size = CHUNKED_SIZE;
                    else
                        write_size = body_size;
                    if ((writ = write(connfd, body_ptr, write_size)) != write_size) {
                        NSLog(@"%s:write body %d, %s, %d", __func__, connfd, strerror(errno), broken_pipe_count);
                        goto clean;
                    }
                    body_size -= write_size;
                    body_ptr += write_size;
                }
            }
            TRACE(">>>>> Writing response: fd: %d, header: %lu, body: %lu\n",
                  connfd, (unsigned long)[header length], (unsigned long)[body length]);
            
        }
        
		shutdown(connfd, SHUT_RDWR);
	} while (YES);
	
	ret = YES;
	
clean:
	close(connfd);

	return ret;
}


- (void)main
{
	
	
	if (localRequest != nil) {
	
		localRequest = nil;
	}
	isRequestValid = NO;
	
	if ([self readFromConnection:connectedFD] == YES) {
		currentReadPtr = currentWritePtr = markIndex = 0;
	}
	
	if (localRequest != nil) {
	
		localRequest = nil;
	}
	
	
	[serverManager exitConnThread:self];
}

- (void)dealloc
{
	
}
@end
