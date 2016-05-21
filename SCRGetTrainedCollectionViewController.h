//
//  SCRMasterCollectionViewController.h
//  scrappling
//
//  Created by Michael Hanna on 2015-05-28.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCRGetTrainedCollectionViewController : UICollectionViewController
@property (strong, nonatomic) NSArray *trainingItems;
- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout;
@end
