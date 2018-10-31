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

@implementation CSAgent

static CSAgent *_sharedAgent = nil;

@dynamic sharedAgent;

+ (void)load {
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *apiKey = [environment valueForKey:@"CODESCOPE_APIKEY"];
    if(apiKey == nil) {
        NSLog(@"No API key detected - aborting CodeScope agent installation");
        return;
    }
    
    NSString *commit = [self autodetectCommit];
    if([commit length] == 0) {
        NSLog(@"No commit detected - aborting CodeScope agent installation");
        return;
    } else {
        NSLog(@"Autodetected commit: %@", commit);
    }

    NSString *repository = [environment valueForKey:@"CODESCOPE_REPOSITORY"];
    if([repository length] == 0) {
        NSString *repositoryURL = [self autodetectRepositoryURL];
        if ([repositoryURL length] != 0) {
            repository = [NSString stringWithFormat:@"@%@", repositoryURL];
        }
    }
    if([repository length] == 0) {
        NSLog(@"No repository detected - aborting CodeScope agent installation");
        return;
    } else {
        NSLog(@"Autodetected repository: %@", repository);
    }

    NSString *service = [environment valueForKey:@"CODESCOPE_SERVICE"];
    if([service length] == 0) {
        service = CSDefaultServiceString;
    }
    
    NSString *baseURL = [environment valueForKey:@"CODESCOPE_API_ENDPOINT"];
    if([baseURL length] == 0) {
        baseURL = CSDefaultBaseURLString;
    }
    CSAgent *agent = [[CSAgent alloc] initWithApiKey:apiKey
                                          repository:repository
                                              commit:commit
                                             service:service
                                             baseURL:[NSURL URLWithString:baseURL]];
    [agent install];
    CSAgent.sharedAgent = agent;
}

+ (NSString *)autodetectCommit {
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *commit = [environment valueForKey:@"CODESCOPE_COMMIT_SHA"];
    if([commit length] == 0) {
        // Jenkins
        commit = [environment valueForKey:@"GIT_COMMIT"];
    }
    if([commit length] == 0) {
        // CirclecI
        commit = [environment valueForKey:@"CIRCLE_SHA1"];
    }
    if([commit length] == 0) {
        // Travis CI
        commit = [environment valueForKey:@"TRAVIS_COMMIT"];
    }
    if([commit length] == 0) {
        // GitLab CI
        commit = [environment valueForKey:@"CI_COMMIT_SHA"];
    }
    if([commit length] == 0) {
        // Bitbucket Pipelines
        commit = [environment valueForKey:@"BITBUCKET_COMMIT"];
    }
    if([commit length] == 0) {
        // AWS CodeBuild
        commit = [environment valueForKey:@"CODEBUILD_RESOLVED_SOURCE_VERSION"];
    }
    return commit;
}

+ (NSString *)autodetectRepositoryURL {
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *repository = nil;
    if([repository length] == 0) {
        // Jenkins
        repository = [environment valueForKey:@"GIT_URL"];
    }
    if([repository length] == 0) {
        // CircleCI
        repository = [environment valueForKey:@"CIRCLE_REPOSITORY_URL"];
    }
    if([repository length] == 0) {
        // Travis CI
        NSString *repoSlug = [environment valueForKey:@"TRAVIS_REPO_SLUG"];
        if(repoSlug != nil) {
            repository = [NSString stringWithFormat:@"https://github.com/%@.git", repoSlug];
        }
    }
    if([repository length] == 0) {
        // GitLab CI
        repository = [environment valueForKey:@"CI_REPOSITORY_URL"];
    }
    if([repository length] == 0) {
        // Bitbucket Pipelines
        NSString *repoSlug = [environment valueForKey:@"BITBUCKET_REPO_SLUG"];
        if(repoSlug != nil) {
            repository = [NSString stringWithFormat:@"https://bitbucket.org/%@.git", repoSlug];
        }
    }
    if([repository length] == 0) {
        // AWS CodeBuild
        repository = [environment valueForKey:@"CODEBUILD_SOURCE_REPO_URL"];
    }
    return repository;
}

+ (CSAgent *)sharedAgent {
    return _sharedAgent;
}

+ (void)setSharedAgent:(CSAgent *)sharedAgent {
    _sharedAgent = sharedAgent;
}

- (instancetype)initWithApiKey:(NSString *)apiKey repository:(NSString *)repository commit:(NSString *)commit service:(NSString *)service baseURL:(NSURL *)baseUrl {
    if (self = [super init]) {
        _baseURL = baseUrl;
        _agentId = [[[NSUUID UUID] UUIDString] lowercaseString];
        _apiKey = apiKey;
        _repository = repository;
        _commit = commit;
        _service = service;
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
            @CSTAG_AGENT_VERSION: CSAGENT_VERSION,
            @CSTAG_SERVICE: self.service,
            @CSTAG_REPOSITORY: self.repository,
            @CSTAG_COMMIT: self.commit,
            @CSTAG_HOSTNAME: [[NSProcessInfo processInfo] hostName],
            @CSTAG_PLATFORM_NAME: @"iOS",
            @CSTAG_PLATFORM_VERSION: [[UIDevice currentDevice] systemVersion],
            @CSTAG_DEVICE_NAME: [[UIDevice currentDevice] name],
            @CSTAG_DEVICE_MODEL: [[UIDevice currentDevice] model],
            @CSTAG_ARCHITECTURE: [NSString stringWithUTF8String:NXGetLocalArchInfo()->description],
        };
        // TODO: get CI metadata
        
        self.tracer = [[CSTracer alloc] initWithApiKey:self.apiKey
                                         componentName:self.service
                                               baseURL:self.baseURL
                                  flushIntervalSeconds:1
                                              metadata:metadata];
        [OTGlobal initSharedTracer:self.tracer];
    });
}

- (void)loggingHandler:(NSString *)message inFile:(NSString *)file inLine:(int)line inFunction:(NSString *)function {
    fprintf(stderr, "Codescope: intercepted logs: %s:%3d %s: %s\n", [file UTF8String], line, [function UTF8String], [message UTF8String]);
}

@end
