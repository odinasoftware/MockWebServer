//
//  TestConditionWait.m
//  MockWebServer
//
//  Created by Jae Han on 11/17/16.
//  Copyright © 2016 Jae Han. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TestConditionWait.h"

@implementation TestConditionWait

+ (TestConditionWait*)instance
{
    static TestConditionWait *_testConditionWait = nil;
    
    @synchronized (self) {
        if (_testConditionWait == nil) {
            _testConditionWait = [[TestConditionWait alloc] init];
        }
    }
    return _testConditionWait;
}

- (id)init
{
    if ((self = [super init])) {
        _waitCondition = [[NSCondition alloc] init];
    }
    
    return self;
}

- (void)wait
{
    [_waitCondition lock];
    [_waitCondition wait];
    [_waitCondition unlock];
}

- (void)wakeup
{
    [_waitCondition signal];
}

@end
