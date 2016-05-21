//
//  MasterViewController.m
//  scrappling
//
//  Created by Michael Hanna on 2014-08-27.
//  Copyright (c) 2014 ils. All rights reserved.
//

#import "SCRGetTrainedViewController.h"
#import "SCRMasterTableViewCell.h"
#import "CMACurriculum.h"
#import "MSCellAccessory.h"
#import "UIColor+ILSColor.h"
#import "IAHInAppPurchaseHelper.h"
#import "UIImage+ImageEffects.h"
#import "SCRPreviewViewController.h"
#import "SCRGetTrainedCollectionViewController.h"
#import "SCRTrainingItem.h"
#import "SCRFlowGroupTableViewController.h"
#import "SCRFlowGroupDetailViewController.h"
#import "SCRThumbCollectionViewCell.h"
#import "M13ProgressViewRing.h"
#import "UIColor+ILSColor.h"
#import "SCRConstants.h"

static NSString *kSCRMasterCollectionViewCellIdentifier = @"kSCRMasterCollectionViewCell";

@interface SCRGetTrainedViewController ()

//@property (weak, nonatomic) IBOutlet M13ProgressViewRing *ringProgress;
//@property (strong, nonatomic) NSNumberFormatter * priceFormatter;
//@property (strong, nonatomic) SCRPreviewViewController *previewController;
//@property (strong, nonatomic) NSArray *previewItems;
@property (strong, nonatomic) SCRGetTrainedCollectionViewController *bodyCollectionViewController;
//@property (strong, nonatomic) UICollectionView *bodyCollectionView;
@end

//NSString *kMAZTableViewCellReuseIdentifier = @"MAZCell";

@implementation SCRGetTrainedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0],
                                                                      NSForegroundColorAttributeName: [UIColor blackColor]}];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundColor:UIColor.scrapplingForegroundBlueColor];

    self.edgesForExtendedLayout = UIRectEdgeNone;
//    [self.ringProgress setHidden:YES];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIForFetchedProducts:) name:SCRProductServiceFetchedProductsNotification object:nil];
//
//    [[[IAHInAppPurchaseHelper sharedInstance] productService] fetchProducts];
//    
//    [self.ringProgress setIndeterminate:YES];
//    self.ringProgress.primaryColor = UIColor.scrapplingForegroundBlueColor;
//    self.ringProgress.secondaryColor = UIColor.scrapplingForegroundBlueColor;
//    [self.ringProgress setHidden:NO];
//    
//    // ~~~~~~~~~
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doFetchProducts) name:UIApplicationWillEnterForegroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    int thumbDimension = ([[SCRConstants sharedInstance] applicationWindow].frame.size.width)/kSCRConstantsThumbDivisor;
    
    UICollectionViewFlowLayout *bodyCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
//    bodyCollectionViewLayout.itemSize = CGSizeMake(thumbDimension, thumbDimension);
    bodyCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    bodyCollectionViewLayout.minimumInteritemSpacing = 0;
    bodyCollectionViewLayout.minimumLineSpacing = 5;
    bodyCollectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);

    self.bodyCollectionViewController = [[SCRGetTrainedCollectionViewController alloc] initWithCollectionViewLayout:bodyCollectionViewLayout];
    self.bodyCollectionViewController.collectionView.backgroundColor = UIColor.clearColor;
    [self addChildViewController:self.bodyCollectionViewController];
    [self.view addSubview:self.bodyCollectionViewController.view];
    [self.bodyCollectionViewController.view alignToView:self.view];
    
    [self.bodyCollectionViewController didMoveToParentViewController:self];
    self.bodyCollectionViewController.collectionView.showsVerticalScrollIndicator = YES;

}


-(void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIApplicationWillEnterForegroundNotification
//                                                  object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIApplicationDidEnterBackgroundNotification
//                                                  object:nil];
}

//- (void)updateUIForFetchedProducts:(NSNotification *)note
//{
//    [self.ringProgress setHidden:YES];
//    
//    if (self.bodyCollectionViewController == nil)
//    {
//        [self setupCollectionViewControllerWithPreviewItems:[[note userInfo] objectForKey:@"previewItems"]];
//    }
//}

//- (void)doFetchProducts
//{
//    [self.ringProgress setIndeterminate:YES];
//    [self.ringProgress setHidden:NO];
//
//    [[[IAHInAppPurchaseHelper sharedInstance] productService] fetchProducts];
//}
//
//- (void)setupCollectionViewControllerWithPreviewItems:(NSArray *)previewItems
//{
//    int thumbDimension = ([[SCRConstants sharedInstance] applicationWindow].frame.size.width)/kSCRConstantsThumbDivisor;
//
//    UICollectionViewFlowLayout *bodyCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
//    bodyCollectionViewLayout.itemSize = CGSizeMake(thumbDimension, thumbDimension);
//    bodyCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    bodyCollectionViewLayout.minimumInteritemSpacing = 0;
//    bodyCollectionViewLayout.minimumLineSpacing = 5;
//    bodyCollectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
//    
//    self.bodyCollectionViewController = [[SCRGetTrainedCollectionViewController alloc] initWithCollectionViewLayout:bodyCollectionViewLayout previewItems:previewItems];
//    [self addChildViewController:self.bodyCollectionViewController];
//    [self.view addSubview:self.bodyCollectionViewController.view];
//    [self.bodyCollectionViewController.view alignToView:self.view];
//    
//    [self.bodyCollectionViewController didMoveToParentViewController:self];
//    self.bodyCollectionViewController.collectionView.showsVerticalScrollIndicator = YES;
//}
//
//- (void)appWillEnterBackground
//{
//    [self.bodyCollectionViewController.view removeFromSuperview];
//    [self.bodyCollectionViewController removeFromParentViewController];
//    self.bodyCollectionViewController = nil;
//}

@end
