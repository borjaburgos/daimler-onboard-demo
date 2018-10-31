#import "CSSpan.h"
#import "CSSpanContext.h"
#import "CSTracer.h"
#import "CSUtil.h"

#pragma mark - CSLog

@interface CSLog : NSObject

@property(nonatomic, strong, readonly) NSDate *timestamp;
@property(nonatomic, strong, readonly) NSDictionary<NSString *, NSObject *> *fields;

- (instancetype)initWithTimestamp:(NSDate *)timestamp fields:(NSDictionary<NSString *, NSObject *> *)fields;

@end

@implementation CSLog

- (instancetype)initWithTimestamp:(NSDate *)timestamp fields:(NSDictionary<NSString *, NSObject *> *)fields {
    if (self = [super init]) {
        _timestamp = timestamp;
        _fields = [NSDictionary dictionaryWithDictionary:fields];
    }
    return self;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary<NSString *, NSObject *> *outputFields = @{}.mutableCopy;
    outputFields[@"timestamp"] = self.timestamp.toISO8601;
    if (self.fields.count > 0) {
        outputFields[@"fields"] = self.fields;
    }
    return outputFields;
}

@end

#pragma mark - CSSpan

@interface CSSpan ()
@property(nonatomic, strong) CSSpanContext *parent;
@property(atomic, strong) NSString *operationName;
@property(atomic, strong) CSSpanContext *context;
@property(nonatomic, strong) NSMutableArray<CSLog *> *logs;
@property(atomic, strong, readonly) NSMutableDictionary<NSString *, NSString *> *mutableTags;
@end

@implementation CSSpan

- (instancetype)initWithTracer:(CSTracer *)client {
    return [self initWithTracer:client operationName:@"" parent:nil tags:nil startTime:nil];
}

- (instancetype)initWithTracer:(CSTracer *)tracer
                 operationName:(NSString *)operationName
                        parent:(nullable CSSpanContext *)parent
                          tags:(nullable NSDictionary *)tags
                     startTime:(nullable NSDate *)startTime {
    if (self = [super init]) {
        _tracer = tracer;
        _operationName = operationName;
        _startTime = startTime ?: [NSDate date];
        _logs = @[].mutableCopy;
        _mutableTags = @{}.mutableCopy;
        _parent = parent;
        
        UInt64 traceId = parent.traceId ?: [CSUtil generateGUID];
        UInt64 spanId = [CSUtil generateGUID];
        _context = [[CSSpanContext alloc] initWithTraceId:traceId spanId:spanId baggage:parent.baggage];
        
        [self addTags:tags];
    }
    return self;
}

- (NSDictionary<NSString *, NSString *> *)tags {
    return [self.mutableTags copy];
}

- (void)setTag:(NSString *)key value:(NSString *)value {
    [self.mutableTags setObject:value forKey:key];
}

- (void)logEvent:(NSString *)eventName {
    [self log:eventName timestamp:[NSDate date] payload:nil];
}

- (void)logEvent:(NSString *)eventName payload:(NSObject *)payload {
    [self log:eventName timestamp:[NSDate date] payload:payload];
}

- (void)log:(NSDictionary<NSString *, NSObject *> *)fields {
    [self log:fields timestamp:[NSDate date]];
}

- (void)log:(NSDictionary<NSString *, NSObject *> *)fields timestamp:(nullable NSDate *)timestamp {
    // No locking is required as all the member variables used below are immutable
    // after initialization.
    if (!self.tracer.enabled) {
        return;
    }
    [self _appendLog:[[CSLog alloc] initWithTimestamp:timestamp fields:fields]];
}

- (void)_appendLog:(CSLog *)log {
    [self.logs addObject:log];
}

- (void)finish {
    [self finishWithTime:[NSDate date]];
}

- (void)finishWithTime:(NSDate *)finishTime {
    if (finishTime == nil) {
        finishTime = [NSDate date];
    }
    
    NSDictionary *spanJSON;
    @synchronized(self) {
        spanJSON = [self _toJSONWithFinishTime:finishTime];
    }
    [self.tracer _appendSpanJSON:spanJSON];
    for (CSLog *l in self.logs) {
        NSDictionary *eventJSON = [l toJSON];
        [eventJSON setValue:[self.context toJSON] forKey:@"context"];
        [self.tracer _appendEventJSON:eventJSON];
    }
}

- (id<OTSpan>)setBaggageItem:(NSString *)key value:(NSString *)value {
    // TODO: change selector in OTSpan.h to setBaggageItem:forKey:
    self.context = [self.context withBaggageItem:key value:value];
    return self;
}

- (NSString *)getBaggageItem:(NSString *)key {
    // TODO: rename selector in OTSpan.h to baggageItemForKey:
    return [self.context baggageItemForKey:key];
}

/// Add a set of tags from the given dictionary. Existing key-value pairs will be overwritten by any new tags.
- (void)addTags:(NSDictionary *)tags {
    if (tags == nil) {
        return;
    }
    [self.mutableTags addEntriesFromDictionary:tags];
}

- (NSString *)tagForKey:(NSString *)key {
    return (NSString *)[self.mutableTags objectForKey:key];
}

/**
 * Generate a JSON-ready NSDictionary representation. Return value must not be
 * modified.
 */
- (NSDictionary *)_toJSONWithFinishTime:(NSDate *)finishTime {
    return @{
             @"context": [self.context toJSON],
             @"parent_span_id": self.parent ? self.parent.hexSpanId : [NSNull null],
             @"operation": self.operationName,
             @"start": self.startTime.toISO8601,
             @"duration": @((int64_t)([finishTime timeIntervalSinceDate:self.startTime] * 1e9)),
             @"tags": self.mutableTags ?: [NSNull null],
             };
}

@end
