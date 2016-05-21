//
//  MAZTableViewCell.h
//  AutoLayoutAnimation
//
//  Created by Michael Hanna on 2014-06-09.
//

#import <UIKit/UIKit.h>
#import "UIView+FLKAutoLayout.h"

@interface SCRTitleBodyTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *bodyLabel;
@property (strong, nonatomic) UIButton *button;
@end
