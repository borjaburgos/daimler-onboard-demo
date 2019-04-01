#import <Foundation/Foundation.h>

#define CSAGENT_VERSION "0.1.17"

#define CSLog(fmt, ...) NSLog(@"[Scope] " fmt, ##__VA_ARGS__)


@class CSTestObserver;
@class CSTracer;
@class CSAlamofireObserver;
@class CSURLSessionObserver;
@class CSNetworkActivityLogger;
@class CSLoggerNotificationObserver;

@class KSCrashInstallationScopeAgent;

@interface CSAgent : NSObject
@property (readonly) NSURL *baseURL;
@property (readonly) NSString *agentId;
@property (readonly) NSString *apiKey;
@property (readonly) NSString *repository;
@property (readonly) NSString *commit;
@property (readonly) NSString *service;
@property (readonly) NSString *sourceRoot;
@property KSCrashInstallationScopeAgent *sharedKSCrash;
@property CSTestObserver *testObserver;
@property CSAlamofireObserver *alamofireObserver;
@property CSURLSessionObserver *urlSessionObserver;
@property CSLoggerNotificationObserver *loggerNotificationObserver;
@property CSTracer *tracer;

@property (class) CSAgent *sharedAgent;

- (void)install;
- (void)log:(NSDictionary<NSString *, NSObject *> *)fields timestamp:(NSDate *)timestamp;

@end
