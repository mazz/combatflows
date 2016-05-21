//
//  SCRMasterCollectionViewController.m
//  scrappling
//
//  Created by Michael Hanna on 2015-05-28.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCRFavoritesCollectionViewController.h"
//#import "SCRPreviewCollectionViewCell.h"
#import "SCRThumbCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "SCRFlowGroupDetailViewController.h"
#import "CMACurriculum.h"
#import "IAHInAppPurchaseHelper.h"
#import "UIColor+ILSColor.h"
#import "M13ProgressViewRing.h"
#import "UIView+FLKAutoLayout.h"
#import "SCRTrainingItem.h"

#define FLKPredicate(x) [NSString stringWithFormat:@"%d", x]

@interface SCRFavoritesCollectionViewController ()
@property (strong, nonatomic) NSArray *assets;
@property (strong, nonatomic) NSArray *playerItems;
@property (strong, nonatomic) NSArray *players;
@property (strong, nonatomic) NSDictionary *downloadingItems;
@property (strong, nonatomic) M13ProgressViewRing *ringProgress;
@property (strong, nonatomic) NSArray *trainingItems;
@property (nonatomic) BOOL viewDidDisappear;
@end

@implementation SCRFavoritesCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
static NSString *kSCRMasterCollectionViewCellIdentifier = @"kSCRMasterCollectionViewCell";
static NSUInteger kSCRScrapplingBundleIndex = 2;

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    if ((self = [super initWithCollectionViewLayout:layout]))
    {
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void)updateUIForFetchedProducts:(NSNotification *)note
//{
//    self.trainingItems = [[note userInfo] objectForKey:@"trainingItems"];
//    [self setupThumbsPlaybackForTrainingItems:self.trainingItems];
//    [self.collectionView reloadData];
//    [self.collectionView setHidden:NO];
//
//    [self.ringProgress setHidden:YES];
//}

//- (void)doFetchProducts
//{
//    [self.ringProgress setIndeterminate:YES];
//    [self.ringProgress setHidden:NO];
//    [self.collectionView setHidden:YES];
//    [[[IAHInAppPurchaseHelper sharedInstance] productService] fetchProducts];
//}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.viewDidDisappear)
    {
        [self setupFavoriteTrainingItems];
        self.viewDidDisappear = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    for (AVQueuePlayer *player in self.players)
    {
        [player pause];
    }
    self.viewDidDisappear = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerClass:[SCRThumbCollectionViewCell class] forCellWithReuseIdentifier:kSCRMasterCollectionViewCellIdentifier];
    [self.collectionView setBackgroundColor:CFBridgingRelease(CFBridgingRetain(UIColor.whiteColor))];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0],
                                                                      NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupFavoriteTrainingItems) name:UIApplicationWillEnterForegroundNotification object:nil];

    [self setupFavoriteTrainingItems];
    self.viewDidDisappear = NO;
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];

}

