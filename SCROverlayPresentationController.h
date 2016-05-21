//
//  SCRInsetPresentationController.h
//  scrappling
//
//  Created by Michael Hanna on 2015-06-16.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCROverlayPresentationController : UIPresentationController
{
    UIView *dimmingView;
}

@property (readonly) UIView *dimmingView;
@end
