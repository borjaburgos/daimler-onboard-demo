//
//  CSAgent.h
//  Agent
//
//  Created by Fernando Mayo on 14/10/2018.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSCrash/KSCrash.h"
#import "KSCrashInstallationCodeScope.h"
#import "CSTestObserver.h"
#import "CSLogPipe.h"
#import "CSTracer.h"
#import "CSCocoaLumberjackLogger.h"

#define CSAGENT_VERSION "0.1.0"
#if DEBUG
#define CSLog(fmt, ...) NSLog(@"[CodeScope] " fmt, ##__VA_ARGS__)
#else
#define CSLog(...)
#endif

@class CSTestObserver;

@interface CSAgent : NSObject
@property (readonly) NSURL *baseURL;
@property (readonly) NSString *agentId;
@property (readonly) NSString *apiKey;
@property (readonly) NSString *repository;
@property (readonly) NSString *commit;
@property (readonly) NSString *service;
@property (readonly) NSString *sourceRoot;
@property KSCrashInstallationCodeScope *sharedKSCrash;
@property CSTestObserver *testObserver;
@property CSTracer *tracer;
@property (class) CSAgent *sharedAgent;

- (void)install;

@end
