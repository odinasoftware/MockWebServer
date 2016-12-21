//
//  TestConditionWait.m
//  MockWebServer
//
//  Created by Jae Han on 11/17/16.
//  Copyright © 2016 Jae Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common_defs.h"
#import "TestConditionWait.h"

@implementation TestConditionWait

static int _waitCount = 0;
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

- (void)waitFor:(int)count
{
    _waitCount = count;
    [_waitCondition lock];
    do {
        TRACE("wait count=%d", _waitCount);
        [_waitCondition wait];
    } while (--_waitCount > 0);
    [_waitCondition unlock];
    TRACE("%s: waken up.", __func__);
}

- (void)wakeup
{
    [_waitCondition lock];
    [_waitCondition signal];
    [_waitCondition unlock];
}

@end