- (void)setupFavoriteTrainingItems
{
    NSMutableArray *items = [NSMutableArray array];
    
    for (NSString *productIdentifier in [[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"])
    {
        SCRTrainingItem *item = [[SCRTrainingItem alloc] init];
        [item setProduct:[[[IAHInAppPurchaseHelper sharedInstance] productService] productForProductIdentifier:productIdentifier]];
        [item setFlowGroup:[[CMACurriculum sharedCurriculum] flowGroupForProductIdentifier:productIdentifier]];
        [items addObject:item];
    }
    
    self.trainingItems = items;
    [self setupThumbsPlaybackForTrainingItems:self.trainingItems];
    
    if (self.trainingItems.count == 0)
    {
        self.collectionView.hidden = YES;
    }
    else
    {
        self.collectionView.layer.opacity = 1.0;
        self.collectionView.hidden = NO;
        [self.collectionView reloadData];
    }
}

-(void)deleteItemsFromDataSourceAtIndexPaths:(NSArray  *)itemPaths
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSIndexPath *itemPath  in itemPaths)
    {
        [indexSet addIndex:itemPath.row];
    }
    NSMutableArray *mutPreviewItems = [self.trainingItems mutableCopy];
    [mutPreviewItems removeObjectsAtIndexes:indexSet];
    self.trainingItems = [mutPreviewItems copy];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    if ([self.playerItems indexOfObjectIdenticalTo:[notification object]] != NSNotFound)
    {
        AVQueuePlayer *qp = [self.players objectAtIndex:[self.playerItems indexOfObjectIdenticalTo:[notification object]]];
        [qp removeAllItems];
        
        AVPlayerItem *p = [notification object];
        [p seekToTime:kCMTimeZero];
        
        [qp insertItem:p afterItem:nil];
    }
}


- (void)setupThumbsPlaybackForTrainingItems:(NSArray *)trainingItems
{
    self.assets = nil;
    self.playerItems = nil;
    self.players = nil;
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *playerItems = [NSMutableArray array];
    NSMutableArray *players = [NSMutableArray array];
    // create the AVURLAssets from the thumbnails
    for (SCRTrainingItem *item in trainingItems)
    {
        [assets addObject:[[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:[[[item flowGroup] thumbs] objectAtIndex:0]] options:nil]];
    }
    
    self.assets = assets;
    
    for (AVURLAsset *asset in self.assets)
    {
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
        [playerItems addObject:item];
        if (item != nil)
        {
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:item];
            
//            [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
//                if ([self.playerItems indexOfObjectIdenticalTo:[note object]] != NSNotFound)
//                {
//                    AVQueuePlayer *qp = [self.players objectAtIndex:[self.playerItems indexOfObjectIdenticalTo:[note object]]];
//                    [qp removeAllItems];
//                    
//                    AVPlayerItem *p = [note object];
//                    [p seekToTime:kCMTimeZero];
//                    
//                    [qp insertItem:p afterItem:nil];
//                }
//            }];
        }
        AVQueuePlayer *p = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObject:item]];
        [players addObject:p];
        
        if ([p respondsToSelector:@selector(setAllowsExternalPlayback:)])
        {
            [p setAllowsExternalPlayback:NO];
        }
        if ([p respondsToSelector:@selector(setUsesExternalPlaybackWhileExternalScreenIsActive:)])
        {
            [p setUsesExternalPlaybackWhileExternalScreenIsActive:NO];
        }
        
        if (p != nil)
        {
            [p setActionAtItemEnd:AVPlayerActionAtItemEndNone];
        }
        [p seekToTime:kCMTimeZero];
        [p play];
    }
    self.playerItems = playerItems;
    self.players = players;

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.trainingItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SCRTrainingItem *trainingItem = [self.trainingItems objectAtIndex:indexPath.row];
    SKProduct *product = [trainingItem product];

    SCRThumbCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSCRMasterCollectionViewCellIdentifier forIndexPath:indexPath];
//    SKProduct *product = [[self.trainingItems objectAtIndex:indexPath.row] product];
    cell.titleLabel.text = (product != nil) ? [[product localizedTitle] uppercaseString] : [[[trainingItem flowGroup] name] uppercaseString]; //[self.previewItem.product.localizedTitle uppercaseString]
    cell.detailLabel.text = (product != nil) ? [product localizedDescription] : @" ";
    [cell.priceFormatter setLocale:product.priceLocale];
    cell.priceLabel.text = [cell.priceFormatter stringFromNumber:[product price]];

    [cell.thumbView setPlayer:self.players[indexPath.row]];

//    NSArray *chargedArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"charged"];
    NSArray *favoriteArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"];
    
    BOOL purchased = [[[IAHInAppPurchaseHelper sharedInstance] productService] hasPurchasedProductWithProductIdentifier:trainingItem.flowGroup.productIdentifier];
    BOOL favorite = [favoriteArray containsObject:trainingItem.flowGroup.productIdentifier];
    cell.purchased = purchased;
    cell.favorite = favorite;
//    cell.canBeFavorited = (indexPath.row != kSCRScrapplingBundleIndex);
    
//    cell.titleLabel.text = [[product localizedTitle] uppercaseString]; //[self.previewItem.product.localizedTitle uppercaseString]
//    cell.subtitleLabel.text = [product localizedDescription];
    [cell.priceFormatter setLocale:product.priceLocale];
    cell.cornerButton.tag = indexPath.row;

//    if (cell.purchased)
    if (cell.purchased) // DEBUG to TEST favorites, remove ! when done testing
    {
        [cell.cornerButton addTarget:self action:@selector(favoriteToggle:) forControlEvents:UIControlEventTouchUpInside];
    }

