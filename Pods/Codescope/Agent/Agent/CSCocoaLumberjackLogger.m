//
//  CSCocoaLumberjackLogger.m
//  Agent
//
//  Created by Fernando Mayo Fernandez on 11/5/18.
//  Copyright © 2018 Codescope. All rights reserved.
//

#ifdef CS_COCOALUMBERJACK_ENABLED

#import "CSCocoaLumberjackLogger.h"
#import "CSAgent.h"
#import "CSTags.h"

@implementation CSCocoaLumberjackLogger

static CSCocoaLumberjackLogger *_sharedInstance = nil;
@dynamic sharedInstance;

+ (CSCocoaLumberjackLogger *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_sharedInstance == nil) {
            _sharedInstance = [[CSCocoaLumberjackLogger alloc] init];
        }
    });
    return _sharedInstance;
}

+ (void)setSharedInstance:(CSCocoaLumberjackLogger *)sharedInstance {
    _sharedInstance = sharedInstance;
}

+ (void)load {
    if([DDLog class]) {
        [DDLog addLogger:[self sharedInstance]];
    }
}

- (void)logMessage:(DDLogMessage *)logMessage {
    NSString *logLevel = nil;
    switch(logMessage.level) {
        case DDLogLevelVerbose:
        case DDLogLevelDebug:
            logLevel = @"DEBUG";
            break;
            
        case DDLogLevelInfo:
            logLevel = @"INFO";
            break;
            
        case DDLogLevelWarning:
            logLevel = @"WARNING";
            break;
           
        case DDLogLevelError:
            logLevel = @"ERROR";
            break;
            
        default:
            logLevel = @"NOTSET";
            
    }
    NSDictionary<NSString *,NSString *> *fields = @{
                                                    @CSTAG_EVENT: logMessage.level == DDLogFlagError ? @"error" : @"log",
                                                    @CSTAG_MESSAGE: logMessage.message,
                                                    @CSTAG_LOG_LEVEL: logLevel,
                                                    @CSTAG_LOG_SOURCE: [NSString stringWithFormat:@"%@:%lu", logMessage.file, (unsigned long)logMessage.line],
                                                    };
    [CSAgent.sharedAgent.tracer.activeSpanStack.lastObject log:fields timestamp:logMessage.timestamp];
}

@end

#endif
