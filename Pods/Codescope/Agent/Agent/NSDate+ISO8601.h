//
//  NSDate+ISO8601.h
//  Agent
//
//  Created by Fernando Mayo Fernandez on 10/29/18.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (ISO8601)
@property(class, readonly) NSDateFormatter *formatter;

+ (NSDate *)fromISO8601:(NSString *)string;
- (NSString *)toISO8601;

@end

NS_ASSUME_NONNULL_END
