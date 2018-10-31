//
//  CSTestObserver.h
//  Agent
//
//  Created by Fernando Mayo Fernandez on 10/15/18.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "CSSpan.h"


@interface CSTestObserver : NSObject <XCTestObservation>
@property(atomic) CSSpan *activeSpan;

- (void)testCase:(XCTestCase *)testCase didThrowException:(NSException *)exception;

@end
