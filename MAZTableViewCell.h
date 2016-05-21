//
//  MAZTableViewCell.h
//  AutoLayoutAnimation
//
//  Created by Michael Hanna on 2014-06-09.
//

#import <UIKit/UIKit.h>
#import "UIView+FLKAutoLayout.h"


@interface MAZTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *bodyLabel;
@property (strong, nonatomic) NSArray *topMarginConstraints;
@property (strong, nonatomic) NSArray *bottomMarginConstraints;
@end
