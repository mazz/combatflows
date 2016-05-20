//
//  SCRReachabilityService.h
//  scrappling
//
//  Created by Michael Hanna on 2015-09-14.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>

UIKIT_EXTERN NSString *const SCRReachabilityChangedNotification;
@interface SCRReachabilityService : NSObject
+ (SCRReachabilityService *)sharedInstance;
- (void)start;
- (BOOL)isOffline;
- (BOOL)isCellular;
- (BOOL)isWIFI;
@end
