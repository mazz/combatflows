//
//  SCRMultilineTableViewCell.h
//  scrappling
//
//  Created by Michael Hanna on 2015-06-28.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCRMultilineTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *bodyLabel;
@property (strong, nonatomic) NSArray *topMarginConstraints;
@property (nonatomic) BOOL hasTopMargin;
@end
