//
//  UILabel+AutoLayout.m
//  scrappling
//
//  Created by Michael Hanna on 2014-08-28.
//  Copyright (c) 2014 ils. All rights reserved.
//

#import "UILabel+AutoLayout.h"

@implementation UILabel (AutoLayout)
+ (instancetype)newAutoLayoutLabel
{
    UILabel *label = [UILabel new];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentLeft;
    
    return label;
}

- (instancetype)initAutoLayoutLabel
{
    self = [self init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.lineBreakMode = NSLineBreakByTruncatingTail;
        self.numberOfLines = 0;
        self.textAlignment = NSTextAlignmentLeft;
    }
    
    return self;
}
@end
