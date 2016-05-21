//
//  SCRHorizontalCardTableViewCell.h
//  scrappling
//
//  Created by Michael Hanna on 2015-06-28.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRFlowContentViewController.h"

//@protocol SCRFlowContentParentTableViewDelegate <NSObject>
//@optional
//- (void)reloadTable;
//@end

@interface SCRHorizontalCardTableViewCell : UITableViewCell
//@property (weak, nonatomic) id <SCRFlowContentParentTableViewDelegate> delegate;
@property (nonatomic, strong) UICollectionView *collectionView;
- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;
@end
