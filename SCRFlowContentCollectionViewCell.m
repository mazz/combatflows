//
//  SCRGraphicGuideCollectionViewCell.m
//  scrappling
//
//  Created by Michael Hanna on 2015-06-27.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCRFlowContentCollectionViewCell.h"
#import "UIView+FLKAutoLayout.h"
#import "UIView+AutoLayout.h"
#import "UILabel+AutoLayout.h"
#import "UIView+Debug.h"
#import "UIFont+SCRFont.h"
#import "UIColor+ILSColor.h"

#define FLKPredicate(x) [NSString stringWithFormat:@"%d", x]

@interface SCRFlowContentCollectionViewCell ()
@property (strong, nonatomic) UIView *mainImageBox;
@end

@implementation SCRFlowContentCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame //previewItem:(SCRPreviewItem *)item
{
    if ((self = [super initWithFrame:frame]))
    {
//        self.priceFormatter = [NSNumberFormatter new];
//        [self.priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
//        [self.priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//        
//        self.titleBox = [UIView newAutoLayoutView];
//        [self.contentView addSubview:self.titleBox];
//        
//        [self.titleBox alignLeadingEdgeWithView:self.contentView predicate:nil];
//        [self.titleBox alignTrailingEdgeWithView:self.contentView predicate:nil];
//        [self.titleBox alignTopEdgeWithView:self.contentView predicate:nil];
//        [self.titleBox constrainHeightToView:self.contentView predicate:@"*0.30"];
//        
//        self.centredTitleBox = [UIView newAutoLayoutView];
//        [self.titleBox addSubview:self.centredTitleBox];
//        [self.centredTitleBox constrainHeightToView:self.titleBox predicate:@"*1.0"];
//        [self.centredTitleBox constrainWidth:@"275"];
//        [self.centredTitleBox alignCenterWithView:self.titleBox];
//        
//        self.stickerBox = [UIView newAutoLayoutView];
//        [self.centredTitleBox addSubview:self.stickerBox];
//        [self.stickerBox alignTopEdgeWithView:self.centredTitleBox predicate:@"0"];
//        [self.stickerBox constrainWidth:@"80"];
//        [self.stickerBox constrainHeightToView:self.centredTitleBox predicate:@"0"];
//        [self.stickerBox alignLeadingEdgeWithView:self.centredTitleBox predicate:@"0"];
//        [self.stickerBox alignCenterYWithView:self.centredTitleBox predicate:@"0"];
//        
//        self.infoBox = [UIView newAutoLayoutView];
//        [self.centredTitleBox addSubview:self.infoBox];
//        [self.infoBox constrainLeadingSpaceToView:self.stickerBox predicate:@"5"];
//        [self.infoBox alignTopEdgeWithView:self.centredTitleBox predicate:@"0"];
//        [self.infoBox alignTrailingEdgeWithView:self.centredTitleBox predicate:@"0"];
//        [self.infoBox alignBottomEdgeWithView:self.centredTitleBox predicate:@"0"];
//        
//        self.compressedLabelBox = [UIView newAutoLayoutView];
//        [self.infoBox addSubview:self.compressedLabelBox];
//        [self.compressedLabelBox alignLeading:@"0" trailing:@"0" toView:self.infoBox];
//        [self.compressedLabelBox alignCenterYWithView:self.infoBox predicate:@"0"];
        
        self.mainImageBox = [UIView newAutoLayoutView];
        [self.contentView addSubview:self.mainImageBox];
        [self.mainImageBox alignTop:FLKPredicate(0) leading:FLKPredicate(10) toView:self.contentView];
        [self.mainImageBox alignTrailingEdgeWithView:self.contentView predicate:FLKPredicate(-10)];
        [self.mainImageBox alignBottomEdgeWithView:self.contentView predicate:FLKPredicate(0)];

//        [self.mainImageBox alignToView:self.contentView];
        
//        
//        
//        self.mainImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bogus-gg-image"]];
//        self.mainImageView.translatesAutoresizingMaskIntoConstraints = NO;

        
        

        self.mainImageView = [[UIImageView alloc] init];
        self.mainImageView.translatesAutoresizingMaskIntoConstraints = NO;
//
        [self.mainImageBox addSubview:self.mainImageView];
//
//        [self.mainImageView alignCenterWithView:self.mainImageBox];
//        //        [self.stickerView setFrame:CGRectMake(0.0, 0.0, self.stickerBox.frame.size.width, self.stickerBox.frame.size.width)];
        [self.mainImageView setFrame:CGRectMake(0.0, 0.0, self.mainImageBox.frame.size.width, self.mainImageBox.frame.size.width)];
//        [self.mainImageView setFrame:CGRectMake(0.0, 0.0, 80.0, 60.0)];
        self.mainImageView.center = self.mainImageView.superview.center;
        self.mainImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.mainImageView setImage:[UIImage imageNamed:@"bogus-gg-image"]];
        [self.mainImageView alignCenterWithView:self.mainImageBox];
//        [UIView colorViewsRandomly:self.mainImageBox];

        
        [self.contentView setBackgroundColor:UIColor.clearColor];
        [self.mainImageBox setBackgroundColor:UIColor.clearColor];
        
//        [self.mainImageView alignTop:FLKPredicate(10) leading:FLKPredicate(10) toView:self.contentView];
//        [self.mainImageView alignTrailingEdgeWithView:self.contentView predicate:FLKPredicate(-10)];
//        [self.mainImageView constrainWidth:@"320" height:@"200"];
        
        self.instructionLabel = [UILabel newAutoLayoutLabel];
        self.instructionLabel.numberOfLines = 0;
        //        self.mainTitle.text = [self.previewItem.product.localizedTitle uppercaseString];
        self.instructionLabel.font = [UIFont productCellTitleFont];
//        self.instructionLabel.textColor = [UIColor colorWithWhite:1. alpha:1.];
        
        [self.contentView addSubview:self.instructionLabel];
        
//        [self.instructionLabel alignLeading:FLKPredicate(10) trailing:FLKPredicate(-10) toView:self.contentView];
        [self.instructionLabel alignTopEdgeWithView:self.contentView predicate:FLKPredicate(10)];

//        [self.instructionLabel constrainWidth:FLKPredicate((int)self.contentView.frame.size.width) height:FLKPredicate(200)];
        
//        [self.instructionLabel constrainTopSpaceToView:self.mainImageBox predicate:FLKPredicate(10)];
//        [self.instructionLabel alignBottomEdgeWithView:self.contentView predicate:FLKPredicate(-10)];
        
        
//        self.instructionLabel.text = @"foo";
//        [self.mainTitle alignTrailingEdgeWithView:self.compressedLabelBox predicate:@"-5"];
        
//        self.subtitleLabel = [UILabel newAutoLayoutLabel];
//        //        self.subtitleLabel.text = self.previewItem.product.localizedDescription;
//        self.subtitleLabel.font = [UIFont productCellSubtitleFont];
//        self.subtitleLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
//        [self.compressedLabelBox addSubview:self.subtitleLabel];
//        [self.subtitleLabel alignLeading:@"5" trailing:@"-5" toView:self.compressedLabelBox];
//        [self.subtitleLabel constrainTopSpaceToView:self.titleLabel predicate:@"0"];
//        
//        self.buyButton = [[UIButton alloc] init];
//        self.buyButton.backgroundColor = (self.purchased)?[UIColor purchasedColor]:[UIColor buyColor];
//        self.buyButton.translatesAutoresizingMaskIntoConstraints = NO;
//        self.buyButton.layer.cornerRadius = 4.0;
//        self.buyButton.layer.masksToBounds = YES;
        
        
        //        [self.buyButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"", @"") attributes:@{NSForegroundColorAttributeName: UIColor.whiteColor, NSFontAttributeName: [UIFont productCellBuyMeFont]}] forState:UIControlStateNormal];
//        [self.compressedLabelBox addSubview:self.buyButton];
//        
//        [self.buyButton alignLeadingEdgeWithView:self.compressedLabelBox predicate:@"5"];
//        [self.buyButton constrainTopSpaceToView:self.subtitleLabel predicate:@"3"];
//        [self.buyButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//        [self.buyButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//        [self.buyButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
//        [self.buyButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
//        [self.buyButton alignBottomEdgeWithView:self.compressedLabelBox predicate:@"-3"];
        
        //        self.buyLabel = [UILabel newAutoLayoutLabel];
        //        [self.compressedLabelBox addSubview:self.buyLabel];
        //        self.buyLabel.textColor = [UIColor whiteColor];
        //        self.buyLabel.font = [UIFont productCellBuyMeFont];
        //        [self.buyLabel alignLeadingEdgeWithView:self.compressedLabelBox predicate:@"5"];
        //        [self.buyLabel constrainTopSpaceToView:self.subtitleLabel predicate:@"3"];
        //        [self.buyLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        //        [self.buyLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        //        [self.buyLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        //        [self.buyLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        //
        //        [self.buyLabel alignBottomEdgeWithView:self.compressedLabelBox predicate:@"-3"];
        
        // buy me green
        //        self.buyLabel.backgroundColor = [UIColor buyColor];
        
        // purchased blue
        //        self.buyLabel.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:171.0/255.0 blue:251.0/255.0 alpha:1.0];
        
        //        self.buyLabel.backgroundColor = UIColor.greenColor;
        //        self.buyLabel.layer.cornerRadius = 4;
        //        self.buyLabel.layer.masksToBounds = YES;
        
//        self.stickerView = [[UIImageView alloc] init];
//        self.stickerView.translatesAutoresizingMaskIntoConstraints = NO;
//        [self.stickerBox addSubview:self.stickerView];
//        
//        [self.stickerView alignCenterWithView:self.stickerBox];
//        //        [self.stickerView setFrame:CGRectMake(0.0, 0.0, self.stickerBox.frame.size.width, self.stickerBox.frame.size.width)];
//        [self.stickerView setFrame:CGRectMake(0.0, 0.0, self.stickerBox.frame.size.width, self.stickerBox.frame.size.width)];
//        self.stickerView.center = self.stickerView.superview.center;
//        self.stickerView.contentMode = UIViewContentModeScaleToFill;
//        
//        self.thumbBox = [UIView newAutoLayoutView];
//        [self.contentView addSubview:self.thumbBox];
//        
//        [self.thumbBox alignLeadingEdgeWithView:self.contentView predicate:@"0"];
//        [self.thumbBox alignTrailingEdgeWithView:self.contentView predicate:@"0"];
//        [self.thumbBox alignBottomEdgeWithView:self.contentView predicate:@"0"];
//        [self.thumbBox constrainHeightToView:self.contentView predicate:@"*0.70"];
//        
//        self.thumbView = [[SCRThumbnailLoopView alloc] initWithFrame:CGRectMake(0.0, 0.0, 145.0, 145.0)];
//        [self.thumbBox addSubview:self.thumbView];
//        
//        [self.thumbView constrainWidth:@"145" height:@"145"];
//        [self.thumbView alignCenterWithView:self.thumbBox];
//        
//        [[self.thumbView layer] setCornerRadius:9.0];
//        [[self.thumbView layer] setMasksToBounds:YES];
//        
//        [[self.thumbView layer] setBorderColor:[[UIColor scrapplingForegroundBlueColor] CGColor]];
//        [[self.thumbView layer] setBackgroundColor:[[UIColor blackColor] CGColor]];
//        [[self.thumbView layer] setBorderWidth:2.0];
    }
    return self;
}
//-(void)updateConstraints
//{
//    [super updateConstraints];
//
//
//}

-(void)layoutSubviews
{
    [super layoutSubviews];
//    self.buyButton.backgroundColor = (self.purchased)?[UIColor purchasedColor]:[UIColor buyColor];
//    [UIView colorViewsRandomly:self.contentView];
}

@end
