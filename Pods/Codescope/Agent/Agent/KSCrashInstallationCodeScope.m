//
//  KSCrashInstallationCodeScope.m
//  Agent
//
//  Created by Fernando Mayo Fernandez on 10/30/18.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import "KSCrash/KSCrashInstallation+Private.h"
#import "KSCrash/KSCrashReportFilterBasic.h"
#import "KSCrashInstallationCodeScope.h"
#import "KSCrashReportSinkCodeScope.h"


@implementation KSCrashInstallationCodeScope

+ (instancetype) sharedInstance
{
    static KSCrashInstallationCodeScope *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[KSCrashInstallationCodeScope alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    if((self = [super initWithRequiredProperties:nil]))
    {
        
    }
    return self;
}

- (id<KSCrashReportFilter>)sink
{
    KSCrashReportSinkCodeScope* sink = [KSCrashReportSinkCodeScope sink];
    return [KSCrashReportFilterPipeline filterWithFilters:[sink defaultCrashReportFilterSet], nil];
}

@end
