#import <Foundation/Foundation.h>
#import "opentracing/OTSpanContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSSpanContext : NSObject<OTSpanContext>

#pragma mark - CodeScope API

- (instancetype)initWithTraceId:(UInt64)traceId spanId:(UInt64)spanId baggage:(nullable NSDictionary *)baggage;

/// Return a copy of this SpanContext with the given (potentially additional) baggage item.
- (CSSpanContext *)withBaggageItem:(NSString *)key value:(NSString *)value;

/// Return a specific baggage item.
- (NSString *)baggageItemForKey:(NSString *)key;

/// The CodeScope Span's probabilistically unique trace id.
@property(nonatomic) UInt64 traceId;

/// The CodeScope Span's probabilistically unique (span) id.
@property(nonatomic) UInt64 spanId;

/// The trace id as a hexadecimal string.
- (NSString *)hexTraceId;

/// The span id as a hexadecimal string.
- (NSString *)hexSpanId;

- (NSDictionary *)toJSON;

#pragma mark - Internal

/// The baggage dictionary (for internal use only).
@property(nonatomic, strong, readonly) NSDictionary *baggage;

@end

NS_ASSUME_NONNULL_END
