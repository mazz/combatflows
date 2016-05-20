//
//  UIView+AutoLayout.m
//  scrappling
//
//  Created by Michael Hanna on 2014-08-28.
//  Copyright (c) 2014 ils. All rights reserved.
//

#import "UIView+AutoLayout.h"

@implementation UIView (AutoLayout)
#pragma mark Factory & Initializer Methods

// Creates and returns a new view that does not convert the autoresizing mask into constraints.
+ (instancetype)newAutoLayoutView
{
    UIView *view = [self new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

// Initializes and returns a new view that does not convert the autoresizing mask into constraints.
- (instancetype)initForAutoLayout
{
    self = [self init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

@end
