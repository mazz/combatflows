//
//  SCRReachabilityService.m
//  scrappling
//
//  Created by Michael Hanna on 2015-09-14.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCRReachabilityService.h"
#import <netinet/in.h>
static SCNetworkReachabilityRef _sReachabilityRef;
SCNetworkReachabilityFlags _flags;

NSString *const SCRReachabilityChangedNotification   = @"SCRReachabilityChangedNotification";


/**
 * @brief Callback method for network reachability. This function is called automatically by the SCNetworkReachability framework when network change was detected
 *
 * @param target used internally by SCNetworkReachabilityRef.
 * @param flags the bitmask that expresses the network reachability change.
 * @param info the reference to self/context.
 */
static void SCRReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
    if (info != NULL)
    {
        @autoreleasepool
        {
            NSNumber *f = [NSNumber numberWithUnsignedInteger:flags];
            DDLogDebug(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c \n",
                  (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
                  (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
                  
                  (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
                  (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
                  (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
                  (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
                  (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
                  (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
                  (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-'
                  );
            [[NSNotificationCenter defaultCenter] postNotificationName:(NSString*)SCRReachabilityChangedNotification object:nil userInfo:[NSDictionary dictionaryWithObject:f forKey:@"flags"]];
            
            _flags = flags;
        }
    }
}

@implementation SCRReachabilityService

+ (SCRReachabilityService *)sharedInstance
{
    static dispatch_once_t once;
    static SCRReachabilityService * sharedInstance;
    
    dispatch_once(&once, ^{

        sharedInstance = [[self alloc] init];
//        sharedInstance->_productService = [[SCRProductService alloc] init];
        
    });
    
    return sharedInstance;
}

- (void)start
{
    // roll our own network change detection with SCReachabilityRef
    //
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    _sReachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    if(SCNetworkReachabilitySetCallback(_sReachabilityRef, SCRReachabilityCallback, &context))
    {
        SCNetworkReachabilityScheduleWithRunLoop(_sReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

- (BOOL)isOffline {
    return (!(_flags & kSCNetworkReachabilityFlagsIsWWAN) && !(_flags & kSCNetworkReachabilityFlagsReachable));
}

- (BOOL)isCellular {
    return (_flags & kSCNetworkReachabilityFlagsIsWWAN);
}

- (BOOL)isWIFI {
    return (_flags & kSCNetworkReachabilityFlagsReachable);
}

@end
