//
//  SCRCombatMMAAppsViewController.m
//  scrappling
//
//  Created by Michael Hanna on 2016-02-07.
//  Copyright © 2016 ils. All rights reserved.
//

#import "SCRCombatMMAAppsViewController.h"
#import "UIView+FLKAutoLayout.h"
#import "UIView+AutoLayout.h"
#import "UIView+Debug.h"
#import <StoreKit/StoreKit.h>
#import "SCRBlankInterstitialViewController.h"

#define FLKPredicate(x) [NSString stringWithFormat:@"%d", x]

static NSInteger const kAppITunesCombatFlowLTItemIdentifier = 577328937;
static NSInteger const kAppITunesCombatFlowHTItemIdentifier = 577333699;
static NSInteger const kAppITunesScrapplingItemIdentifier = 505824406;
static NSInteger const kAppITunesJeetKuneDoItemIdentifier = 577328937;

CGFloat kBlankInterstitialDissolveAnimationDuration = 0.3;

NS_ASSUME_NONNULL_BEGIN
@interface SCRCombatMMAAppsViewController () <SKStoreProductViewControllerDelegate>
@property (strong, nonatomic) UIView *verticalGutter;
@property (strong, nonatomic) UIView *horizontalGutter;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) UIImageView *topLeftImageView;
@property (strong, nonatomic) UIImageView *topRightImageView;
@property (strong, nonatomic) UIImageView *bottomLeftImageView;
@property (strong, nonatomic) UIImageView *bottomRightImageView;
@property (strong, nonatomic) UIButton *topLeftButton;
@property (strong, nonatomic) UIButton *topRightButton;
@property (strong, nonatomic) UIButton *bottomLeftButton;
@property (strong, nonatomic) UIButton *bottomRightButton;
@property (strong, nonatomic) SCRBlankInterstitialViewController *blankInterstitialViewController;
@end

@implementation SCRCombatMMAAppsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.verticalGutter = [UIView newAutoLayoutView];
    [self.contentView addSubview:self.verticalGutter];
    [self.verticalGutter constrainWidth:FLKPredicate(8) height:FLKPredicate(200)];
    [self.verticalGutter alignCenterWithView:self.contentView];
    
    self.horizontalGutter = [UIView newAutoLayoutView];
    [self.contentView addSubview:self.horizontalGutter];
    [self.horizontalGutter constrainWidth:FLKPredicate(200) height:FLKPredicate(8)];
    [self.horizontalGutter alignCenterXWithView:self.contentView predicate:FLKPredicate(0)];
    
    self.topLeftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cmma_apps_icns_lt"]];
    self.topLeftImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.topLeftImageView];
    [self.topLeftImageView alignTopEdgeWithView:self.contentView predicate:FLKPredicate(8)];
    [self.verticalGutter constrainLeadingSpaceToView:self.topLeftImageView predicate:FLKPredicate(0)];
    [self.horizontalGutter constrainTopSpaceToView:self.topLeftImageView predicate:FLKPredicate(0)];
    [self.topLeftImageView constrainWidthToView:self.view predicate:@"*.4"];
    [self.topLeftImageView constrainHeightToView:self.view predicate:@"*.3"];
    
    self.bottomLeftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cmma_apps_icns_jkd"]];
    self.bottomLeftImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.bottomLeftImageView];
    [self.bottomLeftImageView constrainTopSpaceToView:self.horizontalGutter predicate:FLKPredicate(0)];
    [self.verticalGutter constrainLeadingSpaceToView:self.bottomLeftImageView predicate:FLKPredicate(0)];
    [self.bottomLeftImageView constrainWidthToView:self.view predicate:@"*.4"];
    [self.bottomLeftImageView constrainHeightToView:self.view predicate:@"*.3"];

    self.topRightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cmma_apps_icns_ht"]];
    self.topRightImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.topRightImageView];
    [self.topRightImageView alignTopEdgeWithView:self.contentView predicate:FLKPredicate(8)];
    [self.topRightImageView constrainLeadingSpaceToView:self.verticalGutter predicate:FLKPredicate(0)];
    [self.topRightImageView constrainWidthToView:self.view predicate:@"*.4"];
    [self.topRightImageView constrainHeightToView:self.view predicate:@"*.3"];
    [self.horizontalGutter constrainTopSpaceToView:self.topRightImageView predicate:FLKPredicate(0)];
    
    self.bottomRightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cmma_apps_icns_scrp"]];
    self.bottomRightImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.bottomRightImageView];
    [self.bottomRightImageView constrainTopSpaceToView:self.horizontalGutter predicate:FLKPredicate(0)];
    [self.bottomRightImageView constrainLeadingSpaceToView:self.verticalGutter predicate:FLKPredicate(0)];
    [self.bottomRightImageView constrainWidthToView:self.view predicate:@"*.4"];
    [self.bottomRightImageView constrainHeightToView:self.view predicate:@"*.3"];

    [UIView alignBottomEdgesOfViews:@[self.bottomLeftImageView, self.contentView]];

    self.topLeftButton = [[UIButton alloc] init];
    [self.contentView addSubview:self.topLeftButton];
    [self.topLeftButton alignToView:self.topLeftImageView];
    [self.topLeftButton addTarget:self action:@selector(topLeftTapped) forControlEvents:UIControlEventTouchUpInside];

    self.bottomLeftButton = [[UIButton alloc] init];
    [self.contentView addSubview:self.bottomLeftButton];
    [self.bottomLeftButton alignToView:self.bottomLeftImageView];
    [self.bottomLeftButton addTarget:self action:@selector(bottomLeftTapped) forControlEvents:UIControlEventTouchUpInside];

    self.topRightButton = [[UIButton alloc] init];
    [self.contentView addSubview:self.topRightButton];
    [self.topRightButton alignToView:self.topRightImageView];
    [self.topRightButton addTarget:self action:@selector(topRightTapped) forControlEvents:UIControlEventTouchUpInside];

    self.bottomRightButton = [[UIButton alloc] init];
    [self.contentView addSubview:self.bottomRightButton];
    [self.bottomRightButton alignToView:self.bottomRightImageView];
    [self.bottomRightButton addTarget:self action:@selector(bottomRightTapped) forControlEvents:UIControlEventTouchUpInside];
