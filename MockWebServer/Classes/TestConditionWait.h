//
//  TestConditionWait.h
//  MockWebServer
//
//  Created by Jae Han on 11/17/16.
//  Copyright © 2016 Jae Han. All rights reserved.
//

@interface TestConditionWait : NSObject {

    @private
    NSCondition     *_waitCondition;
}

+ (TestConditionWait*)instance;

- (void)waitFor:(int)count;
- (void)wakeup;

@end

