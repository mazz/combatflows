//
//  SCRMasterCollectionViewController.m
//  scrappling
//
//  Created by Michael Hanna on 2015-05-28.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCRGetTrainedCollectionViewController.h"
//#import "SCRPreviewCollectionViewCell.h"
#import "SCRThumbCollectionViewCell.h"
#import "SCRDoubleThumbCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "SCRFlowGroupDetailViewController.h"
#import "CMACurriculum.h"
#import "IAHInAppPurchaseHelper.h"
#import "UIColor+ILSColor.h"
#import "M13ProgressViewRing.h"
#import "UIView+FLKAutoLayout.h"
#import "UILabel+AutoLayout.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "SCRSociallAccountsViewController.h"
#import "SCROverlayTransitioningDelegate.h"
#import "SCRConstants.h"
#import "SCRReachabilityService.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "SCRTrainingItem.h"

#define FLKPredicate(x) [NSString stringWithFormat:@"%d", x]

@interface SCRGetTrainedCollectionViewController () <SCRSocialAccountsViewDelegate>
@property (strong, nonatomic) NSArray *assets;
@property (strong, nonatomic) NSArray *playerItems;
@property (strong, nonatomic) NSArray *players;
@property (strong, nonatomic) NSDictionary *downloadingItems;
@property (strong, nonatomic) M13ProgressViewRing *ringProgress;
@property (strong, nonatomic) UILabel *modalDownloadLabel;
@property (nonatomic) BOOL viewDidDisappear;
@property (strong, nonatomic) UIAlertController *alertController;
@property (strong, nonatomic) SCROverlayTransitioningDelegate *overlayTransitioningDelegate;
@property (strong, nonatomic) SKProduct *promoContentProduct;
@property (strong, nonatomic) UIAlertController *endAndCreateAlertController;
@property (assign) BOOL restoringItems;
@end

@implementation SCRGetTrainedCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
static NSString *kSCRThumbCollectionViewCellIdentifier = @"kSCRThumbCollectionViewCellIdentifier";
static NSString *kSCRDoubleThumbCollectionViewCellIdentifier = @"kSCRDoubleThumbCollectionViewCellIdentifier";
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

- (void)updateUIForFetchedProducts:(NSNotification *)note
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.trainingItems = [[note userInfo] objectForKey:@"trainingItems"];
        [self setupThumbsPlaybackForTrainingItems:self.trainingItems];
        [self.collectionView reloadData];
        [self.collectionView setHidden:NO];
        
        [self.ringProgress setHidden:!self.collectionView.hidden];
        self.modalDownloadLabel.hidden = !self.collectionView.hidden;
    });
}

- (void)reachabilityChanged:(NSNotification *)note
{
    SCNetworkReachabilityFlags flags = [[[note userInfo] objectForKey:@"flags"] integerValue];

    if (!(flags & kSCNetworkReachabilityFlagsIsWWAN) && !(flags & kSCNetworkReachabilityFlagsReachable))
    {
        DDLogDebug(@"probably offline");
        [self doFetchProducts];
    }
    else if (flags & kSCNetworkReachabilityFlagsIsWWAN)
    {
        DDLogDebug(@"probably cellular");
        [self doFetchProducts];
    }
    else if (flags & kSCNetworkReachabilityFlagsReachable)
    {
        DDLogDebug(@"probably WIFI");
        [self doFetchProducts];
    }
}
    

- (void)doFetchProducts
{
//    self.fetchingProducts = YES;
    
//    [self.ringProgress setIndeterminate:YES];
//    [self.ringProgress setHidden:NO];
//    [self.collectionView setHidden:YES];
    [self modalDownloadUI:NSLocalizedString(@"Fetching Content", @"")];
    [[[IAHInAppPurchaseHelper sharedInstance] productService] fetchProducts];
}

- (void)doRestoreProducts
{
    [self modalDownloadUI:NSLocalizedString(@"Restoring Purchases", @"")];
}

