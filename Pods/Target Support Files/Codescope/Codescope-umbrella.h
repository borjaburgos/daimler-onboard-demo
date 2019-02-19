#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CSAgent.h"
#import "CSCocoaLumberjackLogger.h"
#import "CSLogPipe.h"
#import "CSSpan.h"
#import "CSSpanContext.h"
#import "CSTags.h"
#import "CSTestObserver.h"
#import "CSTracer.h"
#import "CSUtil.h"
#import "KSCrashInstallationCodeScope.h"
#import "KSCrashReportSinkCodeScope.h"
#import "NSData+CSGzip.h"
#import "NSDate+ISO8601.h"

FOUNDATION_EXPORT double CodeScopeVersionNumber;
FOUNDATION_EXPORT const unsigned char CodeScopeVersionString[];

