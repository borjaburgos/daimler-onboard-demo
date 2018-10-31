//
//  KSCrashReportSinkCodeScope.h
//  Agent
//
//  Created by Fernando Mayo Fernandez on 10/30/18.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import "KSCrash/KSCrashReportFilter.h"


@interface KSCrashReportSinkCodeScope : NSObject <KSCrashReportFilter>

+ (KSCrashReportSinkCodeScope*)sink;

- (id <KSCrashReportFilter>)defaultCrashReportFilterSet;

@end
