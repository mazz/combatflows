//
//  MAZTableViewCell.m
//  AutoLayoutAnimation
//
//  Created by Michael Hanna on 2014-06-09.
//

#import "MAZTableViewCell.h"
#import "UIView+Debug.h"

#define FLKPredicate(x) [NSString stringWithFormat:@"%d", x]

NS_ENUM(NSUInteger, MAZTableViewCellInsetState) {
    kMAZTableViewCellInsetStateOutset,
    kMAZTableViewCellInsetStateInset
};

@interface MAZTableViewCell ()
@property (nonatomic, assign) BOOL didSetupConstraints;
@end

@implementation MAZTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        int margin = 10;
//        self.titleLabel = [UILabel new];
//        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.bodyLabel = [UILabel new];
        self.bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.bodyLabel setFont:[UIFont systemFontOfSize:24.]];
        [self.bodyLabel setNumberOfLines:0];
        
//        self.bodyLabel.alpha = 0.;
//        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.bodyLabel];
//        [self.titleLabel alignTopEdgeWithView:self.contentView predicate:FLKPredicate(margin)];
//        [self.titleLabel alignLeadingEdgeWithView:self.contentView predicate:FLKPredicate(margin)];
//        [self.titleLabel alignTrailingEdgeWithView:self.contentView predicate:FLKPredicate(-margin)];
        
//        [self.bodyLabel constrainTopSpaceToView:self.titleLabel predicate:FLKPredicate(margin)];
        self.topMarginConstraints = @[[self.bodyLabel alignTopEdgeWithView:self.contentView predicate:FLKPredicate(margin)]];
        [self.bodyLabel alignLeadingEdgeWithView:self.contentView predicate:FLKPredicate(margin)];
        [self.bodyLabel alignTrailingEdgeWithView:self.contentView predicate:FLKPredicate(-margin)];
        self.bottomMarginConstraints = @[[self.bodyLabel alignBottomEdgeWithView:self.contentView predicate:FLKPredicate(-margin)]];
//        self.contentView.backgroundColor = UIColor.clearColor;
    }
    return self;
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
