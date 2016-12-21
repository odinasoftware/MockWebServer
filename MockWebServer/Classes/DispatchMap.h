//
//  DispatchMap.h
//  Pods
//
//  Created by Jae Han on 12/1/16.
//  Copyright © 2016 Jae Han. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dispatch : NSObject

@property(nonatomic, retain)    NSString        *request;
@property(nonatomic, retain)    NSString        *responseString;
@property(nonatomic, retain)    NSString        *fileName;
@property(assign)               int             code;
@property(nonatomic, retain)    NSDictionary    *responseField;
@property(nonatomic, retain)    NSDictionary    *requestHeaders;

- (Dispatch*)requestContainString:(NSString*)string;
- (Dispatch*)responseString:(NSString*)string;
- (Dispatch*)setResponseCode:(int)responseCode;
- (Dispatch*)addResponseField:(NSString*)field value:(NSString*)value;
- (Dispatch*)responseFromFile:(NSString*)name;
- (Dispatch*)responseHeaders:(NSDictionary*)dict;
- (Dispatch*)requestHeaders:(NSDictionary*)dict;
- (Dispatch*)responseBodyForBundle:(NSBundle*)bundle fromFile:(NSString*)file;


@end

@interface DispatchMap : NSObject

@property(nonatomic, retain)    NSDictionary    *requestResposneMap;

- (void)addDispatch:(Dispatch*)dispatch;
- (Dispatch*)dispatchForRequest:(NSString*)request;
@end