- (void)modalDownloadUI:(NSString *)message
{
    [self.collectionView setHidden:YES];

    [self.ringProgress setIndeterminate:YES];
    [self.ringProgress setHidden:NO];
    self.modalDownloadLabel.hidden = NO;
    self.modalDownloadLabel.text = message;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.restoringItems) {
        [self doRestoreProducts];
    } else {
        [self.ringProgress setIndeterminate:YES];
        [self.ringProgress setHidden:!self.collectionView.hidden];
        if (self.viewDidDisappear)
        {
            [self setupThumbsPlaybackForTrainingItems:self.trainingItems];
            [self.collectionView reloadData];
            self.viewDidDisappear = NO;
        }
    }

    [self.navigationController.navigationBar setBarTintColor:UIColor.blackColor];
    self.navigationController.navigationBar.tintColor = UIColor.combatFlowsConfetti;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0],
                                                                      NSForegroundColorAttributeName:UIColor.combatFlowsConfetti}];

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
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[SCRThumbCollectionViewCell class] forCellWithReuseIdentifier:kSCRThumbCollectionViewCellIdentifier];
    [self.collectionView registerClass:[SCRDoubleThumbCollectionViewCell class] forCellWithReuseIdentifier:kSCRDoubleThumbCollectionViewCellIdentifier];
    [self.collectionView setBackgroundColor:CFBridgingRelease(CFBridgingRetain(UIColor.whiteColor))];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0],
                                                                      NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIForFetchedProducts:) name:SCRProductServiceFetchedProductsNotification object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:SCRReachabilityChangedNotification object:nil];

    
//    [[[IAHInAppPurchaseHelper sharedInstance] productService] fetchProducts];
    
    self.view.backgroundColor = UIColor.blackColor;
    self.ringProgress = [[M13ProgressViewRing alloc] init];
    self.ringProgress.backgroundRingWidth = 3.0;
    [self.ringProgress setIndeterminate:YES];
    self.ringProgress.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.ringProgress];
    [self.ringProgress constrainWidth:FLKPredicate(150) height:FLKPredicate(150)];
    [self.ringProgress alignCenterWithView:self.view];
    self.ringProgress.primaryColor = UIColor.whiteColor;
    self.ringProgress.secondaryColor = UIColor.whiteColor;
    [self.ringProgress setHidden:YES];
    
    self.modalDownloadLabel = [UILabel newAutoLayoutLabel];
    [self.view addSubview:self.modalDownloadLabel];
    [self.modalDownloadLabel alignCenterXWithView:self.view predicate:FLKPredicate(0)];
    [self.modalDownloadLabel constrainBottomSpaceToView:self.ringProgress predicate:FLKPredicate(-10)];
    self.modalDownloadLabel.text = @"modalDownloadLabel";
    self.modalDownloadLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    self.modalDownloadLabel.textColor = UIColor.whiteColor;
    self.modalDownloadLabel.hidden = NO;
    [self doFetchProducts];
    
    // ~~~~~~~~~
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doFetchProducts) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserverForName:IAPHelperTransactionFailedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Transaction Failed", @"Alert view controller title") message:[[note.object error] localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:actionOK];
        [self presentViewController:alertController animated:YES completion:nil];
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionCharged:) name:IAPHelperTransactionChargedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:IAPHelperProductPurchasedNotification object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         NSString *productIdentifier = [note.userInfo objectForKey:@"productIdentifier"];
         [self.trainingItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             if ([[[obj product] productIdentifier] isEqualToString:productIdentifier]) {

                 __block NSArray *scrapplingBundleIndexPath  = nil;
                 
                 // Delete the items from the data source.
                 [self deleteItemsFromDataSourceAtIndexPaths:scrapplingBundleIndexPath];

                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                     if (idx == kSCRScrapplingBundleIndex) // if they bought the scrappling bundle we want to delete the thumb from the collection view
                     {
                         scrapplingBundleIndexPath = @[[NSIndexPath indexPathForRow:idx inSection:0]];
                         // Delete the items from the data source.
                         [self deleteItemsFromDataSourceAtIndexPaths:scrapplingBundleIndexPath];
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self.collectionView performBatchUpdates:^{
                                 NSArray *scrapplingBundleIndexPath = @[[NSIndexPath indexPathForRow:idx inSection:0]];
                                 // Now delete the items from the collection view.
                                 [self.collectionView deleteItemsAtIndexPaths:scrapplingBundleIndexPath];
                             } completion:^(BOOL finished) {
                                 [self setupThumbsPlaybackForTrainingItems:self.trainingItems];
                                 [self.collectionView reloadData];
                             }];
                         });
                     } else {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self.collectionView performBatchUpdates:^{
                                 [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
                             } completion:^(BOOL finished) {
                                 ;
                             }];
                         });
                     }
                 });
             }
         }];
         self.downloadingItems = [NSMutableDictionary dictionary];
     }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:IAPHelperDownloadProgessUpdateNotification object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         //        DDLogDebug(@"observe IAPHelperDownloadProgessUpdateNotification: %@", note);
         NSDictionary *download = [[note userInfo] objectForKey:@"download"];
         NSString *productIdentifier = [[note userInfo] objectForKey:@"productIdentifier"];
         NSMutableDictionary *downloading = [self.downloadingItems mutableCopy];
         [downloading setObject:download forKey:productIdentifier];
         self.downloadingItems = downloading;
         //
         //        DDLogDebug(@"self.downloadingItems: %@", self.downloadingItems);

