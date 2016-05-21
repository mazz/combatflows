//
//  MAZTableViewCell.h
//  AutoLayoutAnimation
//
//  Created by Michael Hanna on 2014-06-09.
//

#import <UIKit/UIKit.h>
#import "UIView+FLKAutoLayout.h"
#import "M13ProgressViewBar.h"

//NS_ENUM(NSUInteger, MAZTableViewCellInsetState) {
//    kMAZTableViewCellInsetStateOutset,
//    kMAZTableViewCellInsetStateInset
//};

@interface SCRMasterTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *bodyLabel;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) M13ProgressViewBar *progressBar;
@property BOOL isLocked;
//@property (readonly) BOOL inset;
//@property BOOL willDoToggle;
@end
