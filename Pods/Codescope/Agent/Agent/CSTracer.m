#import <UIKit/UIKit.h>
#import "opentracing/OTReference.h"

#import "NSData+CSGzip.h"
#import "CSSpan.h"
#import "CSSpanContext.h"
#import "CSTracer.h"
#import "CSUtil.h"
#import "CSTags.h"

static const int CSDefaultFlushIntervalSeconds = 30;
static const NSUInteger CSDefaultMaxBufferedSpans = 5000;
static const NSUInteger CSDefaultMaxPayloadJSONLength = 32 * 1024;
NSInteger const CSBackgroundTaskError = 1;
NSInteger const CSRequestTooLargeError = 2;
NSString *const CSErrorDomain = @"com.codescope";

#pragma mark - Private properties

@interface CSTracer ()
@property(nonatomic, strong) NSMutableArray<NSDictionary *> *pendingJSONSpans;
@property(nonatomic, strong) NSMutableArray<NSDictionary *> *pendingJSONEvents;
@property(nonatomic, strong, readonly) NSDictionary<NSString *, id> *tracerJSON;

@property(nonatomic, strong, readonly) dispatch_queue_t flushQueue;
@property(nonatomic, strong) dispatch_source_t flushTimer;
@property(nonatomic, strong) NSDate *lastFlush;
@property(nonatomic) UInt64 runtimeGuid;
@end

#pragma mark - Tracer implementation

@implementation CSTracer

- (instancetype)initWithApiKey:(NSString *)apiKey
                 componentName:(NSString *)componentName
                       baseURL:(NSURL *)baseURL
          flushIntervalSeconds:(NSUInteger)flushIntervalSeconds
                   metadata:(NSDictionary<NSString *, NSString *> *)metadata {
    if (self = [super init]) {
        _apiKey = apiKey;
        _maxSpanRecords = CSDefaultMaxBufferedSpans;
        _maxPayloadJSONLength = CSDefaultMaxPayloadJSONLength;
        _pendingJSONSpans = [NSMutableArray<NSDictionary *> array];
        _pendingJSONEvents = [NSMutableArray<NSDictionary *> array];
        _flushQueue = dispatch_queue_create("com.codescope.flush_queue", DISPATCH_QUEUE_SERIAL);
        _flushTimer = nil;
        _enabled = true;
        _lastFlush = [NSDate date];
        _baseURL = baseURL;
        _metadata = metadata;
        _activeSpanStack = [NSMutableArray<CSSpan *> array];
        [self _forkFlushLoop:flushIntervalSeconds];
    }
    return self;
}

- (instancetype)initWithApiKey:(NSString *)apiKey
                 componentName:(nullable NSString *)componentName
          flushIntervalSeconds:(NSUInteger)flushIntervalSeconds {
    return [self initWithApiKey:apiKey
                  componentName:componentName
                        baseURL:nil
           flushIntervalSeconds:flushIntervalSeconds
                       metadata:nil];
}

- (instancetype)initWithApiKey:(NSString *)apiKey componentName:(NSString *)componentName {
    return [self initWithApiKey:apiKey
                  componentName:componentName
                        baseURL:nil
           flushIntervalSeconds:CSDefaultFlushIntervalSeconds
                       metadata:nil];
}

- (instancetype)initWithApiKey:(NSString *)apiKey {
    NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    return [self initWithApiKey:apiKey componentName:bundleName];
}

- (id<OTSpan>)startSpan:(NSString *)operationName {
    return [self startSpan:operationName childOf:nil tags:nil startTime:[NSDate date]];
}

- (id<OTSpan>)startSpan:(NSString *)operationName tags:(NSDictionary *)tags {
    return [self startSpan:operationName childOf:nil tags:tags startTime:[NSDate date]];
}

- (id<OTSpan>)startSpan:(NSString *)operationName childOf:(id<OTSpanContext>)parent {
    return [self startSpan:operationName childOf:parent tags:nil startTime:[NSDate date]];
}

- (id<OTSpan>)startSpan:(NSString *)operationName childOf:(id<OTSpanContext>)parent tags:(NSDictionary *)tags {
    return [self startSpan:operationName childOf:parent tags:tags startTime:[NSDate date]];
}

