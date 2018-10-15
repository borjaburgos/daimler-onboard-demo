//
//  Agent.m
//  Agent
//
//  Created by Fernando Mayo on 14/10/2018.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import "Agent.h"

@implementation Agent

+ (void)load
{
    Agent *agent = [[Agent alloc] init];
    [[XCTestObservationCenter sharedTestObservationCenter] addTestObserver:agent];
}

- (void)testCaseDidFinish:(XCTestCase *)testCase
{
    os_log(OS_LOG_DEFAULT, "Codescope: %@ finished!", testCase.name);
}

@end
