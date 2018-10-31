//
//  NSDate+ISO8601.m
//  Agent
//
//  Created by Fernando Mayo Fernandez on 10/29/18.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import "NSDate+ISO8601.h"

@implementation NSDate (ISO8601)

@dynamic formatter;

+ (NSDate *)fromISO8601:(NSString *)string {
    return [self.formatter dateFromString:string];
}

- (NSString *)toISO8601 {
    return [self.class.formatter stringFromDate:self];
}

+ (NSDateFormatter *)formatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSS'+00:00'";
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    return formatter;
}

@end