- (id<OTSpan>)startSpan:(NSString *)operationName
                childOf:(id<OTSpanContext>)parent
                   tags:(NSDictionary *)tags
              startTime:(NSDate *)startTime {
    return [self startSpan:operationName references:@[[OTReference childOf:parent]] tags:tags startTime:startTime];
}

- (id<OTSpan>)startSpan:(NSString *)operationName
             references:(NSArray *)references
                   tags:(NSDictionary *)tags
              startTime:(NSDate *)startTime {
    CSSpanContext *parent = nil;
    if (references != nil) {
        for (OTReference *ref in references) {
            if (ref != nil &&
                ([ref.type isEqualToString:OTReferenceChildOf] || [ref.type isEqualToString:OTReferenceFollowsFrom])) {
                parent = (CSSpanContext *)ref.referencedContext;
            }
        }
    }
    // No locking required
    return [[CSSpan alloc] initWithTracer:self operationName:operationName parent:parent tags:tags startTime:startTime];
    return nil;
}

- (BOOL)inject:(id<OTSpanContext>)span format:(NSString *)format carrier:(id)carrier {
    return [self inject:span format:format carrier:carrier error:nil];
}

// These strings are used for TextMap inject and join.
static NSString *kBasicTracerStatePrefix = @"ot-tracer-";
static NSString *kTraceIdKey = @"ot-tracer-traceid";
static NSString *kSpanIdKey = @"ot-tracer-spanid";
static NSString *kSampledKey = @"ot-tracer-sampled";
static NSString *kBasicTracerBaggagePrefix = @"ot-baggage-";

- (BOOL)inject:(id<OTSpanContext>)spanContext
        format:(NSString *)format
       carrier:(id)carrier
         error:(NSError *__autoreleasing *)outError {
    CSSpanContext *ctx = (CSSpanContext *)spanContext;
    if ([format isEqualToString:OTFormatTextMap] || [format isEqualToString:OTFormatHTTPHeaders]) {
        NSMutableDictionary *dict = carrier;
        [dict setObject:ctx.hexTraceId forKey:kTraceIdKey];
        [dict setObject:ctx.hexSpanId forKey:kSpanIdKey];
        [dict setObject:@"true" forKey:kSampledKey];
        // TODO: HTTP headers require special treatment here.
        [ctx forEachBaggageItem:^BOOL(NSString *key, NSString *val) {
            [dict setObject:val forKey:key];
            return true;
        }];
        return true;
    } else if ([format isEqualToString:OTFormatBinary]) {
        // TODO: support the binary carrier here.
        if (outError != nil) {
            *outError = [NSError errorWithDomain:OTErrorDomain code:OTUnsupportedFormatCode userInfo:nil];
        }
        return false;
    } else {
        if (outError != nil) {
            *outError = [NSError errorWithDomain:OTErrorDomain code:OTUnsupportedFormatCode userInfo:nil];
        }
        return false;
    }
}

- (id<OTSpanContext>)extractWithFormat:(NSString *)format carrier:(id)carrier {
    return [self extractWithFormat:format carrier:carrier error:nil];
}

- (id<OTSpanContext>)extractWithFormat:(NSString *)format
                               carrier:(id)carrier
                                 error:(NSError *__autoreleasing *)outError {
    if ([format isEqualToString:OTFormatTextMap]) {
        NSMutableDictionary *dict = carrier;
        NSMutableDictionary *baggage;
        int foundRequiredFields = 0;
        UInt64 traceId = 0;
        UInt64 spanId = 0;
        for (NSString *key in dict) {
            if ([key hasPrefix:kBasicTracerBaggagePrefix]) {
                [baggage setObject:[dict objectForKey:key]
                            forKey:[key substringFromIndex:kBasicTracerBaggagePrefix.length]];
            } else if ([key hasPrefix:kBasicTracerStatePrefix]) {
                if ([key isEqualToString:kTraceIdKey]) {
                    foundRequiredFields++;
                    traceId = [CSUtil guidFromHex:[dict objectForKey:key]];
                    if (traceId == 0) {
                        if (outError != nil) {
                            *outError =
                            [NSError errorWithDomain:OTErrorDomain code:OTSpanContextCorruptedCode userInfo:nil];
                        }
                        return nil;
                    }
                } else if ([key isEqualToString:kSpanIdKey]) {
                    foundRequiredFields++;
                    spanId = [CSUtil guidFromHex:[dict objectForKey:key]];
                    if (spanId == 0) {
                        if (outError != nil) {
                            *outError =
                            [NSError errorWithDomain:OTErrorDomain code:OTSpanContextCorruptedCode userInfo:nil];
                        }
                        return nil;
                    }
                } else if ([key isEqualToString:kSampledKey]) {
                    // TODO: care about sampled status at this layer
                }
            }
        }
        if (foundRequiredFields == 0) {
            // (no error per se, just didn't find a trace to join)
            return nil;
        }
        if (foundRequiredFields < 2) {
            if (outError != nil) {
                *outError = [NSError errorWithDomain:OTErrorDomain code:OTSpanContextCorruptedCode userInfo:nil];
            }
            return nil;
        }
        
        return [[CSSpanContext alloc] initWithTraceId:traceId spanId:spanId baggage:baggage];
    } else if ([format isEqualToString:OTFormatBinary]) {
        if (outError != nil) {
            *outError = [NSError errorWithDomain:OTErrorDomain code:OTUnsupportedFormatCode userInfo:nil];
        }
        return nil;
    } else {
        if (outError != nil) {
            *outError = [NSError errorWithDomain:OTErrorDomain code:OTUnsupportedFormatCode userInfo:nil];
        }
        return nil;
    }
}

