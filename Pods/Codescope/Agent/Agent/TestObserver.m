//
//  TestObserver.m
//  Agent
//
//  Created by Fernando Mayo Fernandez on 10/15/18.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import "TestObserver.h"

@implementation TestObserver

- (void)install:(id)agent
{
    [[XCTestObservationCenter sharedTestObservationCenter] addTestObserver:self];
    self.agent = agent;
}

- (void)testCaseWillStart:(XCTestCase *)testCase
{
    fprintf(stderr, "Codescope: %s will start!\n", [testCase.name UTF8String]);
    [testCase.invocation aspect_hookSelector:@selector(invoke) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info) {
        @try {
            [info.originalInvocation invokeWithTarget:info.instance];
        }
        @catch(NSException *exception) {
            [self testCase:testCase didThrowException:exception];
            @throw;
        }
    } error:NULL];
}

- (void)testCaseDidFinish:(XCTestCase *)testCase
{
    fprintf(stderr, "Codescope: %s finished with status: %s!\n", [testCase.name UTF8String], testCase.testRun.hasSucceeded ? "PASS" : testCase.testRun.unexpectedExceptionCount > 0 ? "ERROR" : "FAIL");
}

- (void)testCase:(XCTestCase *)testCase didFailWithDescription:(NSString *)description inFile:(NSString *)filePath atLine:(NSUInteger)lineNumber
{
    fprintf(stderr, "Codescope: %s failed with description: %s in file: %s at line: %lu\n", [testCase.name UTF8String], [description UTF8String], [filePath UTF8String], lineNumber);
}

- (void)testCase:(XCTestCase *)testCase didThrowException:(NSException *)exception
{
    [self.agent exceptionHandler:exception];
}

@end