//         self.currentlyDownloading = YES;
         DDLogDebug(@"observe IAPHelperDownloadProgessUpdateNotification: %@", note);
//         NSDictionary *download = [[note userInfo] objectForKey:@"download"];
         [self.trainingItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             if ([[[obj product] productIdentifier] isEqualToString:productIdentifier]) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.collectionView performBatchUpdates:^{
                         [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
                     } completion:^(BOOL finished) {
                         ;
                     }];
                 });

             }
         }];
     }];

    [[NSNotificationCenter defaultCenter] addObserverForName:IAPHelperDownloadFailedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
//        self.currentlyDownloading = NO;
        self.downloadingItems = [NSMutableDictionary dictionary];
        
        [self.collectionView reloadData];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:IAPHelperTransactionFailedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Transaction Failed", @"Alert view controller title") message:[[note.object error] localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:actionOK];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    
    //IAPHelperRestoreCompletedTransactionsBeginNotification
    //IAPHelperRestoreCompletedTransactionsFinishedNotification
    //IAPHelperRestoreCompletedTransactionsFailedNotification
    
    [[NSNotificationCenter defaultCenter] addObserverForName:IAPHelperRestoreCompletedTransactionsBeginNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.restoringItems = YES;
        [self doRestoreProducts];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:IAPHelperRestoreCompletedTransactionsFinishedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.restoringItems = NO;
        [self doFetchProducts];
//        [self updateUIForFetchedProducts:nil];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:IAPHelperRestoreCompletedTransactionsFailedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.restoringItems = NO;
        [self doFetchProducts];
    }];

    self.restoringItems = NO;
    self.downloadingItems = [NSDictionary dictionary];

    self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"foo", @"Alert view controller title") message:NSLocalizedString(@"initialize me.", @"") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [self.alertController addAction:actionOK];
    
    self.overlayTransitioningDelegate = [[SCROverlayTransitioningDelegate alloc] init];
    self.promoContentProduct = nil;
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.trainingItems.count;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    if (indexPath.row == 2)
    {
        cell = (SCRDoubleThumbCollectionViewCell *)[self cellForIndexPath:indexPath];
    }
    else
    {
        cell = (SCRThumbCollectionViewCell *)[self cellForIndexPath:indexPath];
    }
    return cell;
}

