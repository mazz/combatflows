//
//  SCCNetworkConstants.m
//  SecureConversations
//
//  Created by Alex Lee on 2014-08-06.
//  Copyright (c) 2014 PointClickCare. All rights reserved.
//

#import "SCRConstants.h"
#import <sys/sysctl.h>

double kSCRConstantsThumbDivisor = 2.08;

NSString* kGAIEventCategoryWatchVideo = @"ScrapplingWatchVideo";
NSString* kGAIEventActionWatchVideoCompleted = @"ScrapplingWatchVideoCompleted";
NSString* kGAIEventActionWatchVideoConnectionType = @"ScrapplingWatchVideoConnectionType";
NSString* kGAIEventLabelWatchVideoDuration = @"ScrapplingWatchVideoDuration";

@implementation SCRConstants

+ (SCRConstants *)sharedInstance
{
    static SCRConstants *constants = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        constants = [[SCRConstants alloc] init];
    });
    return constants;
}

- (NSString *)hardwareType
{
    size_t   size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char* machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString* devicecode = [NSString stringWithUTF8String:machine];
    free(machine);
    return devicecode;
}

static NSString *systemVersion = nil;

- (NSString *)systemVersion
{
    if(systemVersion == nil)
    {
        systemVersion = [[UIDevice currentDevice] systemVersion];
    }
    return systemVersion;
}

@end
