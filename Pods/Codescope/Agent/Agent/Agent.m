//
//  Agent.m
//  Agent
//
//  Created by Fernando Mayo on 14/10/2018.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import "Agent.h"


@implementation Agent

+ (void)load {
    [[Agent sharedAgent] install];
}

+ (Agent *)sharedAgent {
    static Agent *sharedAgent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAgent = [[self alloc] init];
        sharedAgent.sharedKSCrash = [KSCrashInstallationConsole sharedInstance];
    });
    return sharedAgent;
}

- (void)install {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TestObserver *obs = [[TestObserver alloc] init];
        [obs install:self];
        
        [self.sharedKSCrash install];
    });
}

- (void)loggingHandler:(NSString *)message inFile:(NSString *)file inLine:(int)line inFunction:(NSString *)function {
    fprintf(stderr, "Codescope: intercepted logs: %s:%3d %s: %s\n", [file UTF8String], line, [function UTF8String], [message UTF8String]);
}

- (void)exceptionHandler:(NSException *)exception {
    [KSCrash.sharedInstance reportUserException:exception.name reason:exception.reason language:nil lineOfCode:nil stackTrace:exception.callStackSymbols logAllThreads:FALSE terminateProgram:FALSE];
}

@end
