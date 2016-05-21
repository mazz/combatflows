//
//  SCRTitleBodyTableViewCell.m
//  AutoLayoutAnimation
//
//  Created by Michael Hanna on 2014-06-09.
//

#import "SCRTitleBodyTableViewCell.h"
#import "UIView+Debug.h"
#import "UIView+AutoLayout.h"

#define FLKPredicate(x) [NSString stringWithFormat:@"%d", x]

@interface SCRTitleBodyTableViewCell ()
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIView *labelBox;
@end

@implementation SCRTitleBodyTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        int margin = 10;
        int interLabelMargin = 5;
        
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(0., 0., 53., 53.)];
        self.labelBox = [UIView newAutoLayoutView];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.textColor = UIColor.whiteColor;
        
        self.bodyLabel = [UILabel new];
        self.bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.bodyLabel setFont:[UIFont systemFontOfSize:24.]];
        [self.bodyLabel setNumberOfLines:0];
        self.bodyLabel.textColor = UIColor.whiteColor;
        
//        self.bodyLabel.alpha = 0.;
        [self.contentView addSubview:self.button];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.bodyLabel];
        [self.contentView addSubview:self.labelBox];
        
//        [self.button alignTop:FLKPredicate(5) leading:FLKPredicate(5) toView:self.contentView];

        [self.button alignCenterYWithView:self.contentView predicate:FLKPredicate(0)];
        [self.button alignLeadingEdgeWithView:self.contentView predicate:FLKPredicate(margin)];
        [self.button setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.button setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        

        [self.labelBox constrainLeadingSpaceToView:self.button predicate:FLKPredicate(10)];
        [self.labelBox alignTrailingEdgeWithView:self.contentView predicate:FLKPredicate(-margin)];

        [self.titleLabel alignTop:FLKPredicate(0) leading:FLKPredicate(0) toView:self.labelBox];
        [self.titleLabel alignTrailingEdgeWithView:self.labelBox predicate:FLKPredicate(0)];

        [self.bodyLabel alignLeadingEdgeWithView:self.labelBox predicate:FLKPredicate(0)];
        [self.bodyLabel constrainTopSpaceToView:self.titleLabel predicate:FLKPredicate(0)];
        [self.bodyLabel alignTrailingEdgeWithView:self.labelBox predicate:FLKPredicate(0)];
        [self.bodyLabel alignBottomEdgeWithView:self.labelBox predicate:FLKPredicate(0)];

        [self.labelBox alignCenterYWithView:self.contentView predicate:FLKPredicate(0)];
        
        self.contentView.backgroundColor = UIColor.blackColor;//[UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0];
        
        //        [self.titleLabel alignTopEdgeWithView:self.contentView predicate:FLKPredicate(margin)];
//        [self.titleLabel alignLeadingEdgeWithView:self.contentView predicate:FLKPredicate(margin)];
//        [self.titleLabel alignTrailingEdgeWithView:self.contentView predicate:FLKPredicate(-margin)];
        
//        [self.bodyLabel constrainTopSpaceToView:self.titleLabel predicate:FLKPredicate(interLabelMargin)];
////        self.topMarginConstraints = [self.bodyLabel alignTopEdgeWithView:self.contentView predicate:FLKPredicate(margin)];
//        [self.bodyLabel alignLeadingEdgeWithView:self.contentView predicate:FLKPredicate(margin)];
//        [self.bodyLabel alignTrailingEdgeWithView:self.contentView predicate:FLKPredicate(-margin)];
//        [self.bodyLabel alignBottomEdgeWithView:self.contentView predicate:FLKPredicate(-margin)];
    }
    return self;
}

//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    
////    CGContextSetRGBStrokeColor(ctx, 1.0f, 1.0f, 1.0f, 1.0f);
//    CGContextSetRGBStrokeColor(ctx, 0.2, 0.2, 0.2, 1.0);
//    CGContextSetLineWidth(ctx, 1.0);
//    
////    CGContextMoveToPoint(ctx, 0, self.bounds.size.height);
//    // left vertical stroke
//    CGContextMoveToPoint(ctx, self.bounds.size.width, 0.0);
////    CGContextMoveToPoint(ctx, 0, 10.0);
//    CGContextAddLineToPoint(ctx, 0.0, 0.0);
//    CGContextSetLineWidth(ctx, 4.5);
//
////    CGContextStrokePath(ctx);
//
//    // top horizontal line
//    CGContextAddLineToPoint(ctx, 0.0, self.bounds.size.height);
//    
//    CGContextSetLineWidth(ctx, 1.0);
////    CGContextMoveToPoint(ctx, self.bounds.size.width, 1.0);
////    CGContextMoveToPoint(ctx, self.bounds.size.width-30, 1.0);
//    CGContextAddLineToPoint(ctx, self.bounds.size.width, self.bounds.size.height);
//    CGContextAddLineToPoint(ctx, self.bounds.size.width, 0.0);
//
//    //    CGContextAddLineToPoint(ctx, self.bounds.size.width - 20, self.bounds.size.height);
//    
//    CGContextStrokePath(ctx);
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];

    self.bodyLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bodyLabel.frame);

//    [UIView colorViewsRandomly:self.contentView];
}


@end
