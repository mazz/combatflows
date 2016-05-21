//
//  SCRMasterCollectionViewCell.h
//  scrappling
//
//  Created by Michael Hanna on 2015-05-30.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRThumbnailLoopView.h"
#import "M13ProgressViewPie.h"

@interface SCRThumbCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) SCRThumbnailLoopView *thumbView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UIButton *cornerButton;
@property (strong, nonatomic) NSNumberFormatter *priceFormatter;
@property (nonatomic) BOOL purchased;
@property (nonatomic) BOOL favorite;
@property (nonatomic) BOOL productRequestFailed; // we could not connect to the App Store to fetch products
//@property (nonatomic) BOOL canBeFavorited;
@property (strong, nonatomic) M13ProgressViewPie *progressView;
@end
