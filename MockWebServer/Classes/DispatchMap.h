//
//  DispatchMap.h
//  Pods
//
//  Created by Jae Han on 12/1/16.
//
//

#import <Foundation/Foundation.h>

@interface Dispatch : NSObject

@property(nonatomic, retain)    NSString        *request;
@property(nonatomic, retain)    NSString        *responseString;
@property(nonatomic, retain)    NSString        *fileName;
@property(assign)               int             code;
@property(nonatomic, retain)    NSDictionary    *responseField;
@property(nonatomic, retain)    NSDictionary    *requestHeaders;

- (void)requestContainString:(NSString*)string;
- (void)responseString:(NSString*)string;
- (void)setResponseCode:(int)code;
- (void)addResponseField:(NSString*)field value:(NSString*)value;
- (void)responseFromFile:(NSString*)name;
- (void)responseHeaders:(NSDictionary*)dict;
- (void)requestHeaders:(NSDictionary*)dict;

@end

@interface DispatchMap : NSObject

@property(nonatomic, retain)    NSDictionary    *requestResposneMap;

- (void)addDispatch:(Dispatch*)dispatch;
- (Dispatch*)dispatchForRequest:(NSString*)request;
@end
