//
//  CSCocoaLumberjackLogger.h
//  Agent
//
//  Created by Fernando Mayo Fernandez on 11/5/18.
//  Copyright © 2018 Codescope. All rights reserved.
//

#ifdef CS_COCOALUMBERJACK_ENABLED

#import <CocoaLumberjack/CocoaLumberjack.h>

@interface CSCocoaLumberjackLogger : NSObject <DDLogger>
@property (nonatomic, strong) id <DDLogFormatter> logFormatter;
@property (class) CSCocoaLumberjackLogger *sharedInstance;

- (void)logMessage:(DDLogMessage *)logMessage;

@end

#endif