- (UICollectionViewCell *)cellForIndexPath:(NSIndexPath *)indexPath
{
    SCRTrainingItem *trainingItem = [self.trainingItems objectAtIndex:indexPath.row];
    SKProduct *product = [trainingItem product];

    if (indexPath.row == 2 && ![[[IAHInAppPurchaseHelper sharedInstance] productService] hasPurchasedProductWithProductIdentifier:kSCRCombatFlowBundleProductIdentifier])
    {
        SCRDoubleThumbCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kSCRDoubleThumbCollectionViewCellIdentifier forIndexPath:indexPath];

//        DDLogDebug(@"self.productRequestFailed: %d", self.productRequestFailed);
        cell.productRequestFailed = ([[[IAHInAppPurchaseHelper sharedInstance] productService] products] == nil) ? YES : NO;
        
        cell.titleLabel.text = (product != nil) ? [[product localizedTitle] uppercaseString] : [[[trainingItem flowGroup] name] uppercaseString]; //[self.previewItem.product.localizedTitle uppercaseString]
        cell.detailLabel.text = (product != nil) ? [product localizedDescription] : @" ";
        [cell.priceFormatter setLocale:product.priceLocale];
        cell.priceLabel.text = [cell.priceFormatter stringFromNumber:[product price]];
        
        [cell.thumbView setPlayer:self.players[indexPath.row]];
        
        //    NSArray *chargedArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"charged"];
        NSArray *favoriteArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"];
        
        BOOL purchased = [[[IAHInAppPurchaseHelper sharedInstance] productService] hasPurchasedProductWithProductIdentifier:trainingItem.flowGroup.productIdentifier];
        BOOL favorite = [favoriteArray containsObject:[product productIdentifier]];
        cell.purchased = purchased;
        cell.favorite = favorite;
        //    cell.canBeFavorited = (indexPath.row != kSCRScrapplingBundleIndex);
        
//        cell.titleLabel.text = [[product localizedTitle] uppercaseString]; //[self.previewItem.product.localizedTitle uppercaseString]
        //    cell.subtitleLabel.text = [product localizedDescription];
        [cell.priceFormatter setLocale:product.priceLocale];
        cell.cornerButton.tag = indexPath.row;
        
        //    if (cell.purchased)
        if (cell.purchased) // DEBUG to TEST favorites, remove ! when done testing
        {
            [cell.cornerButton addTarget:self action:@selector(favoriteToggle:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        NSDictionary *downloading = [self.downloadingItems objectForKey:product.productIdentifier];
        
        CGFloat progress = (CGFloat)[[downloading objectForKey:@"progress"] doubleValue];
        if (downloading != nil && progress > 0.10)
        {
            cell.progressView.hidden = NO;
            [cell.progressView setProgress:progress animated:NO];
        }
        else
        {
            cell.progressView.hidden = YES;
        }
        return cell;
    }
    else
    {
        SCRThumbCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kSCRThumbCollectionViewCellIdentifier forIndexPath:indexPath];
//        DDLogDebug(@"self.productRequestFailed: %d", self.productRequestFailed);
//        cell.productRequestFailed = self.productRequestFailed;
        cell.productRequestFailed = ([[[IAHInAppPurchaseHelper sharedInstance] productService] products] == nil) ? YES : NO;
        cell.titleLabel.text = (product != nil) ? [[product localizedTitle] uppercaseString] : [[[trainingItem flowGroup] name] uppercaseString]; //[self.previewItem.product.localizedTitle uppercaseString]
        cell.detailLabel.text = (product != nil) ? [product localizedDescription] : @" ";
        [cell.priceFormatter setLocale:product.priceLocale];
        cell.priceLabel.text = [cell.priceFormatter stringFromNumber:[product price]];
        
        [cell.thumbView setPlayer:self.players[indexPath.row]];
        
        //    NSArray *chargedArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"charged"];
        NSArray *favoriteArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"];
        
        BOOL purchased = [[[IAHInAppPurchaseHelper sharedInstance] productService] hasPurchasedProductWithProductIdentifier:[[trainingItem flowGroup] productIdentifier]];
        BOOL favorite = [favoriteArray containsObject:[[[self.trainingItems objectAtIndex:indexPath.row] flowGroup] productIdentifier]];
        cell.purchased = purchased;
        cell.favorite = favorite;
        //    cell.canBeFavorited = (indexPath.row != kSCRScrapplingBundleIndex);
        
//        cell.titleLabel.text = [[product localizedTitle] uppercaseString]; //[self.previewItem.product.localizedTitle uppercaseString]
        //    cell.subtitleLabel.text = [product localizedDescription];
        [cell.priceFormatter setLocale:product.priceLocale];
        cell.cornerButton.tag = indexPath.row;
        
        //    if (cell.purchased)
        if (cell.purchased) // DEBUG to TEST favorites, remove ! when done testing
        {
            [cell.cornerButton addTarget:self action:@selector(favoriteToggle:) forControlEvents:UIControlEventTouchUpInside];
        }
        NSString *productIdentifier = [[[self.trainingItems objectAtIndex:indexPath.row] flowGroup] productIdentifier];
        NSDictionary *downloading = [self.downloadingItems objectForKey:productIdentifier];
        
        DDLogDebug(@"downloading: %@", downloading);
        CGFloat progress = (CGFloat)[[downloading objectForKey:@"progress"] doubleValue];
        if ((downloading != nil && [productIdentifier isEqualToString:kSCRCombatFlowBundleProductIdentifier] && progress > 0.03) || (![productIdentifier isEqualToString:kSCRCombatFlowBundleProductIdentifier] && downloading != nil && progress > 0.10))
        {
            cell.progressView.hidden = NO;
            [cell.progressView setProgress:progress animated:NO];
        }
        else
        {
            cell.progressView.hidden = YES;
        }
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SCRTrainingItem *trainingItem = [self.trainingItems objectAtIndex:indexPath.row];
    SKProduct *product = [trainingItem product];

    // check if we're downloading, if so don't view the content
    if (self.downloadingItems.allKeys.count > 0)
    {
        self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Downloading", @"Alert view controller title") message:NSLocalizedString(@"Please allow the current download to complete before accessing your content", @"") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [self.alertController addAction:actionOK];
        [self presentViewController:self.alertController animated:YES completion:nil];
    }
    else
    {
//        SKProduct *product = [[self.trainingItems objectAtIndex:indexPath.row] product];
        
        if ([[[IAHInAppPurchaseHelper sharedInstance] productService] hasPurchasedProductWithProductIdentifier:trainingItem.flowGroup.productIdentifier])
        {
//            if (indexPath.row != kSCRScrapplingBundleIndex) // 2 is scrappling bundle and we do not drill into it. For purchase only.
//            {
            SCRFlowGroupDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SCRFlowGroupDetailViewController"];
            [detailViewController setFlowGroup:trainingItem.flowGroup];
            [self.navigationController pushViewController:detailViewController animated:YES];
//            }
        }
        else
        {
            if ([[[IAHInAppPurchaseHelper sharedInstance] productService] products] != nil)
            {
                // in here we check if they have are about to purchase a single flow. If so, tell them they will save money if they buy the bundle
                NSArray *chargedArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"charged"];
                
                if (chargedArray == nil && ![product.productIdentifier isEqualToString:kSCRCombatFlowBundleProductIdentifier] && ![product.productIdentifier isEqualToString:kSCRCombatFlowFreeProductIdentifier] && ![product.productIdentifier isEqualToString:kSCRCombatFlowFreeProductIdentifier]) // the message does not apply to bundle, body position free nor guard position free
                {
                    SKProduct *bundleProduct = [[self.trainingItems objectAtIndex:kSCRScrapplingBundleIndex] product];
                    NSNumberFormatter *formatter = [NSNumberFormatter new];
                    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                    
                    [formatter setLocale:bundleProduct.priceLocale];
                    NSString *localPrice = [formatter stringFromNumber:[bundleProduct price]];
                    
                    NSString *savingsWarning = [NSString stringWithFormat:NSLocalizedString(@"Before you purchase %@, Did you know you can Save 66%% by buying the full CombatFlows Bundle at %@?", @""), product.localizedTitle, localPrice];
                    self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Purchase", @"Alert view controller title") message:savingsWarning preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:nil];
                    UIAlertAction *actionPurchase = [UIAlertAction actionWithTitle:NSLocalizedString(@"Purchase", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        DDLogDebug(@"Buying %@...", product.productIdentifier);
                        [[IAHInAppPurchaseHelper sharedInstance] buyProduct:product];
                    }];
                    [self.alertController addAction:actionCancel];
                    [self.alertController addAction:actionPurchase];
                    
                    [self presentViewController:self.alertController animated:YES completion:nil];
                }
                else // about to buy either the bundle or a single flow group AND they already bought something before
                {
                    if (([product.productIdentifier isEqualToString:kSCRCombatFlowFreeProductIdentifier] || [product.productIdentifier isEqualToString:kSCRCombatFlowFreeProductIdentifier]) && ([chargedArray containsObject:kSCRCombatFlowFreeProductIdentifier] || [chargedArray containsObject:kSCRCombatFlowFreeProductIdentifier])) // tell the user they can get this content if they tweet something IF they got either of the free content and they're about to get the second free content
                    {
                        self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Unlock More Free Content", @"Alert view controller title") message:NSLocalizedString(@"If you're enjoying our free scrappling content, have another free training video on us just by tweeting out our message.", @"") preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:nil];
                        UIAlertAction *actionTweet = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                            //                        DDLogDebug(@"Buying %@...", product.productIdentifier);
                            //                        [[IAHInAppPurchaseHelper sharedInstance] buyProduct:product];
                            
                            ACAccountStore *accountStore = [[ACAccountStore alloc] init];
                            
                            // Create an account type that ensures Twitter accounts are retrieved.
                            ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                            // Request access from the user to use their Twitter accounts.
                            [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
                                if (granted)
                                {
                                    if ([accountStore accountsWithAccountType:accountType].count > 0)
                                    {
                                        if ([accountStore accountsWithAccountType:accountType].count > 1) // present a view controller to select the twitter account
                                        {
                                            SCRSociallAccountsViewController *socialAccountsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SCRSociallAccountsViewController"];
                                            socialAccountsViewController.accounts = [accountStore accountsWithAccountType:accountType];
                                            socialAccountsViewController.delegate = self;
                                            socialAccountsViewController.modalPresentationStyle = UIModalPresentationCustom;
                                            socialAccountsViewController.transitioningDelegate = self.overlayTransitioningDelegate;
                                            
                                            //                                        [detailViewController setFlowGroup:[[[CMACurriculum sharedCurriculum] flowGroupsSortedByNumber] objectAtIndex:idx]];
                                            [self presentViewController:socialAccountsViewController animated:YES completion:nil];
                                            self.promoContentProduct = product;
                                        }
                                        else
                                        {
                                            ACAccount *firstAccount = [[accountStore accountsWithAccountType:accountType] objectAtIndex:0];
                                            if (firstAccount != nil)
                                            {
                                                [self promoContentTweet:firstAccount];
                                                self.promoContentProduct = product;
                                            }
                                            else
                                            {
                                                self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Alert view controller title") message:NSLocalizedString(@"There was a problem when attempting to access a Twitter account.", @"") preferredStyle:UIAlertControllerStyleAlert];
                                                UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                                [self.alertController addAction:actionOK];
                                                [self presentViewController:self.alertController animated:YES completion:nil];
                                            }
                                        }
                                    }
                                    else
                                    {
                                        self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Alert view controller title") message:NSLocalizedString(@"A twitter account could not be found.", @"") preferredStyle:UIAlertControllerStyleAlert];
                                        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                        [self.alertController addAction:actionOK];
                                        [self presentViewController:self.alertController animated:YES completion:nil];
                                    }
                                    
                                }
                            }];
                            
                        }];
                        [self.alertController addAction:actionCancel];
                        [self.alertController addAction:actionTweet];
                        
                        [self presentViewController:self.alertController animated:YES completion:nil];
                        
                    }
                    else
                    {
                        DDLogDebug(@"Buying %@...", product.productIdentifier);
                        [[IAHInAppPurchaseHelper sharedInstance] buyProduct:product];
                    }
                }
                
            }
            else // no products, we might be offline
            {
                // show an action sheet to do reconnection attempt
                [self presentViewController:[self endAndCreateAlertController] animated:YES completion:nil];
            }
        }
    }
}

