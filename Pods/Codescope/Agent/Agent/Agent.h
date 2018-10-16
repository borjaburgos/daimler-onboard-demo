//
//  Agent.h
//  Agent
//
//  Created by Fernando Mayo on 14/10/2018.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <os/log.h>
#import <objc/runtime.h>
#import "TestObserver.h"

@interface Agent : NSObject
@property BOOL installed;

+ (id)sharedAgent;
+ (void)load;
- (void)install;
- (void)exceptionHandler:(NSException *)exception;

@end
