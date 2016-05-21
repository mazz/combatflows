//
//  SCRInsetPresentationController.m
//  scrappling
//
//  Created by Michael Hanna on 2015-06-16.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCROverlayPresentationController.h"

@implementation SCROverlayPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if(self)
    {
        [self prepareDimmingView];
    }
    
    return self;
}

- (void)presentationTransitionWillBegin
{
    UIView* containerView = [self containerView];
    UIViewController* presentedViewController = [self presentedViewController];
    [dimmingView setFrame:[containerView bounds]];
    [dimmingView setAlpha:0.0];
    
    [containerView insertSubview:dimmingView atIndex:0];
    
    if([presentedViewController transitionCoordinator])
    {
        [[presentedViewController transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [dimmingView setAlpha:1.0];
        } completion:nil];
    }
    else
    {
        [dimmingView setAlpha:1.0];
    }
}

- (void)dismissalTransitionWillBegin
{
    if([[self presentedViewController] transitionCoordinator])
    {
        [[[self presentedViewController] transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [dimmingView setAlpha:0.0];
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [self.dimmingView removeFromSuperview];
        }];
    }
    else
    {
        [dimmingView setAlpha:0.0];
    }
}

//- (void)presentationTransitionDidEnd:(BOOL)completed {
//    // Remove the dimming view if the presentation was aborted.
//    if (!completed) {
//        [self.dimmingView removeFromSuperview];
//    }
//}
//
//
//- (void)dismissalTransitionDidEnd:(BOOL)completed
//{
//    if (completed)
//    {
//        [self.dimmingView removeFromSuperview];
//    }
//}

- (CGRect)frameOfPresentedViewInContainerView
{

//    return CGRectMake(0.0, 0.0, 200.0, 200.0);
    return CGRectInset(self.containerView.bounds, 30, 125);
//    CGRect presentedViewFrame = CGRectZero;
//    CGRect containerBounds = [[self containerView] bounds];
//    
//    presentedViewFrame.size = [self sizeForChildContentContainer:(UIViewController<UIContentContainer> *)[self presentedViewController]
//                                         withParentContainerSize:containerBounds.size];
//    
//    presentedViewFrame.origin.x = containerBounds.size.width - presentedViewFrame.size.width;
//    
//    return presentedViewFrame;
    
}

- (void)containerViewWillLayoutSubviews
{
    self.dimmingView.frame = self.containerView.bounds;
    self.presentedView.frame = self.frameOfPresentedViewInContainerView;
}

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//    
//    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
//        self.dimmingView.frame = self.containerView.bounds;
//    } completion:nil];
//}


@synthesize dimmingView;

- (void)prepareDimmingView
{
    dimmingView = [[UIView alloc] init];
    [dimmingView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    [dimmingView setAlpha:0.0];
}

@end
