//
//  CSAgent.h
//  Agent
//
//  Created by Fernando Mayo on 14/10/2018.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "KSCrash/KSCrash.h"
#import "KSCrashInstallationCodeScope.h"
#import "CSTestObserver.h"
#import "CSLogPipe.h"
#import "CSTracer.h"

#define CSAGENT_VERSION @"0.1.0"

@class CSTestObserver;

@interface CSAgent : NSObject
@property (readonly) NSURL *baseURL;
@property (readonly) NSString *agentId;
@property (readonly) NSString *apiKey;
@property (readonly) NSString *repository;
@property (readonly) NSString *commit;
@property (readonly) NSString *service;
@property KSCrashInstallationCodeScope *sharedKSCrash;
@property CSTestObserver *testObserver;
@property CSTracer *tracer;
@property (class) CSAgent *sharedAgent;

- (void)install;
- (void)loggingHandler:(NSString *)message inFile:(NSString *)file inLine:(int)line inFunction:(NSString *)function;

@end
