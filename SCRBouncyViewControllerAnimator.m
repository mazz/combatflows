//
//  SCRBouncyViewControllerAnimator.m
//  scrappling
//
//  Created by Michael Hanna on 2015-06-17.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCRBouncyViewControllerAnimator.h"

@implementation SCRBouncyViewControllerAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.8;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    
    UIView *presentedControllerView = [transitionContext viewForKey:UITransitionContextToViewKey];

    CGPoint centre = presentedControllerView.center;
    presentedControllerView.center = CGPointMake(centre.x, -presentedControllerView.bounds.size.height);
    [[transitionContext containerView] addSubview:presentedControllerView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:9.9 options:nil animations:^{
        presentedControllerView.center = centre;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end
