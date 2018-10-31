//
//  CSTestObserver.m
//  Agent
//
//  Created by Fernando Mayo Fernandez on 10/15/18.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import "KSCrash/KSCrash.h"
#import "Aspects/Aspects.h"
#import "CSTestObserver.h"
#import "CSTags.h"
#import "CSAgent.h"

@implementation CSTestObserver

static NSRegularExpression *regex;

- (instancetype)init
{
    if (self = [super init]) {
        [[XCTestObservationCenter sharedTestObservationCenter] addTestObserver:self];
        regex = [NSRegularExpression regularExpressionWithPattern:@"([\\w]+) ([\\w]+)"
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:nil];
    }
    return self;
}

- (void)testCaseWillStart:(XCTestCase *)testCase
{
    [testCase.invocation aspect_hookSelector:@selector(invoke) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info) {
        @try {
            [info.originalInvocation invokeWithTarget:info.instance];
        }
        @catch(NSException *exception) {
            [self testCase:testCase didThrowException:exception];
            @throw;
        }
    } error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:testCase.name options:0 range:NSMakeRange(0, [testCase.name length])];
    NSString *testSuite = [testCase.name substringWithRange:[match rangeAtIndex:1]];
    NSString *testName = [testCase.name substringWithRange:[match rangeAtIndex:2]];
    NSDictionary *tags = @{
                           @CSTAG_SPAN_KIND: @CSTAG_TEST,
                           @CSTAG_TEST_FRAMEWORK: @"XCTest",
                           @CSTAG_TEST_SUITE: testSuite,
                           @CSTAG_TEST_NAME: testName,
                           };
    self.activeSpan = (CSSpan *)[CSAgent.sharedAgent.tracer startSpan:testCase.name tags:tags];
    [KSCrash.sharedInstance setUserInfo:@{@"activeSpan": [self.activeSpan _toJSONWithFinishTime:[NSDate date]]}];
}

- (void)testCaseDidFinish:(XCTestCase *)testCase
{
    NSString *status = testCase.testRun.hasSucceeded ? @"PASS" : testCase.testRun.unexpectedExceptionCount > 0 ? @"ERROR" : @"FAIL";
    [self.activeSpan setTag:@CSTAG_TEST_STATUS value:status];
    [self.activeSpan finish];
    self.activeSpan = nil;
}

- (void)testCase:(XCTestCase *)testCase didFailWithDescription:(NSString *)description inFile:(NSString *)filePath atLine:(NSUInteger)lineNumber
{
    [self.activeSpan log:@{
                           @"event": @"test_failure",
                           @"message": description,
                           @"source": [NSString stringWithFormat:@"%@:%lu", filePath, (unsigned long)lineNumber],
                           @CSTAG_LOG_LEVEL: @"ERROR",
                           }];
}

- (void)testCase:(XCTestCase *)testCase didThrowException:(NSException *)exception
{
    // [KSCrash.sharedInstance reportUserException:exception.name reason:exception.reason language:nil lineOfCode:nil stackTrace:exception.callStackSymbols logAllThreads:FALSE terminateProgram:FALSE];
}

- (void)testBundleDidFinish:(NSBundle *)testBundle
{
    [CSAgent.sharedAgent.sharedKSCrash sendAllReportsWithCompletion:nil];
    [CSAgent.sharedAgent.tracer flush];
}

@end
