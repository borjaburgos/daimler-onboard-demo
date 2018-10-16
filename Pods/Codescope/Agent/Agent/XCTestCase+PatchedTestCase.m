//
//  XCTestCase+PatchedTestCase.m
//  Agent
//
//  Created by Fernando Mayo Fernandez on 10/15/18.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import "XCTestCase+PatchedTestCase.h"

static void *PatchedTestCaseHandlerKey;

@implementation XCTestCase (PatchedTestCase)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL defaultSelector = @selector(invokeTest);
        SEL swizzledSelector = @selector(patched_invokeTest);

        Method defaultMethod = class_getInstanceMethod(class, defaultSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        BOOL isMethodExists = !class_addMethod(class, defaultSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));

        if (isMethodExists) {
            method_exchangeImplementations(defaultMethod, swizzledMethod);
        }
        else {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(defaultMethod), method_getTypeEncoding(defaultMethod));
        }
    });
}

- (void)patched_invokeTest
{
    @try {
        [self setUp];
        [self.invocation invoke];
        [self tearDown];
    }
    @catch(NSException *exception) {
        [self.exceptionHandler testCase:self didThrowException:exception];
        @throw;
    }
}

- (NSObject<TestExceptionHandler> *)exceptionHandler {
    return objc_getAssociatedObject(self, &PatchedTestCaseHandlerKey);
}

- (void)setExceptionHandler:(NSObject<TestExceptionHandler> *)exceptionHandler {
    objc_setAssociatedObject(self, &PatchedTestCaseHandlerKey, exceptionHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
