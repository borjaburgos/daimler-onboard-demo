//
//  TestObserver.m
//  Agent
//
//  Created by Fernando Mayo Fernandez on 10/15/18.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import "TestObserver.h"

@implementation TestObserver

- (void)install
{
    [[XCTestObservationCenter sharedTestObservationCenter] addTestObserver:self];
}

- (void)testCaseWillStart:(XCTestCase *)testCase
{
    os_log(OS_LOG_DEFAULT, "Codescope: %@ will start!", testCase.name);
    [testCase setExceptionHandler:self];
}

- (void)testCaseDidFinish:(XCTestCase *)testCase
{
    os_log(OS_LOG_DEFAULT, "Codescope: %@ finished with status: %@!", testCase.name, testCase.testRun.hasSucceeded ? @"PASS" : testCase.testRun.unexpectedExceptionCount > 0 ? @"ERROR" : @"FAIL");
}

- (void)testCase:(XCTestCase *)testCase didFailWithDescription:(NSString *)description inFile:(NSString *)filePath atLine:(NSUInteger)lineNumber
{
    os_log(OS_LOG_DEFAULT, "Codescope: %@ failed with description: %@ in file: %@ at line: %lu", testCase.name, description, filePath, lineNumber);
}

- (void)testCase:(XCTestCase *)testCase didThrowException:(NSException *)exception
{
    os_log(OS_LOG_DEFAULT, "Codescope: %@ did throw an exception: %@!", testCase.name, exception);
}

@end
