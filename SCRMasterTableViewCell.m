//
//  MAZTableViewCell.m
//  AutoLayoutAnimation
//
//  Created by Michael Hanna on 2014-06-09.
//

#import "SCRMasterTableViewCell.h"
#import "UIView+AutoLayout.h"
#import "UILabel+AutoLayout.h"
#import "UIView+Debug.h"
#import "UIColor+ILSColor.h"
#import "UIFont+SCRFont.h"

NSString *const kMasterLabelHorizontalOutset          = @"6";
NSString *const kLabelHorizontalInset           = @"70";
NSString *const kTopMargin                      = @"6";
NSString *const kLabelVerticalGap               = @"0";

#define kLabelBottomAndTrailingInsets [NSString stringWithFormat:@"-%@", kTopMargin]

@interface SCRMasterTableViewCell ()
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIView *labelBox;
@property (nonatomic, strong) UIImageView *lockImageView;
@property (nonatomic, strong) NSArray *trailingPriceConstraints;
//@property BOOL inset;
//@property (nonatomic, strong) NSArray *constraintsToAnimate;
@end

@implementation SCRMasterTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(0., 0., 53., 53.)];
        [self.contentView addSubview:self.button];
        
        self.labelBox = [UIView newAutoLayoutView];
        [self.contentView addSubview:self.labelBox];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.titleLabel setNumberOfLines:0];

//        self.titleLabel.alpha = 0.;
        self.bodyLabel = [UILabel new];
        self.bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
//        [self.bodyLabel setFont:[UIFont preferredFontForDefaultTextStyleWithWeight:PPFontWeightTypeBold]];
        [self.bodyLabel setFont:[UIFont productCellSubtitleFont]];
        [self.bodyLabel setNumberOfLines:0];
//        self.bodyLabel.alpha = 0.;
        [self.contentView addSubview:self.titleLabel];
        
