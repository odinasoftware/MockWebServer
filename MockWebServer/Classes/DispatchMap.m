//
//  DispatchMap.m
//  Pods
//
//  Created by Jae Han on 12/1/16.
//  Copyright © 2016 Jae Han. All rights reserved.
//

#import "DispatchMap.h"
#import "Common_defs.h"

@implementation Dispatch

@synthesize request;
@synthesize responseString;
@synthesize fileName;
@synthesize code;
@synthesize responseField;
@synthesize requestHeaders;

- (Dispatch*)requestContainString:(NSString*)string
{
    self.request = string;
    return self;
}

- (Dispatch*)responseString:(NSString*)string
{
    self.responseString = string;
    return self;
}

- (Dispatch*)setResponseCode:(int)responseCode
{
    self.code = responseCode;
    return self;
}

- (Dispatch*)addResponseField:(NSString*)field value:(NSString*)value
{
    if (self.responseField == nil) {
        self.responseField = [[NSMutableDictionary alloc] init];
    }
    [self.responseField setValue:value forKey:field];
    return self;
}

- (Dispatch*)responseFromFile:(NSString*)name
{
    self.fileName = name;
    return self;
}

- (Dispatch*)responseHeaders:(NSDictionary *)dict
{
    self.responseField = dict;
    return self;
}

- (Dispatch*)requestHeaders:(NSDictionary*)dict
{
    self.requestHeaders = dict;
    return self;
}

- (Dispatch*)responseBodyForBundle:(NSBundle*)bundle fromFile:(NSString*)file
{
    NSString *name=nil, *ext=nil;
    
    NSRange range = [file rangeOfString:@"."];
    if (range.location != NSNotFound) {
        name = [file substringToIndex:range.location];
        ext = [file substringFromIndex:range.location+1];
    }
    
    TRACE("responseBodyForBundle: name=%s, ext=%s", [name UTF8String], [ext UTF8String]);
    
    NSString *filePath = [bundle pathForResource:name ofType:ext];
    self.responseString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return self;
}

@end

@implementation DispatchMap

@synthesize requestResposneMap;

- (id)init
{
    if ((self=[super init])) {
        requestResposneMap = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)addDispatch:(Dispatch*)dispatch
{
    if (dispatch.request != nil) {
        [self.requestResposneMap setValue:dispatch forKey:dispatch.request];
    }
    else {
        NSLog(@"%s: dispatch request can't be null.", __func__);
    }
}

- (Dispatch*)dispatchForRequest:(NSString*)request
{
    Dispatch *dispatch = nil;
    
    for (NSString *key in self.requestResposneMap.allKeys) {
        Dispatch *d = [self.requestResposneMap objectForKey:key];
        if (d != nil && [request containsString:d.request] == YES) {
            dispatch = d;
            break;
        }
    }
    
    return dispatch;
}
@end
