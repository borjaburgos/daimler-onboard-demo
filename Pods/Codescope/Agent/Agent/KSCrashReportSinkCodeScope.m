//
//  KSCrashReportSinkCodeScope.m
//  Agent
//
//  Created by Fernando Mayo Fernandez on 10/30/18.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import "KSCrash/KSCrashReportFilterAppleFmt.h"
#import "KSCrash/KSCrashReportFields.h"
#import "KSCrashReportSinkCodeScope.h"
#import "CSAgent.h"
#import "CSTags.h"

@interface KSCrashReportFilterAppleFmt ()
- (NSString*) threadListStringForReport:(NSDictionary*) report
                     mainExecutableName:(NSString*) mainExecutableName;
@end


@implementation KSCrashReportSinkCodeScope

+ (KSCrashReportSinkCodeScope*)sink {
    return [[self alloc] init];
}

- (id<KSCrashReportFilter>)defaultCrashReportFilterSet {
    return self;
}

- (void)filterReports:(NSArray *)reports onCompletion:(KSCrashReportFilterCompletion)onCompletion {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    KSCrashReportFilterAppleFmt *appleFormatter = [KSCrashReportFilterAppleFmt filterWithReportStyle:KSAppleReportStyleSymbolicated];
    
    for(NSDictionary *report in reports) {
        NSDictionary *spanJSON = [report valueForKeyPath:@"user.activeSpan"];
        if(spanJSON == nil) {
            continue;
        }
        NSDate *startTime = [NSDate fromISO8601:[spanJSON valueForKey:@"start"]];
        NSDate *crashTime = [formatter dateFromString:[report valueForKeyPath:@"report.timestamp"]];
        if([crashTime compare:startTime] == NSOrderedAscending) {
            crashTime = startTime;
        }
        NSNumber *duration = @((int64_t)([crashTime timeIntervalSinceDate:startTime] * 1e9));
        [spanJSON setValue:duration forKey:@"duration"];
        [spanJSON setValue:[NSNull null] forKey:@"parent_span_id"];
        NSDictionary *tags = [spanJSON valueForKey:@"tags"];
        [tags setValue:@"ERROR" forKey:@CSTAG_TEST_STATUS];
        [tags setValue:@YES forKey:@"error"];
        [CSAgent.sharedAgent.tracer _appendSpanJSON:spanJSON];
        NSString *diagnosis = [report valueForKeyPath:@KSCrashField_Crash @"." @KSCrashField_Diagnosis];
        NSString *exception = [report valueForKeyPath:@KSCrashField_Crash @"." @KSCrashField_Error @"." @KSCrashField_Mach @"." @KSCrashField_ExceptionName];
        [CSAgent.sharedAgent.tracer _appendEventJSON:@{
                                                       @"context": [spanJSON valueForKey:@"context"],
                                                       @"timestamp": [crashTime toISO8601],
                                                       @"fields": @{
                                                               @CSTAG_EVENT: @"error",
                                                               @CSTAG_MESSAGE: diagnosis ?: [NSString stringWithFormat:@"Exception: %@", exception],
                                                               @CSTAG_ERROR_KIND: exception,
                                                               @CSTAG_STACK: [[appleFormatter threadListStringForReport:report mainExecutableName:[report valueForKeyPath:@KSCrashField_Report @"." @KSCrashField_ProcessName]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                                                               }
                                                       }];
    }
    kscrash_callCompletion(onCompletion, reports, YES, nil);
}

@end