//        [self.titleLabel alignTop:kLabelVerticalInsets leading:kLabelHorizontalOutset toView:self.contentView];
//        [self.titleLabel alignTrailingEdgeWithView:self.contentView predicate:kLabelBottomAndTrailingInsets];
        
        [self.contentView addSubview:self.bodyLabel];
        
        self.priceLabel = [UILabel newAutoLayoutLabel];
        self.priceLabel.textAlignment = NSTextAlignmentRight;
        [self.priceLabel setFont:[UIFont italicSystemFontOfSize:11.]];
        [self.contentView addSubview:self.priceLabel];
        
        self.lockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tn_lock_icon"]];
        self.lockImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.lockImageView];
        self.lockImageView.hidden = YES;
        
        self.progressBar = [[M13ProgressViewBar alloc] init];
        self.progressBar.translatesAutoresizingMaskIntoConstraints = NO;
        self.progressBar.progressBarThickness = 2.5;
        self.progressBar.indeterminate = NO;
        self.progressBar.showPercentage = NO;
        self.progressBar.hidden = YES;
        [self.contentView addSubview:self.progressBar];
        [self.progressBar alignLeading:@"0" trailing:@"0" toView:self.contentView];
        [self.progressBar alignBottomEdgeWithView:self.contentView predicate:@"0"];
        

        [self.button alignTop:kTopMargin leading:kMasterLabelHorizontalOutset toView:self.contentView];
        [self.button setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
        [self.button setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        //    [self.labelBox alignTopEdgeWithView:self.contentView predicate:kTopMargin];
        [self.labelBox constrainLeadingSpaceToView:self.button predicate:@"10"];
        [self.labelBox alignTrailingEdgeWithView:self.contentView predicate:kLabelBottomAndTrailingInsets];
        
        [self.titleLabel alignTop:@"0" leading:@"0" toView:self.labelBox];
        [self.titleLabel alignTrailingEdgeWithView:self.labelBox predicate:@"0"];
        
        [self.bodyLabel alignLeadingEdgeWithView:self.labelBox predicate:@"0"];
        [self.bodyLabel constrainTopSpaceToView:self.titleLabel predicate:kLabelVerticalGap];
        [self.bodyLabel alignTrailingEdgeWithView:self.labelBox predicate:@"0"];
        [self.bodyLabel alignBottomEdgeWithView:self.labelBox predicate:@"0"];
        
        [self.labelBox alignCenterYWithView:self.contentView predicate:@"0"];
        
        [self.priceLabel alignBottomEdgeWithView:self.contentView predicate:kLabelBottomAndTrailingInsets];
        [self.priceLabel constrainLeadingSpaceToView:self.button predicate:@">=10"];
        self.trailingPriceConstraints = @[[self.priceLabel alignTrailingEdgeWithView:self.contentView predicate:kLabelBottomAndTrailingInsets]];
        
        [self.priceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.priceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
        [self.priceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.priceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
        if (self.isLocked)
        {
            [self.lockImageView alignBottomEdgeWithView:self.priceLabel predicate:@"-25"];
            [self.lockImageView constrainLeadingSpaceToView:self.button predicate:@">=10"];
            [self.lockImageView alignTrailingEdgeWithView:self.contentView predicate:@"0"];
            self.lockImageView.hidden = NO;
        }
        //    [self.titleLabel constrainLeadingSpaceToView:self.button predicate:@"14"];
        
        //    [self.titleLabel alignLeadingEdgeWithView:self.contentView predicate:kLabelHorizontalOutset];
        //    [self.titleLabel alignTrailingEdgeWithView:self.contentView predicate:kLabelBottomAndTrailingInsets];
        
        //    [self.bodyLabel alignLeadingEdgeWithView:self.contentView predicate:kLabelHorizontalOutset];
        //    [self.bodyLabel constrainLeadingSpaceToView:self.button predicate:@"14"];
        //    [self.bodyLabel alignTrailingEdgeWithView:self.contentView predicate:kLabelBottomAndTrailingInsets];
        
        //    [self.bodyLabel alignBottomEdgeWithView:self.contentView predicate:kLabelBottomAndTrailingInsets];
        
        [self.button alignBottomEdgeWithView:self.contentView predicate:kLabelBottomAndTrailingInsets];

//        [self.bodyLabel constrainTopSpaceToView:self.titleLabel predicate:kLabelVerticalInsets];
//        [self.bodyLabel alignLeading:kLabelHorizontalOutset trailing:kLabelBottomAndTrailingInsets toView:self.contentView];
//        [self.bodyLabel alignBottomEdgeWithView:self.contentView predicate:kLabelBottomAndTrailingInsets];
        
    
        // collect constraints that have a leading attribute because that's what we'll animate later
//        self.constraintsToAnimate = [[self setWithConstraintAttributes:NSLayoutAttributeLeading] allObjects];
    }
    return self;
}

- (NSMutableSet *)setWithConstraintAttributes:(NSLayoutAttribute)attribute
{
    NSMutableSet *set = [NSMutableSet set];

    for (NSLayoutConstraint *constraint in self.contentView.constraints) {
        if ([constraint firstAttribute] == attribute) {
            [set addObject:constraint];
            DDLogDebug(@"constraint item: %@, %@", [constraint firstItem], [constraint secondItem]);
        }
    }
    DDLogDebug(@"set: %@", set);
    return set;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateConstraints
{
    [super updateConstraints];
    if (self.didSetupConstraints)
    {
        return;
    }
    
    
    self.didSetupConstraints = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];

    self.bodyLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bodyLabel.frame);
    self.titleLabel.font = [UIFont productCellTitleFont];
    self.titleLabel.textColor = [UIColor colorWithWhite:1. alpha:1.];
    self.bodyLabel.textColor = [UIColor colorWithWhite:.5 alpha:1.];
    self.priceLabel.textColor = [UIColor scrapplingForegroundBlueColor];

//    [self contentView].backgroundColor = [UIColor colorWithRed:39./255. green:56./255. blue:67./255. alpha:1];
  
//    [UIView colorViewsRandomly:self.contentView];
}


@end