//    NSDictionary *downloading = [self.downloadingItems objectForKey:trainingItem.flowGroup.productIdentifier];
//    
//    CGFloat progress = (CGFloat)[[downloading objectForKey:@"progress"] doubleValue];
//    if (downloading != nil && progress > 0.15)
//    {
//        cell.progressView.hidden = NO;
//        [cell.progressView setProgress:progress animated:NO];
//    }
//    else
//    {
//        cell.progressView.hidden = YES;
//    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SCRTrainingItem *trainingItem = [self.trainingItems objectAtIndex:indexPath.row];
    SKProduct *product = [trainingItem product];
    
    if ([[[IAHInAppPurchaseHelper sharedInstance] productService] hasPurchasedProductWithProductIdentifier:trainingItem.flowGroup.productIdentifier])
    {
        //            if (indexPath.row != kSCRScrapplingBundleIndex) // 2 is scrappling bundle and we do not drill into it. For purchase only.
        //            {
        SCRFlowGroupDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SCRFlowGroupDetailViewController"];
        [detailViewController setFlowGroup:trainingItem.flowGroup];
        [self.navigationController pushViewController:detailViewController animated:YES];
        //            }
    }
}

- (void)favoriteToggle:(id)sender
{
    
//    UIButton *button = (UIButton*)sender;
//    SKProduct *product = [[self.previewItems objectAtIndex:button.tag] product];
//
//    NSLog(@"Buying %@...", product.productIdentifier);
//    [[IAHInAppPurchaseHelper sharedInstance] buyProduct:product];

//    /* TEMP remove until IAP tested
    UIButton *button = (UIButton*)sender;
    SCRTrainingItem *trainingItem = [self.trainingItems objectAtIndex:button.tag];
    SKProduct *product = [trainingItem product];
//    SKProduct *product = [[self.trainingItems objectAtIndex:button.tag] product];
    
    NSArray *favoriteArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"];
    
    BOOL favorite = [favoriteArray containsObject:trainingItem.flowGroup.productIdentifier];

    if (!favorite)
    {
        NSArray *favoritesArray = @[trainingItem.flowGroup.productIdentifier];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"] != nil)
        {
            NSMutableArray *favorite = [[[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"] mutableCopy];
            [favorite addObjectsFromArray:favoritesArray];
            [[NSUserDefaults standardUserDefaults] setObject:favorite forKey:@"favorite"];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:favoritesArray forKey:@"favorite"];
        }
    }
    else
    {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"] != nil)
        {
            NSMutableArray *favorite = [[[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"] mutableCopy];
            [favorite removeObject:trainingItem.flowGroup.productIdentifier];
            [[NSUserDefaults standardUserDefaults] setObject:favorite forKey:@"favorite"];
            [self.collectionView performBatchUpdates:^{
                
                NSArray *scrapplingBundleIndexPath = @[[NSIndexPath indexPathForRow:button.tag inSection:0]];
                
                // Delete the items from the data source.
                [self deleteItemsFromDataSourceAtIndexPaths:scrapplingBundleIndexPath];
                
                // Now delete the items from the collection view.
                [self.collectionView deleteItemsAtIndexPaths:scrapplingBundleIndexPath];
                
            } completion:^(BOOL finished) {
                if (self.trainingItems.count == 0)
                {
                    [UIView animateWithDuration:0.5 animations:^{
                        self.collectionView.layer.opacity = 0.0;
                    }];
                }
                [self.collectionView reloadData];
                
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(favoriteWasRemoved)])
                {
                    [self.delegate favoriteWasRemoved];
                }

            }];
        }
    }
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//            [self.collectionView performBatchUpdates:^{
//                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:0]]];
//            } completion:^(BOOL finished) {
//                ;
//            }];
//    });

    NSLog(@"favorites: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"]);
//     */
}

-(void)transactionCharged:(NSNotification *)note
{
    NSLog(@"note: %@", note);
    
    //    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:note.userInfo[@"productIdentifier"]];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // just bought scrappling bundle so buy bonus for 0.00
//    [self.collectionView reloadData];
}

//
//- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(-20, 5, 30.0, 5); // top, left, bottom, right
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 0.0;
//}
//
//#pragma mark <UICollectionViewDelegate>
//
// -(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(150.0, 150.0);
////    return CGSizeMake(160.0, 160.0);
//}


/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