- (void)_appendSpanJSON:(NSDictionary *)spanJSON {
    @synchronized(self) {
        if (!self.enabled) {
            return;
        }
        
        if (self.pendingJSONSpans.count < self.maxSpanRecords) {
            [self.pendingJSONSpans addObject:spanJSON];
        }
    }
}

- (void)_appendEventJSON:(NSDictionary *)eventJSON {
    @synchronized(self) {
        if (!self.enabled) {
            return;
        }
        
        [self.pendingJSONEvents addObject:eventJSON];
    }
}

// Establish the m_flushTimer ticker.
- (void)_forkFlushLoop:(NSUInteger)flushIntervalSeconds {
    @synchronized(self) {
        if (!self.enabled) {
            // Noop.
            return;
        }
        if (flushIntervalSeconds == 0) {
            // Noop.
            return;
        }
        self.flushTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.flushQueue);
        if (!self.flushTimer) {
            return;
        }
        dispatch_source_set_timer(self.flushTimer, DISPATCH_TIME_NOW, flushIntervalSeconds * NSEC_PER_SEC,
                                  NSEC_PER_SEC);
        __weak __typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(self.flushTimer, ^{
            [weakSelf flush];
        });
        dispatch_resume(self.flushTimer);
    }
}

- (void)flush {
    if (!self.enabled) {
        // Short-circuit.
        return;
    }
    
    NSDictionary *reqJSON;
    @synchronized(self) {
        NSDate *now = [NSDate date];
        if (self.pendingJSONSpans.count == 0 && self.pendingJSONEvents.count == 0) {
            // Nothing to report.
            return;
        }
        
        reqJSON = @{
                    @"metadata": self.metadata,
                    @"spans": self.pendingJSONSpans,
                    @"events": self.pendingJSONEvents,
                    };
        self.pendingJSONSpans = [NSMutableArray<NSDictionary *> new];
        self.pendingJSONEvents = [NSMutableArray<NSDictionary *> new];
        self.lastFlush = now;
    }
    
    NSData *reqBody = [NSJSONSerialization dataWithJSONObject:reqJSON options:0 error:nil];
    if (reqBody == nil) {
        @throw [NSError errorWithDomain:CSErrorDomain code:CSRequestTooLargeError userInfo:nil];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self.baseURL URLByAppendingPathComponent:@"/api/agent/ingest"]];
    request.allHTTPHeaderFields = @{
                                    @"Content-Type": @"application/json",
                                    @"X-CodeScope-ApiKey": self.apiKey,
                                    @"Content-Encoding": @"gzip"
                                    };
    request.HTTPBody = [reqBody gzippedData];
    request.HTTPMethod = @"POST";
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURLSessionDataTask *postDataTask =
    [self.urlSession dataTaskWithRequest:request
                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                           dispatch_semaphore_signal(semaphore);
                       }];
    [postDataTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (NSURLSession *)urlSession {
    if (_urlSession) {
        return _urlSession;
    }
    
    _urlSession = [NSURLSession sessionWithConfiguration:
                   [NSURLSessionConfiguration defaultSessionConfiguration]];
    return _urlSession;
}

@end
