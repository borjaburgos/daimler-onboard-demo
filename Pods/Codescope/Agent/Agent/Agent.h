//
//  Agent.h
//  Agent
//
//  Created by Fernando Mayo on 14/10/2018.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "TestObserver.h"
#import "Log.h"
#import <KSCrash/KSCrash.h>
#import <KSCrash/KSCrashInstallationConsole.h>

@interface Agent : NSObject
@property KSCrashInstallationConsole *sharedKSCrash;

+ (Agent *)sharedAgent;
- (void)install;
- (void)exceptionHandler:(NSException *)exception;
- (void)loggingHandler:(NSString *)message inFile:(NSString *)file inLine:(int)line inFunction:(NSString *)function;

@end
