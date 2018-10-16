//
//  Agent.m
//  Agent
//
//  Created by Fernando Mayo on 14/10/2018.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import "Agent.h"


void uncaughtExceptionHandler(NSException *exception) {
    [[Agent sharedAgent] exceptionHandler: exception];
}


@implementation Agent

+ (id)sharedAgent {
    static Agent *sharedAgent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAgent = [[self alloc] init];
    });
    return sharedAgent;
}

+ (void)load
{
    [[Agent sharedAgent] install];
}

- (void)install
{
    if(!self.installed) {
        // Instrument testing framework
        TestObserver *obs = [[TestObserver alloc] init];
        [obs install];
        
        // Catch unhandled exceptions
        NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
        
        // Mark agent as installed
        self.installed = YES;
    }
}

- (void)exceptionHandler:(NSException *)exception
{
    os_log(OS_LOG_DEFAULT, "Codescope: exception unhandled: %@", exception);
}

@end
