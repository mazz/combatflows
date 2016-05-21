//
//  SCRHorizontalCardTableViewCell.m
//  scrappling
//
//  Created by Michael Hanna on 2015-06-28.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCRHorizontalCardTableViewCell.h"
#import "EBCardCollectionViewLayout.h"
#import "SCRFlowContentCollectionViewCell.h"

@implementation SCRHorizontalCardTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    EBCardCollectionViewLayout *layout = [[EBCardCollectionViewLayout alloc] init];
//    layout.sectionInset = UIEdgeInsetsMake(10, 10, 9, 10);
//    layout.itemSize = CGSizeMake(44, 44);
//    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[SCRFlowContentCollectionViewCell class] forCellWithReuseIdentifier:@"SCRFlowContentCollectionViewCell"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = YES;
    [self.contentView addSubview:self.collectionView];
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, 200.0); // hardcoded to 200 to match bogus-gg-image
}


- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;    
    [self.collectionView reloadData];
}

@end
