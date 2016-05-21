//
//  SCRGraphicGuideCardInfoTableViewCell.h
//  scrappling
//
//  Created by Michael Hanna on 2015-07-01.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCRGraphicGuideCardInfoTableViewCell : UITableViewCell
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UILabel *instructionLabel;
@property (strong, nonatomic) NSArray *instructions;
@end