//    self.topLeftButton = [[UIButton alloc] initWithFrame:self.to
//    [UIView colorViewsRandomly:self.view];
    
    self.blankInterstitialViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SCRBlankInterstitialViewController"];
    
}

- (void)itemTapped {
    
    self.blankInterstitialViewController.view.layer.opacity = 0.0;
    
    [self addChildViewController:self.blankInterstitialViewController];
    [self.view addSubview:self.blankInterstitialViewController.view];
    self.blankInterstitialViewController.view.frame = self.view.bounds;
    [self.blankInterstitialViewController didMoveToParentViewController:self];

    [UIView animateWithDuration:kBlankInterstitialDissolveAnimationDuration animations:^{
        self.blankInterstitialViewController.view.layer.opacity = 1.0;
    }];
}

- (void)topLeftTapped { // kAppITunesCombatFlowLTItemIdentifier
    [self itemTapped];
    
    NSLog(@"topLeftTapped");
    [self openStoreProductViewControllerWithITunesItemIdentifier:kAppITunesCombatFlowLTItemIdentifier];
}

- (void)bottomLeftTapped {
    [self itemTapped];
    NSLog(@"bottomLeftTapped");
}

- (void)topRightTapped {
    [self itemTapped];
    [self openStoreProductViewControllerWithITunesItemIdentifier:kAppITunesCombatFlowHTItemIdentifier];
}

- (void)bottomRightTapped {
    [self itemTapped];
    [self openStoreProductViewControllerWithITunesItemIdentifier:kAppITunesScrapplingItemIdentifier];
}


- (void)openStoreProductViewControllerWithITunesItemIdentifier:(NSInteger)iTunesItemIdentifier {
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
    storeViewController.delegate = self;
    
    NSNumber *identifier = [NSNumber numberWithInteger:iTunesItemIdentifier];
    NSDictionary *parameters = @{ SKStoreProductParameterITunesItemIdentifier:identifier };
        [storeViewController loadProductWithParameters:parameters completionBlock:^(BOOL result, NSError *error) {
            if (result) {
                [self presentViewController:storeViewController animated:NO completion:nil];
            }
            else {
                [UIView animateWithDuration:kBlankInterstitialDissolveAnimationDuration animations:^{
                    self.blankInterstitialViewController.view.layer.opacity = 0.0;
                } completion:^(BOOL finished) {
                    [[self.blankInterstitialViewController view] removeFromSuperview];
                    [self.blankInterstitialViewController removeFromParentViewController];
                }];
                
                NSLog(@"SKStoreProductViewController: %@", error);
            }
        }];

}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:^{
        [UIView animateWithDuration:kBlankInterstitialDissolveAnimationDuration animations:^{
            self.blankInterstitialViewController.view.layer.opacity = 0.0;
        } completion:^(BOOL finished) {
            [[self.blankInterstitialViewController view] removeFromSuperview];
            [self.blankInterstitialViewController removeFromParentViewController];
        }];
    }];
}
@end
NS_ASSUME_NONNULL_END