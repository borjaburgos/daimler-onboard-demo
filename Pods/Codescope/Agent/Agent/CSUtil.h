#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GPBTimestamp;

/// Shared, generic utility functions used across the library.
@interface CSUtil : NSObject

+ (UInt64)generateGUID;
+ (NSString *)hexGUID:(UInt64)guid;
+ (UInt64)guidFromHex:(NSString *)hexString;

@end

@interface NSDate (CSSpan)
- (int64_t)toMicros;
@end

NS_ASSUME_NONNULL_END
