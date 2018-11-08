//
//  CSAgent.m
//  Agent
//
//  Created by Fernando Mayo on 14/10/2018.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import <mach-o/arch.h>
#import "opentracing/OTGlobal.h"
#import "CSAgent.h"
#import "CSTags.h"


static NSString *const CSDefaultBaseURLString = @"https://api.codescope.com";
static NSString *const CSDefaultServiceString = @"default";
static NSString *const CSDefaultSourceRoot = @"/";

@implementation CSAgent

static CSAgent *_sharedAgent = nil;

@dynamic sharedAgent;

+ (void)load {
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *apiKey = [environment valueForKey:@"CODESCOPE_APIKEY"];
    if([apiKey length] == 0) {
        CSLog(@"Warning: no API key detected - aborting CodeScope agent installation");
        return;
    }

    NSString *baseURL = [environment valueForKey:@"CODESCOPE_API_ENDPOINT"];
    if([baseURL length] == 0) {
        baseURL = CSDefaultBaseURLString;
    }

    NSString *commit = [environment valueForKey:@"CODESCOPE_COMMIT_SHA"];
    if([commit length] == 0) {
        CSLog(@"Warning: no commit detected - aborting CodeScope agent installation");
        return;
    } else {
        CSLog(@"Autodetected commit: %@", commit);
    }

    NSString *repository = [environment valueForKey:@"CODESCOPE_REPOSITORY"];
    if([repository length] == 0) {
        CSLog(@"No repository detected - aborting CodeScope agent installation");
        return;
    } else {
        CSLog(@"Autodetected repository: %@", repository);
    }

    NSString *service = [environment valueForKey:@"CODESCOPE_SERVICE"];
    if([service length] == 0) {
        service = CSDefaultServiceString;
    }

    NSString *sourceRoot = [environment valueForKey:@"CODESCOPE_SOURCE_ROOT"];
    if([sourceRoot length] == 0) {
        sourceRoot = CSDefaultSourceRoot;
    }

    CSAgent *agent = [[CSAgent alloc] initWithApiKey:apiKey
                                          repository:repository
                                              commit:commit
                                             service:service
                                             baseURL:[NSURL URLWithString:baseURL]
                                          sourceRoot:sourceRoot];
    [agent install];
    CSAgent.sharedAgent = agent;
}

+ (CSAgent *)sharedAgent {
    return _sharedAgent;
}

+ (void)setSharedAgent:(CSAgent *)sharedAgent {
    _sharedAgent = sharedAgent;
}

- (instancetype)initWithApiKey:(NSString *)apiKey
                    repository:(NSString *)repository
                        commit:(NSString *)commit
                       service:(NSString *)service
                       baseURL:(NSURL *)baseUrl
                    sourceRoot:(NSString *)sourceRoot {
    if (self = [super init]) {
        _baseURL = baseUrl;
        _agentId = [[[NSUUID UUID] UUIDString] lowercaseString];
        _apiKey = apiKey;
        _repository = repository;
        _commit = commit;
        _service = service;
        _sourceRoot = sourceRoot;
    }
    return self;
}

- (void)install {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.testObserver = [[CSTestObserver alloc] init];
        self.sharedKSCrash = [KSCrashInstallationCodeScope sharedInstance];
        [self.sharedKSCrash install];
        NSDictionary *metadata = @{
            @CSTAG_AGENT_ID: self.agentId,
            @CSTAG_AGENT_VERSION: @CSAGENT_VERSION,
            @CSTAG_SERVICE: self.service,
            @CSTAG_REPOSITORY: self.repository,
            @CSTAG_COMMIT: self.commit,
            @CSTAG_HOSTNAME: [[NSProcessInfo processInfo] hostName],
            @CSTAG_SOURCE_ROOT: self.sourceRoot,
            @CSTAG_PLATFORM_NAME: @"iOS",
            @CSTAG_PLATFORM_VERSION: [[UIDevice currentDevice] systemVersion],
            @CSTAG_DEVICE_NAME: [[UIDevice currentDevice] name],
            @CSTAG_DEVICE_MODEL: [[UIDevice currentDevice] model],
            @CSTAG_ARCHITECTURE: [NSString stringWithUTF8String:NXGetLocalArchInfo()->description],
        };
        
        self.tracer = [[CSTracer alloc] initWithApiKey:self.apiKey
                                         componentName:self.service
                                               baseURL:self.baseURL
                                  flushIntervalSeconds:1
                                              metadata:metadata];
        [OTGlobal initSharedTracer:self.tracer];
    });
}

@end
