//
//  CSLogPipe.h
//  Agent
//
//  Created by Fernando Mayo on 19/10/2018.
//  Copyright © 2018 Codescope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <unistd.h>


@interface CSLogPipe : NSObject
@property NSPipe *stdoutPipe;
@property NSPipe *stderrPipe;
@end
