#import <Foundation/Foundation.h>

#import "opentracing/OTTracer.h"
#import "CSSpan.h"

NS_ASSUME_NONNULL_BEGIN

/// The error domain for all CodeScope-related NSErrors.
extern NSString *const CSErrorDomain;

/// CodeScope error that represents background task failures.
extern NSInteger const CSBackgroundTaskError;

/// An implementation of the OTTracer protocol.

/// Either pass the resulting id<OTTracer> around your application explicitly or use the OTGlobal singleton
/// mechanism.
///
/// CSTracer is thread-safe.
@interface CSTracer : NSObject<OTTracer>

#pragma mark - CSTracer initialization

/// @returns An `CSTracer` instance that's ready to create spans and logs.
- (instancetype)initWithApiKey:(NSString *)apiKey;

/// @returns An `CSTracer` instance that's ready to create spans and logs.
- (instancetype)initWithApiKey:(NSString *)apiKey componentName:(nullable NSString *)componentName;

/// @returns An `CSTracer` instance that's ready to create spans and logs.
- (instancetype)initWithApiKey:(NSString *)apiKey
                componentName:(nullable NSString *)componentName
         flushIntervalSeconds:(NSUInteger)flushIntervalSeconds;

/// Initialize an CSTracer instance. Either pass the resulting CSTracer* around your application explicitly
/// or use the OTGlobal singleton mechanism.
/// Whether calling `-[CSTracer flush]` manually or whether using automatic background flushing, users may
/// wish to register for UIApplicationDidEnterBackgroundNotification notifications and explicitly call flush
/// at that point.
///
/// @param apiKey the access token.
/// @param componentName the "component name" to associate with spans from this process; e.g.,
///                      the name of your iOS app or the bundle name.
/// @param baseURL the URL for the collector's HTTP+JSON base endpoint (search for CSDefaultBaseURLString)
/// @param flushIntervalSeconds the flush interval, or 0 for no automatic background flushing
///
/// @returns An `CSTracer` instance that's ready to create spans and logs.
- (instancetype)initWithApiKey:(NSString *)apiKey
                componentName:(nullable NSString *)componentName
                      baseURL:(nullable NSURL *)baseURL
         flushIntervalSeconds:(NSUInteger)flushIntervalSeconds
                     metadata:(nullable NSDictionary<NSString *, NSString *> *)metadata;


#pragma mark - CodeScope extensions and internal methods

@property(nonatomic) NSDictionary<NSString *, NSString *> *metadata;

/// The remote service base URL
@property(nonatomic, strong, readonly) NSURL *baseURL;

/// HTTP session to be used for performing requests. This enables sharing a connnection pool with your own app.
/// It should be set during initialization, ideally before starting and finishing Spans.
@property(nonatomic, strong) NSURLSession *urlSession;

/// The `CSTracer` instance's maximum number of records to buffer between reports.
@property(atomic) NSUInteger maxSpanRecords;

/// Maximum string length of any single JSON payload.
@property(atomic) NSUInteger maxPayloadJSONLength;

/// If true, the library is currently buffering and reporting data. If set to false, tracing data is no longer
/// collected.
@property(atomic) BOOL enabled;

/// Tracer's access token
@property(atomic, strong, readonly) NSString *apiKey;

@property(atomic, strong, readonly) NSMutableArray<CSSpan *> *activeSpanStack;

/// Record a span.
- (void)_appendSpanJSON:(NSDictionary *)spanRecord;

/// Record an event.
- (void)_appendEventJSON:(NSDictionary *)eventRecord;

/// Flush any buffered data to the collector. This is a blocking call.
- (void)flush;

@end

NS_ASSUME_NONNULL_END
