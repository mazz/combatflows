//
//  UIView+AutoLayout.h
//  scrappling
//
//  Created by Michael Hanna on 2014-08-28.
//  Copyright (c) 2014 ils. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AutoLayout)
// Creates and returns a new view that does not convert the autoresizing mask into constraints.
+ (instancetype)newAutoLayoutView;

// Initializes and returns a new view that does not convert the autoresizing mask into constraints.
- (instancetype)initForAutoLayout;

@end
