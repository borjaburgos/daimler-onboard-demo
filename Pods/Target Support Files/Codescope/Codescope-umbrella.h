#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Agent.h"

FOUNDATION_EXPORT double CodescopeVersionNumber;
FOUNDATION_EXPORT const unsigned char CodescopeVersionString[];

