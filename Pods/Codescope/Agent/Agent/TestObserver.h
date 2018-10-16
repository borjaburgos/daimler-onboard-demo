//
//  TestObserver.h
//  Agent
//
//  Created by Fernando Mayo Fernandez on 10/15/18.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <os/log.h>
#import "XCTestCase+PatchedTestCase.h"

@interface TestObserver : NSObject <XCTestObservation, TestExceptionHandler>

- (void)install;
- (void)testCase:(XCTestCase *)testCase didThrowException:(NSException *)exception;

@end
