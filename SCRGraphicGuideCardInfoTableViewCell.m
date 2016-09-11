//
//  SCRGraphicGuideCardInfoTableViewCell.m
//  scrappling
//
//  Created by Michael Hanna on 2015-07-01.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCRGraphicGuideCardInfoTableViewCell.h"
#import "UIColor+ILSColor.h"
#import "UIFont+SCRFont.h"
#import "UILabel+AutoLayout.h"
#import "UIView+AutoLayout.h"
#import "UIView+Debug.h"
#import "UIView+FLKAutoLayout.h"
#import "Util.h"

#define FLKPredicate(x) [NSString stringWithFormat:@"%d", x]

@interface SCRGraphicGuideCardInfoTableViewCell ()
@property (nonatomic) NSUInteger currentPageNumber;
@end

@implementation SCRGraphicGuideCardInfoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        int margin = 10;
        //        self.titleLabel = [UILabel new];
        //        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

        self.instructionLabel = [UILabel newAutoLayoutLabel];
        self.instructionLabel.translatesAutoresizingMaskIntoConstraints = NO;

        [self.instructionLabel setFont:[UIFont systemFontOfSize:24.]];
        [self.instructionLabel setNumberOfLines:2];
        self.instructionLabel.textAlignment = NSTextAlignmentCenter;
        //        self.bodyLabel.alpha = 0.;
        //        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.instructionLabel];
        [self.instructionLabel alignTop:FLKPredicate(margin) leading:FLKPredicate(margin) toView:self.contentView];
        [self.instructionLabel alignTrailingEdgeWithView:self.contentView predicate:FLKPredicate(-margin)];

        self.pageControl = [UIPageControl newAutoLayoutView];
        self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.pageControl];

        //        [self.pageControl alignLeading:FLKPredicate(10) trailing:FLKPredicate(-margin) toView:self.contentView];
        [self.pageControl alignCenterXWithView:self.contentView predicate:FLKPredicate(0)];
        [self.pageControl constrainTopSpaceToView:self.instructionLabel predicate:FLKPredicate(0)];
        [self.pageControl alignBottomEdgeWithView:self.contentView predicate:FLKPredicate(0)];

        self.pageControl.currentPage = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePageControl:) name:@"EBCardCollectionViewLayoutNewPageNotification" object:nil];
        //        [self.titleLabel alignTopEdgeWithView:self.contentView predicate:FLKPredicate(margin)];
        //        [self.titleLabel alignLeadingEdgeWithView:self.contentView predicate:FLKPredicate(margin)];
        //        [self.titleLabel alignTrailingEdgeWithView:self.contentView predicate:FLKPredicate(-margin)];

        //        [self.bodyLabel constrainTopSpaceToView:self.titleLabel predicate:FLKPredicate(margin)];

        //        @[
        //          @{@"title": [self.lorem words:arc4random() % 4 + 1], @"body": [self.lorem words:arc4random() % 20 + 5]},
        //          @{@"title": [self.lorem words:arc4random() % 4 + 1], @"body": [self.lorem words:arc4random() % 20 + 3]},
        //          @{@"title": [self.lorem words:arc4random() % 4 + 1], @"body": [self.lorem words:arc4random() % 20 + 0]},
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

static dispatch_once_t isAnimating;

- (void)updatePageControl:(NSNotification*)note
{
    NSInteger newPageNumber = [[[note userInfo] objectForKey:@"newPage"] integerValue];

    if (newPageNumber != self.currentPageNumber) {
        dispatch_once(&isAnimating, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.pageControl setCurrentPage:newPageNumber];
                DDLogDebug(@"newPageNumber: %ld", (long)newPageNumber);
                //        CATransition *animation = [CATransition animation];
                //        animation.duration = .5;
                //        animation.type = kCATransitionFade;
                //        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                //        [self.instructionLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
                //
                //        // Change the text
                //        self.instructionLabel.text = self.instructions[newPageNumber];

                [UIView transitionWithView:self.instructionLabel
                    duration:0.3
                    options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{

                        self.instructionLabel.text = self.instructions[newPageNumber];

                    }
                    completion:^(BOOL finished) {
                        isAnimating = NO;
                    }];

            });
            self.currentPageNumber = newPageNumber;
        });
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //    [UIView colorViewsRandomly:self.contentView];
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];

    self.instructionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.instructionLabel.frame);
}
@end
