#import "CSSpanContext.h"
#import "CSUtil.h"

@implementation CSSpanContext

- (instancetype)initWithTraceId:(UInt64)traceId spanId:(UInt64)spanId baggage:(nullable NSDictionary *)baggage {
    if (self = [super init]) {
        _traceId = traceId;
        _spanId = spanId;
        _baggage = baggage ?: @{};
    }
    return self;
}

- (CSSpanContext *)withBaggageItem:(NSString *)key value:(NSString *)value {
    NSMutableDictionary *baggageCopy = [self.baggage mutableCopy];
    [baggageCopy setObject:value forKey:key];
    return [[CSSpanContext alloc] initWithTraceId:self.traceId spanId:self.spanId baggage:baggageCopy];
}

- (NSString *)baggageItemForKey:(NSString *)key {
    return (NSString *)[self.baggage objectForKey:key];
}

- (void)forEachBaggageItem:(BOOL (^)(NSString *key, NSString *value))callback {
    for (NSString *key in self.baggage) {
        if (!callback(key, [self.baggage objectForKey:key])) {
            return;
        }
    }
}

- (NSString *)hexTraceId {
    return [CSUtil hexGUID:self.traceId];
}

- (NSString *)hexSpanId {
    return [CSUtil hexGUID:self.spanId];
}

- (NSDictionary *)toJSON {
    return @{
             @"trace_id": self.hexTraceId,
             @"span_id": self.hexSpanId,
             @"baggage": self.baggage ?: [NSNull null],
             };
}

@end
