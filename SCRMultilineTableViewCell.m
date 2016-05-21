//
//  SCRMultilineTableViewCell.m
//  scrappling
//
//  Created by Michael Hanna on 2015-06-28.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCRMultilineTableViewCell.h"
#import "UIView+AutoLayout.h"
#import "UILabel+AutoLayout.h"
#import "UIView+FLKAutoLayout.h"
#import "UIView+Debug.h"
#import "UIColor+ILSColor.h"
#import "UIFont+SCRFont.h"

#define FLKPredicate(x) [NSString stringWithFormat:@"%d", x]

@implementation SCRMultilineTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
     
        self.bodyLabel = [UILabel newAutoLayoutLabel];
        self.bodyLabel.numberOfLines = 0;
        
        [self.contentView addSubview:self.bodyLabel];
//        [self.contentView alignTop:FLKPredicate(10) leading:FLKPredicate(10) bottom:FLKPredicate(-10) trailing:FLKPredicate(-10) toView:self.contentView];
        self.topMarginConstraints = @[[self.bodyLabel alignTopEdgeWithView:self.contentView predicate:FLKPredicate(10)]];
        [self.bodyLabel alignLeading:FLKPredicate(10) trailing:FLKPredicate(-10) toView:self.contentView];
        [self.bodyLabel alignBottomEdgeWithView:self.contentView predicate:FLKPredicate(-10)];
//        [UIView alignBottomEdgesOfViews:@[self.contentView, self.bodyLabel]];
        
    }
    return self;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    //    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}
//
//- (void)updateConstraints
//{
//    [super updateConstraints];
//    if (self.didSetupConstraints)
//    {
//        return;
//    }
//
//
//    self.didSetupConstraints = YES;
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [UIView colorViewsRandomly:self.contentView];
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    self.bodyLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bodyLabel.frame);
    //    self.titleLabel.font = [UIFont productCellTitleFont];
    //    self.titleLabel.textColor = [UIColor colorWithWhite:1. alpha:1.];
    //    self.bodyLabel.textColor = [UIColor colorWithWhite:.5 alpha:1.];
    //    self.priceLabel.textColor = [UIColor scrapplingForegroundBlueColor];
    
    //    [self contentView].backgroundColor = [UIColor colorWithRed:39./255. green:56./255. blue:67./255. alpha:1];
    
}
@end




