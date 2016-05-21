//
//  SCRFavoritesViewController.m
//  scrappling
//
//  Created by Michael Hanna on 2015-06-13.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCRFavoritesViewController.h"
#import "SCRConstants.h"
#import "SCRFavoritesCollectionViewController.h"
#import "UIView+FLKAutoLayout.h"

@interface SCRFavoritesViewController () <SCRFavoritesDelegate>
@property (strong, nonatomic) SCRFavoritesCollectionViewController *bodyCollectionViewController;
@property (weak, nonatomic) IBOutlet UILabel *putYourFavoritesHereLabel;
@end

@implementation SCRFavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    int thumbDimension = ([[SCRConstants sharedInstance] applicationWindow].frame.size.width)/kSCRConstantsThumbDivisor;
    
    UICollectionViewFlowLayout *bodyCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    bodyCollectionViewLayout.itemSize = CGSizeMake(thumbDimension, thumbDimension);
    bodyCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    bodyCollectionViewLayout.minimumInteritemSpacing = 0;
    bodyCollectionViewLayout.minimumLineSpacing = 5;
    bodyCollectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    self.bodyCollectionViewController = [[SCRFavoritesCollectionViewController alloc] initWithCollectionViewLayout:bodyCollectionViewLayout];
    self.bodyCollectionViewController.delegate = self;
    self.bodyCollectionViewController.collectionView.backgroundColor = UIColor.clearColor;
    [self addChildViewController:self.bodyCollectionViewController];
    [self.view addSubview:self.bodyCollectionViewController.view];
    [self.bodyCollectionViewController.view alignToView:self.view];
    
    [self.bodyCollectionViewController didMoveToParentViewController:self];
    self.bodyCollectionViewController.collectionView.showsVerticalScrollIndicator = YES;
    self.putYourFavoritesHereLabel.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.putYourFavoritesHereLabel.hidden = !([[[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"] count] == 0);
}

- (void)favoriteWasRemoved
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"] count] == 0))
        {
            self.putYourFavoritesHereLabel.layer.opacity = 0.0;
            self.putYourFavoritesHereLabel.hidden = NO;
            [UIView animateWithDuration:0.5 animations:^{
                self.putYourFavoritesHereLabel.layer.opacity = 1.0;
            }];
        }
    });
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
