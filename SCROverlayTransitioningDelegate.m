//
//  SCROverlayTransitioningDelegate.m
//  scrappling
//
//  Created by Michael Hanna on 2015-06-17.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCROverlayTransitioningDelegate.h"
#import "SCROverlayPresentationController.h"
#import "SCRBouncyViewControllerAnimator.h"

@implementation SCROverlayTransitioningDelegate
-(UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return [[SCROverlayPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[SCRBouncyViewControllerAnimator alloc] init];
}

@end