- (void)accountWasSelected:(ACAccount *)selectedAccount
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self promoContentTweet:selectedAccount];
    });

}

- (void)promoContentTweet:(ACAccount *)account
{
    NSString *tweetMessage = @"Hey check out free #mobile #mma #scrappling #jkd #training content from @combatmma http://apple.co/1YiSvAP";
    NSString *confirmMessage = [NSString stringWithFormat:NSLocalizedString(@"About to post this tweet with your account %@:\n\n%@", @""), account.username, tweetMessage];

    SLRequest *postTweet = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"] parameters:@{@"status": tweetMessage}];
    [postTweet setAccount:account];

    self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Shout Out", @"Alert view controller title") message:confirmMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *actionTweet = [UIAlertAction actionWithTitle:NSLocalizedString(@"Tweet", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [postTweet performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (error == nil)
            {
                DDLogDebug(@"Buying %@...", self.promoContentProduct.productIdentifier);
                [[IAHInAppPurchaseHelper sharedInstance] buyProduct:self.promoContentProduct];
            }
            else
            {
                self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Alert view controller title") message:NSLocalizedString(@"There was a problem posting the message to your twitter account. Please try again.", @"") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [self.alertController addAction:actionOK];
                [self presentViewController:self.alertController animated:YES completion:nil];
            }
        }];
    }];
    [self.alertController addAction:actionCancel];
    [self.alertController addAction:actionTweet];
    
    [self presentViewController:self.alertController animated:YES completion:nil];
}

