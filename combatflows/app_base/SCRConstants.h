//
//  SCCNetworkConstants.h
//  SecureConversations
//
//  Created by Alex Lee on 2014-08-06.
//  Copyright (c) 2014 PointClickCare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern double kSCRConstantsThumbDivisor;

extern NSString* kGAIEventCategoryWatchVideo;
extern NSString* kGAIEventActionWatchVideoCompleted;
extern NSString* kGAIEventActionWatchVideoConnectionType;
extern NSString* kGAIEventLabelWatchVideoDuration;

@interface SCRConstants : NSObject
@property (nonatomic, strong) UIWindow *applicationWindow;
+ (SCRConstants *)sharedInstance;

- (NSString *)hardwareType;
- (NSString *)systemVersion;
@end
