//
//  SCRMasterCollectionViewController.h
//  scrappling
//
//  Created by Michael Hanna on 2015-05-28.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRFavoritesViewController.h"
#import "SCRTrainingItem.h"

@protocol SCRFavoritesDelegate <NSObject>
- (void)favoriteWasRemoved;//:(SCRTrainingItem *)favorite;
@end

@interface SCRFavoritesCollectionViewController : UICollectionViewController
@property (nonatomic, weak) id<SCRFavoritesDelegate> delegate;
- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout;
@end
