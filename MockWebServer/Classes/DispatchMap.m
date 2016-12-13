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

- (void)requestContainString:(NSString*)string
{
    self.request = string;
}

- (void)responseString:(NSString*)string
{
    self.responseString = string;
}

- (void)setResponseCode:(int)code
{
    self.code = code;
}

- (void)addResponseField:(NSString*)field value:(NSString*)value
{
    if (self.responseField == nil) {
        self.responseField = [[NSMutableDictionary alloc] init];
    }
    [self.responseField setValue:value forKey:field];
}

- (void)responseFromFile:(NSString*)name
{
    self.fileName = name;
}

- (void)responseHeaders:(NSDictionary *)dict
{
    self.responseField = dict;
}

- (void)requestHeaders:(NSDictionary*)dict
{
    self.requestHeaders = dict;
}

- (NSString*)responseBodyForBundle:(NSBundle*)bundle fromFile:(NSString*)file
{
    NSString *name=nil, *ext=nil;
    
    NSRange range = [file rangeOfString:@"."];
    if (range.location != NSNotFound) {
        name = [file substringToIndex:range.location];
        ext = [file substringFromIndex:range.location+1];
    }
    
    TRACE("responseBodyForBundle: name=%s, ext=%s", [name UTF8String], [ext UTF8String]);
    
    NSString *filePath = [bundle pathForResource:name ofType:ext];
    return self.responseString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
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
