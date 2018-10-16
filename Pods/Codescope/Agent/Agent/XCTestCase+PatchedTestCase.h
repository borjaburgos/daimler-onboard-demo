//
//  XCTestCase+PatchedTestCase.h
//  Agent
//
//  Created by Fernando Mayo Fernandez on 10/15/18.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <os/log.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TestExceptionHandler <NSObject>

- (void)testCase:(XCTestCase *)testCase didThrowException:(NSException *)exception;

@end

@interface XCTestCase (PatchedTestCase)
@property NSObject<TestExceptionHandler> *exceptionHandler;

+ (void)load;
- (void)patched_invokeTest;
- (void)setExceptionHandler:(NSObject<TestExceptionHandler> *)exceptionHandler;

@end

NS_ASSUME_NONNULL_END