- (UIAlertController *)endAndCreateAlertController
{
    if (!_endAndCreateAlertController)
    {
        __weak typeof(self) weakSelf = self;
        
        _endAndCreateAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Would you like to try and reconnect?", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *reconnectAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Reconnect", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf doFetchProducts];
        }];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];

        //        UIAlertAction *endAndCreateProgressNote = [UIAlertAction actionWithTitle:NSLocalizedString(@"End & Create Progress Note", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
//            
//            weakSelf.progressNoteController.isEndingConversation = YES;
//            [weakSelf presentCreateProgressNoteController];
//        }];
        
        [_endAndCreateAlertController addAction:reconnectAction];
        [_endAndCreateAlertController addAction:actionCancel];
    }
    
    return _endAndCreateAlertController;
}

- (void)favoriteToggle:(id)sender
{
    
//    UIButton *button = (UIButton*)sender;
//    SKProduct *product = [[self.previewItems objectAtIndex:button.tag] product];
//
//    DDLogDebug(@"Buying %@...", product.productIdentifier);
//    [[IAHInAppPurchaseHelper sharedInstance] buyProduct:product];

//    /* TEMP remove until IAP tested
    UIButton *button = (UIButton*)sender;
    SCRTrainingItem *trainingItem = [self.trainingItems objectAtIndex:button.tag];
//    SKProduct *product = [trainingItem product];
    
    NSArray *favoriteArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"];
    
    BOOL favorite = [favoriteArray containsObject:[[trainingItem flowGroup] productIdentifier]];

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
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView performBatchUpdates:^{
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:0]]];
            } completion:^(BOOL finished) {
                ;
            }];
    });

    DDLogDebug(@"favorites: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"]);
//     */
}

-(void)transactionCharged:(NSNotification *)note
{
    DDLogDebug(@"note: %@", note);
    
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
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 3.0;
}

//#pragma mark <UICollectionViewDelegate>
//
 -(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int thumbDimension = ([[SCRConstants sharedInstance] applicationWindow].frame.size.width)/kSCRConstantsThumbDivisor;
    if (indexPath.row == 2 && ![[[IAHInAppPurchaseHelper sharedInstance] productService] hasPurchasedProductWithProductIdentifier:kSCRCombatFlowBundleProductIdentifier])
    {
        return CGSizeMake(thumbDimension*2, thumbDimension*2);
    }
    return CGSizeMake(thumbDimension, thumbDimension);
//    return CGSizeMake(160.0, 160.0);
}

@end
