#import <Foundation/Foundation.h>
#import "opentracing/OTSpan.h"
#import "NSDate+ISO8601.h"
NS_ASSUME_NONNULL_BEGIN

@class CSSpanContext;
@class CSTracer;

/// An `CSSpan` represents a logical unit of work done by the service.
/// One or more spans – presumably from different processes – are assembled into traces.
///
/// The CSSpan class is thread-safe.
@interface CSSpan : NSObject<OTSpan>


@property(nonatomic, strong, readonly) CSTracer *tracer;

/// Internal function.
///
/// Creates a new span associated with the given tracer.
- (instancetype)initWithTracer:(CSTracer *)tracer;

/// Internal function.
///
/// Creates a new span associated with the given tracer and the other optional parameters.
- (instancetype)initWithTracer:(CSTracer *)tracer
                 operationName:(NSString *)operationName
                        parent:(nullable CSSpanContext *)parent
                          tags:(nullable NSDictionary *)tags
                     startTime:(nullable NSDate *)startTime;

@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *tags;

///  Get a particular tag.
- (NSString *)tagForKey:(NSString *)key;

/// For testing only
- (NSDictionary *)_toJSONWithFinishTime:(NSDate *)finishTime;

@property(nonatomic, strong, readonly) NSDate *startTime;

@end
NS_ASSUME_NONNULL_END
