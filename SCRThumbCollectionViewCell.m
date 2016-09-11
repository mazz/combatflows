//
//  SCRMasterCollectionViewCell.m
//  scrappling
//
//  Created by Michael Hanna on 2015-05-30.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCRThumbCollectionViewCell.h"
#import "UIView+FLKAutoLayout.h"
#import "UIView+AutoLayout.h"
#import "UILabel+AutoLayout.h"
#import "UIView+Debug.h"
#import "UIFont+SCRFont.h"
#import "UIColor+ILSColor.h"
#import "SCRConstants.h"

#define FLKPredicate(x) [NSString stringWithFormat:@"%d", x]
//NSUInteger kThumbSize = 180;

@interface SCRThumbCollectionViewCell()
@property (strong, nonatomic) UIView *thumbBox;
@property (strong, nonatomic) UIView *labelBox;
@property (strong, nonatomic) UIView *getView;
@property (strong, nonatomic) UILabel *getLabel;
@property (strong, nonatomic) NSArray *getViewWidthOnlineConstraints;
@property (strong, nonatomic) NSArray *getViewWidthOfflineConstraints;
@end

@implementation SCRThumbCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame //previewItem:(SCRPreviewItem *)item
{
    if ((self = [super initWithFrame:frame]))
    {
        self.priceFormatter = [NSNumberFormatter new];
        [self.priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [self.priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

        self.thumbBox = [UIView newAutoLayoutView];
        [self.contentView addSubview:self.thumbBox];
        
        [self.thumbBox alignToView:self.contentView];
//        [self.thumbBox setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5]];
        int thumbDimension = ([[SCRConstants sharedInstance] applicationWindow].frame.size.width)/kSCRConstantsThumbDivisor;

        self.thumbView = [[SCRThumbnailLoopView alloc] initWithFrame:CGRectMake(0.0, 0.0, thumbDimension, thumbDimension)];

        [self.thumbBox addSubview:self.thumbView];
        [self.thumbView constrainWidth:FLKPredicate(thumbDimension) height:FLKPredicate(thumbDimension)];
        [self.thumbView alignCenterWithView:self.thumbBox];
//        [[self.thumbView layer] setBorderColor:[[UIColor scrapplingForegroundGreenColor] CGColor]];
//        [[self.thumbView layer] setBorderColor:[[UIColor scrapplingForegroundBlueColor] CGColor]];
        [[self.thumbView layer] setBackgroundColor:[[UIColor blackColor] CGColor]];
        [[self.thumbView layer] setBorderWidth:1.0];
        
        self.labelBox = [UILabel newAutoLayoutView];
        [self.contentView addSubview:self.labelBox];
//        [self.labelBox setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5]];
        [self.labelBox alignLeading:FLKPredicate(0) trailing:FLKPredicate(0) toView:self.contentView];
        [self.labelBox alignBottomEdgeWithView:self.contentView predicate:FLKPredicate(0)];
        [self.labelBox constrainHeightToView:self.contentView predicate:@"*0.35"];

        // ~~~ title and detail label ~~~ //
        
        self.titleLabel = [UILabel newAutoLayoutLabel];
        [self.labelBox addSubview:self.titleLabel];
//        [self.titleLabel setText:@"technocracy"];
        self.titleLabel.numberOfLines = 2;

        self.detailLabel = [UILabel newAutoLayoutLabel];
        [self.labelBox addSubview:self.detailLabel];
//        [self.detailLabel setText:@"detail label here"];
        self.detailLabel.font = [UIFont productCellSubtitleFont];
        self.detailLabel.textColor = [UIColor colorWithWhite:1. alpha:1.];
        self.detailLabel.numberOfLines = 3;
        [self.detailLabel alignLeadingEdgeWithView:self.labelBox predicate:FLKPredicate(2)];
//        [self.detailLabel alignBottomEdgeWithView:self.labelBox predicate:FLKPredicate(-6)];
        [self.detailLabel constrainTopSpaceToView:self.titleLabel predicate:FLKPredicate(2)];
        [self.detailLabel alignTrailingEdgeWithView:self.labelBox predicate:FLKPredicate(-2)];

        //        self.titleLabel.text = [self.previewItem.product.localizedTitle uppercaseString];
        self.titleLabel.font = [UIFont productCellTitleFont];
        self.titleLabel.textColor = [UIColor colorWithWhite:1. alpha:1.];

        [self.titleLabel alignLeading:FLKPredicate(2) trailing:FLKPredicate(0) toView:self.labelBox];

        // ~~~ price label ~~~ //
        
        self.priceLabel = [UILabel newAutoLayoutLabel];
        [self.labelBox addSubview:self.priceLabel];
//        [self.priceLabel setText:@"PURCHASED"];
        self.priceLabel.font = [UIFont productCellSubtitleFont];
        self.priceLabel.textColor = [UIColor colorWithWhite:1. alpha:1.];
//        [self.priceLabel constrainLeadingSpaceToView:self.detailLabel predicate:FLKPredicate(-5)];
        [self.priceLabel alignTrailingEdgeWithView:self.labelBox predicate:FLKPredicate(-2)];
        [self.priceLabel alignBottomEdgeWithView:self.labelBox predicate:FLKPredicate(-2)];
        [self.priceLabel constrainTopSpaceToView:self.detailLabel predicate:FLKPredicate(2)];
        [self.priceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.priceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

//        [self.priceLabel constrainTopSpaceToView:self.titleLabel predicate:FLKPredicate(2)];
        
//        [self.titleLabel alignTopEdgeWithView:self.labelBox predicate:@"0"];

//        [self.titleLabel constrainHeight];

        
        // ~~~~ GET view ~~~ //
        
        self.getView = [UIView newAutoLayoutView];
//        self.getView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
        
        self.getLabel = [UILabel newAutoLayoutLabel];
        [self.getLabel setText:NSLocalizedString(@"GET", @"")];
        self.getLabel.font = [UIFont buttonTitleFont];
        self.getLabel.textColor = [UIColor scrapplingForegroundGreenColor];

        [self.contentView addSubview:self.getView];
        [self.getView alignCenterWithView:self.contentView];
        [self.getView.layer setBorderColor:[[UIColor scrapplingForegroundGreenColor] CGColor]];
        [self.getView.layer setBorderWidth:2.0];
        self.getView.layer.cornerRadius = 3.0;
        self.getView.layer.masksToBounds = YES;
        
        [self.getView setBackgroundColor:[UIColor clearColor]];
        [self.getView addSubview:self.getLabel];
        [self.getView constrainHeight:FLKPredicate(20)];
        
        self.getViewWidthOnlineConstraints = [self generateWidthConstraintsForLabel:5];
        [self.getLabel setText:NSLocalizedString(@"OFFLINE", @"")];
        self.getViewWidthOfflineConstraints = [self generateWidthConstraintsForLabel:30];

        // default to online "GET" text
        [self.getLabel setText:NSLocalizedString(@"GET", @"")];
        // default to the online or, "GET" constraints
        [self.getView addConstraints:self.getViewWidthOnlineConstraints];
        [self.getView addConstraints:self.getViewWidthOfflineConstraints];
        [NSLayoutConstraint deactivateConstraints:self.getViewWidthOfflineConstraints];
        
        [self.getLabel alignCenterWithView:self.getView];
        
        // ~~~ corner button ~~~ //
        
        self.cornerButton = [[UIButton alloc] init];
        self.cornerButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.cornerButton constrainWidth:FLKPredicate(40) height:FLKPredicate(40)];
        [self.contentView addSubview:self.cornerButton];
        [self.cornerButton alignTopEdgeWithView:self.contentView predicate:FLKPredicate(0)];
        [self.cornerButton alignTrailingEdgeWithView:self.contentView predicate:FLKPredicate(0)];
//        [self.cornerButton setTitle:@"foo" forState:UIControlStateNormal];
//        self.cornerButton.backgroundColor = [UIColor scrapplingForegroundGreenColor];
        
        
        // ~~~ progressView ~~~ //
        
        self.progressView = [[M13ProgressViewPie alloc] initForAutoLayout];
        [self.contentView addSubview:self.progressView];
        [self.progressView alignTop:FLKPredicate(25) leading:FLKPredicate(25) bottom:FLKPredicate(-25) trailing:FLKPredicate(-25) toView:self.contentView];
//        self.progressView.progressBarThickness = 2.5;
        self.progressView.indeterminate = NO;
        self.progressView.backgroundRingWidth = 0.0;
        UIColor *scrapplingBlue = UIColor.scrapplingForegroundBlueColor;
        UIColor *scrapplingBlueWithAlpha = [scrapplingBlue colorWithAlphaComponent:0.7];
        self.progressView.primaryColor = scrapplingBlueWithAlpha;
        self.progressView.secondaryColor = scrapplingBlueWithAlpha;
//        self.progressView.showPercentage = NO;
        self.progressView.hidden = YES;

    }
    return self;
}

- (NSArray *)generateWidthConstraintsForLabel:(NSUInteger)baseWidth
{
    NSArray *constraints = nil;
//    NSLayoutConstraint *constraints = nil;
    
    NSUInteger labelWidth = baseWidth + 50;
    constraints = @[[self.getView constrainWidth:FLKPredicate(labelWidth)]];
    [self.getView removeConstraints:constraints];
//    DDLogDebug(@"constraints: %@", constraints);
    
    return constraints;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.getView.hidden = self.purchased;
    
    if (self.productRequestFailed)
    {
        [[self.thumbView layer] setBorderColor:(self.purchased) ? [[UIColor scrapplingForegroundBlueColor] CGColor] : [[UIColor scrapplingForegroundOrangeColor] CGColor]];
        [NSLayoutConstraint deactivateConstraints:self.getViewWidthOnlineConstraints];
        [NSLayoutConstraint activateConstraints:self.getViewWidthOfflineConstraints];
        [self.getView.layer setBorderColor:[[UIColor scrapplingForegroundOrangeColor] CGColor]];
        self.getLabel.textColor = [UIColor scrapplingForegroundOrangeColor];

        self.getLabel.text = NSLocalizedString(@"OFFLINE", @"");
    }
    else
    {
        [[self.thumbView layer] setBorderColor:(self.purchased) ? [[UIColor scrapplingForegroundBlueColor] CGColor] : [[UIColor scrapplingForegroundGreenColor] CGColor]];
        [NSLayoutConstraint deactivateConstraints:self.getViewWidthOfflineConstraints];
        [NSLayoutConstraint activateConstraints:self.getViewWidthOnlineConstraints];
        [self.getView.layer setBorderColor:[[UIColor scrapplingForegroundGreenColor] CGColor]];
        self.getLabel.textColor = [UIColor scrapplingForegroundGreenColor];

        self.getLabel.text = NSLocalizedString(@"GET", @"");
    }
    
    if (self.purchased)
    {
        self.priceLabel.text = NSLocalizedString(@"PURCHASED", @"");
        self.priceLabel.textColor = UIColor.scrapplingForegroundBlueColor;

        [self.cornerButton setBackgroundImage:(self.favorite) ? [UIImage imageNamed:@"icn_unlocked_fav_on"] : [UIImage imageNamed:@"icn_unlocked_fav_off"] forState:UIControlStateNormal];
    }
    else
    {
        [self.cornerButton setBackgroundImage:(self.productRequestFailed) ? [UIImage imageNamed:@"icn_lock_org"] : [UIImage imageNamed:@"icn_lock"] forState:UIControlStateNormal];
    }
//    [UIView colorViewsRandomly:self.contentView];
}

@end
