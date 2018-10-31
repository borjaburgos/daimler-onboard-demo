#import "CSUtil.h"
#import <stdlib.h> // arc4random_uniform()

@implementation CSUtil

+ (UInt64)generateGUID {
    return (((UInt64)arc4random()) << 32) | arc4random();
}

+ (NSString *)hexGUID:(UInt64)guid {
    return [NSString stringWithFormat:@"%llx", guid];
}

+ (UInt64)guidFromHex:(NSString *)hexString {
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    UInt64 rval;
    if (![scanner scanHexLongLong:&rval]) {
        return 0; // what else to do?
    }
    return rval;
}

@end

@implementation NSDate (CSSpan)
- (int64_t)toMicros {
    return (int64_t)([self timeIntervalSince1970] * USEC_PER_SEC);
}
@end
