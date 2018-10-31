//
//  CSLogPipe.m
//  Agent
//
//  Created by Fernando Mayo on 19/10/2018.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import "CSLogPipe.h"

static CSLogPipe *sharedLog = nil;

@implementation CSLogPipe

- (void)redirectStdout
{
    self.stdoutPipe = [NSPipe pipe];
    [self redirectFile:stdout withName:@"stdout" toPipe:self.stdoutPipe];
}

- (void)redirectStderr
{
    self.stderrPipe = [NSPipe pipe];
    [self redirectFile:stderr withName:@"stderr" toPipe:self.stderrPipe];
}

- (void)redirectFile:(FILE *)file withName:(NSString *)name toPipe:(NSPipe *)pipe
{
    FILE *_orig = fdopen(dup(fileno(file)), "w");
    dup2([[pipe fileHandleForWriting] fileDescriptor], fileno(file));
    [pipe fileHandleForReading].readabilityHandler = ^(NSFileHandle *fh){
        NSString* str = [[[NSString alloc] initWithData:[fh availableData] encoding:NSASCIIStringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        if([str length] > 0) {
            fprintf(_orig, "[%s] %s\n", [name UTF8String], [[str stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] UTF8String]);
        }
    };
}

@end
