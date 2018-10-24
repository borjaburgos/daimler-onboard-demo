//
//  TestObserver.h
//  Agent
//
//  Created by Fernando Mayo Fernandez on 10/15/18.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "Agent.h"
#import "Aspects/Aspects.h"


@interface TestObserver : NSObject <XCTestObservation>
@property id agent;

- (void)install:(id)agent;
- (void)testCase:(XCTestCase *)testCase didThrowException:(NSException *)exception;

@end
