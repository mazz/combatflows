//
//  SCRPreviewBuyViewController.m
//  scrappling
//
//  Created by Michael Hanna on 2014-09-30.
//  Copyright (c) 2014 ils. All rights reserved.
//

#import "SCRPreviewViewController.h"
#import "UIView+FLKAutoLayout.h"
#import "UIView+AutoLayout.h"
#import "UILabel+AutoLayout.h"
#import "UIView+Debug.h"
#import "UIFont+SCRFont.h"
#import "SCRTrainingItem.h"
#import "EBCardCollectionViewLayout.h"
#import "SCRPreviewCollectionViewController.h"

CGFloat kSCRPreviewBeginDismissAnimationDuration = 0.3;

@interface SCRPreviewViewController () <UICollectionViewDelegate>
@property (strong, nonatomic) UIImageView *background;
@property (strong, nonatomic) UIImageView *beginSticker;
@property (strong, nonatomic) UIImageView *dismissSticker;
@property (strong, nonatomic) UIView *stickerStartConverted;
@property (strong, nonatomic) UIView *stickerDismissConverted;
@property (strong, nonatomic) UIView *stickerPreviewConverted;
@property (strong, nonatomic) UIImageView *stickerDestination;
@property (nonatomic) CGPoint initialStickerLocation;
@property (strong, nonatomic) UIVisualEffectView *blurView;
@property (strong, nonatomic) UIView *contentBox;   // 0.45 height of self.view
@property (strong, nonatomic) UIView *titleBox;     // 0.25 height of self.contentBox -- 90 pts high
//@property (strong, nonatomic) UIView *bodyBox;     // 0.75 height of self.contentBox
@property (strong, nonatomic) UIView *centredTitleBox;     // centred inside titleBox
@property (strong, nonatomic) UIView *stickerBox;   // inside self.centredTitleBox
@property (strong, nonatomic) UIView *infoBox;   // inside self.centredTitleBox
@property (strong, nonatomic) UIView *compressedLabelBox;   // inside self.infoBox
//@property (strong, nonatomic) UIView *compressedLabelBox;   // inside self.infoBox
@property (strong, nonatomic) UIView *dismissalView;    // tap to dismiss view controller
@property (nonatomic) CGPathRef previewStickerPath;
@property (nonatomic) CGFloat stickerScaleFactor;
@property (strong, nonatomic) NSNumberFormatter *priceFormatter;
@property (strong, nonatomic) NSArray *previewItems;
@property (strong, nonatomic) SCRPreviewCollectionViewController *bodyCollectionViewController;

@end

@implementation SCRPreviewViewController
{
    NSInteger _currentIndex;
//    SCRPreviewScrollViewDelegate *collectionViewsScrollViewDelegate;
}

- (instancetype)initWithItems:(NSArray *)items initialItemIndex:(NSUInteger)initialItemIndex backgroundImageView:(UIImageView *)biv
{
    if ((self = [super init]))
    {
        _currentIndex = initialItemIndex;
        self.previewItems = items;
        self.initialStickerLocation = [[items objectAtIndex:initialItemIndex] initialStickerLocation];
        self.background = biv;
        
        UIImage *sticker = [UIImage imageNamed:@"AppIcon"];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(self.initialStickerLocation.x, self.initialStickerLocation.y, sticker.size.width, sticker.size.height)];
        [iv setImage:sticker];
        self.beginSticker = iv;
        self.stickerStartConverted = [[UIView alloc] initWithFrame:[self.beginSticker convertRect:self.beginSticker.bounds toView:self.view]];
    }
    return self;
}

-(void)loadView
{
    [super loadView];
//    self.view.backgroundColor = [UIColor blueColor];
    [self.view setFrame:self.background.frame];
    [self.view addSubview:self.background];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.priceFormatter = [NSNumberFormatter new];
    [self.priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [self.priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    self.blurView.frame = self.view.frame;
    self.blurView.alpha = 0.0;
    [self.view addSubview:self.blurView];
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
//    [UIView colorViewsRandomly:self.view];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingViewTapped:)];
    [self.dismissalView addGestureRecognizer:tap];

    [self.stickerDestination setFrame:CGRectMake(0.0, 0.0, self.stickerBox.frame.size.width, self.stickerBox.frame.size.width)];
 
    self.stickerDestination.center = self.stickerDestination.superview.center;
    self.stickerDestination.contentMode = UIViewContentModeScaleAspectFit;

    CGRect buttonLoc = [self.stickerDestination convertRect:self.stickerDestination.bounds toView:self.view];
    self.stickerPreviewConverted = [[UIView alloc] initWithFrame:buttonLoc];
    NSLog(@"destView center: %@", NSStringFromCGPoint(self.stickerPreviewConverted.center));
    [self.view addSubview:self.beginSticker];
    
    self.infoBox.alpha = 0.0;
//    self.bodyCollectionViewController.view.alpha = 0.0;
    
    [self beginPreview];
    
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
//    SKProduct *product = [[self.previewItems objectAtIndex:_currentIndex] product];
    
    if (self.contentBox == nil)
    {
        self.dismissalView = [UIView newAutoLayoutView];
        [self.view addSubview:self.dismissalView];
        [self.dismissalView alignLeading:@"0" trailing:@"0" toView:self.view];
        [self.dismissalView alignTopEdgeWithView:self.view predicate:@"0"];
        [self.dismissalView constrainHeightToView:self.view predicate:@"*0.5"];

        self.contentBox = [UIView newAutoLayoutView];
        [self.view addSubview:self.contentBox];

        [self.contentBox alignLeadingEdgeWithView:self.view predicate:@"0"];
        [self.contentBox alignTrailingEdgeWithView:self.view predicate:@"0"];
        [self.contentBox alignBottomEdgeWithView:self.view predicate:@"0"];
        [self.contentBox constrainHeightToView:self.view predicate:@"*0.5"];
        
        self.titleBox = [UIView newAutoLayoutView];
        [self.contentBox addSubview:self.titleBox];

        [self.titleBox alignLeadingEdgeWithView:self.contentBox predicate:nil];
        [self.titleBox alignTrailingEdgeWithView:self.contentBox predicate:nil];
        [self.titleBox alignTopEdgeWithView:self.contentBox predicate:nil];
        [self.titleBox constrainHeightToView:self.contentBox predicate:@"*0.30"];
//        [self.titleBox constrainHeight:@"90"];

//        self.bodyBox = [UIView newAutoLayoutView];
//        [self.contentBox addSubview:self.bodyBox];
//        
//        [self.bodyBox alignLeadingEdgeWithView:self.contentBox predicate:@"0"];
//        [self.bodyBox alignTrailingEdgeWithView:self.contentBox predicate:@"0"];
//        [self.bodyBox alignBottomEdgeWithView:self.contentBox predicate:@"0"];
//        [self.bodyBox constrainHeightToView:self.contentBox predicate:@"*0.70"];
     
        self.centredTitleBox = [UIView newAutoLayoutView];
        [self.titleBox addSubview:self.centredTitleBox];
        [self.centredTitleBox constrainHeightToView:self.titleBox predicate:@"*1.0"];
        [self.centredTitleBox constrainWidth:@"275"];
        [self.centredTitleBox alignCenterWithView:self.titleBox];

        self.stickerBox = [UIView newAutoLayoutView];
        [self.centredTitleBox addSubview:self.stickerBox];
        [self.stickerBox alignTopEdgeWithView:self.centredTitleBox predicate:@"0"];
        [self.stickerBox constrainWidth:@"80"];
        [self.stickerBox constrainHeightToView:self.centredTitleBox predicate:@"0"];
        [self.stickerBox alignLeadingEdgeWithView:self.centredTitleBox predicate:@"0"];
        [self.stickerBox alignCenterYWithView:self.centredTitleBox predicate:@"0"];
        
//
        self.infoBox = [UIView newAutoLayoutView];
        [self.centredTitleBox addSubview:self.infoBox];
        [self.infoBox constrainLeadingSpaceToView:self.stickerBox predicate:@"5"];
        [self.infoBox alignTopEdgeWithView:self.centredTitleBox predicate:@"0"];
        [self.infoBox alignTrailingEdgeWithView:self.centredTitleBox predicate:@"0"];
        [self.infoBox alignBottomEdgeWithView:self.centredTitleBox predicate:@"0"];

        self.stickerDestination = [[UIImageView alloc] init];
        self.stickerDestination.translatesAutoresizingMaskIntoConstraints = NO;
        [self.stickerBox addSubview:self.stickerDestination];
        [self.stickerDestination alignCenterWithView:self.stickerBox];

    }

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.bodyCollectionViewController == nil)
    {
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //        collectionViewLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
//        collectionViewLayout.itemSize = CGSizeMake(320, 50);
        
        EBCardCollectionViewLayout *bodyCvl = [[EBCardCollectionViewLayout alloc] init];
        self.bodyCollectionViewController = [[SCRPreviewCollectionViewController alloc] initWithCollectionViewLayout:bodyCvl previewItems:self.previewItems initialItemIndex:_currentIndex];
        
        //        UIOffset anOffset = UIOffsetMake(40, 10);
        //        [(EBCardCollectionViewLayout *)self.bodyCollectionViewController.collectionView.collectionViewLayout setOffset:anOffset];
        
        [self addChildViewController:self.bodyCollectionViewController];
        [self.contentBox addSubview:self.bodyCollectionViewController.view];
        [self.bodyCollectionViewController.view alignToView:self.contentBox];
        //        NSLog(@"self.previewCollectionViewController.view: %@", self.previewCollectionViewController.view);
        [self.bodyCollectionViewController didMoveToParentViewController:self];
        
        self.bodyCollectionViewController.collectionView.backgroundColor = UIColor.clearColor;
        self.bodyCollectionViewController.collectionView.showsHorizontalScrollIndicator = NO;
        self.bodyCollectionViewController.collectionView.showsVerticalScrollIndicator = NO;
    }
}

- (void)dimmingViewTapped:(UIGestureRecognizer *)gesture
{
    if([gesture state] == UIGestureRecognizerStateRecognized)
    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissPreviewBuyViewController" object:nil];
        [self dismissPreview];
    }
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    NSLog(@"scrollViewDidScroll scrollView: %@", scrollView);
//    if (scrollView == self.bodyCollectionViewController.collectionView)
//    {
//        self.titleCollectionViewController.collectionView.contentOffset = scrollView.contentOffset;
//    }
//    else if (scrollView == self.titleCollectionViewController.collectionView)
//    {
//        self.bodyCollectionViewController.collectionView.contentOffset = scrollView.contentOffset;
//    }
//    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCRBodyCollectionViewControllerScrollViewDidScroll" object:nil userInfo:@{@"contentOffset":[NSValue valueWithCGPoint:scrollView.contentOffset]}];
//}


- (void)beginPreview
{
    [CATransaction begin];
    {
        CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacity.fromValue = [NSNumber numberWithFloat:0.0];
        opacity.toValue = [NSNumber numberWithFloat:1.0];
        opacity.additive = NO;
        opacity.removedOnCompletion = NO;
        opacity.duration = kSCRPreviewBeginDismissAnimationDuration;
        
        [self.blurView.layer addAnimation:opacity forKey:@"visualEffectChanges"];
        self.blurView.alpha = [opacity.toValue doubleValue];
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path,NULL,self.beginSticker.center.x, self.beginSticker.center.y);
        CGPathAddCurveToPoint(path,NULL,
                              self.beginSticker.center.x, self.beginSticker.center.y,
                              self.beginSticker.center.x + 45, self.beginSticker.center.y,
                              self.stickerPreviewConverted.center.x, self.stickerPreviewConverted.center.y);
        
        self.previewStickerPath = path;
        
        CAKeyframeAnimation *stickerPosition;
        stickerPosition = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        stickerPosition.path = self.previewStickerPath;
        stickerPosition.duration = kSCRPreviewBeginDismissAnimationDuration;
        
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform"];
        scale.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        self.stickerScaleFactor = (self.beginSticker.frame.size.width/self.stickerPreviewConverted.frame.size.width);
        scale.toValue =   [NSValue valueWithCATransform3D:CATransform3DMakeScale(1 + self.stickerScaleFactor, 1 + self.stickerScaleFactor, 1.0)];
        
        
        CAAnimationGroup* group = [CAAnimationGroup animation];
        group.animations = [NSArray arrayWithObjects:stickerPosition, scale, nil];
        group.duration = kSCRPreviewBeginDismissAnimationDuration;
        group.delegate = self.bodyCollectionViewController;
        [group setValue:self.beginSticker.layer forKey:@"stickerLayer"];

        [self.beginSticker.layer addAnimation:group forKey:@"stickerChanges"];
        self.beginSticker.layer.position = self.stickerPreviewConverted.center;
        self.beginSticker.layer.transform = [scale.toValue CATransform3DValue];
    }
    [CATransaction commit];
}

- (void)dismissPreview
{
    NSLog(@"dismissPreview indexPathsForVisibleItems: %@", [self.bodyCollectionViewController.collectionView indexPathsForVisibleItems]);
    
    NSUInteger dismissStickerIndex = [[[self.bodyCollectionViewController.collectionView indexPathsForVisibleItems] objectAtIndex:0] row];
    
    UIImage *dismissSticker = [UIImage imageNamed:@"AppIcon"];

    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake([[self.previewItems objectAtIndex:dismissStickerIndex] initialStickerLocation].x, [[self.previewItems objectAtIndex:dismissStickerIndex] initialStickerLocation].y, dismissSticker.size.width, dismissSticker.size.height)];
    [iv setImage:dismissSticker];
    self.dismissSticker = iv;
    self.stickerDismissConverted = [[UIView alloc] initWithFrame:[self.dismissSticker convertRect:self.dismissSticker.bounds toView:self.view]];
    [self.view addSubview:self.dismissSticker];

    [CATransaction setCompletionBlock:^{
        [[self presentingViewController] dismissViewControllerAnimated:NO completion:NULL];
    }];
    [CATransaction begin];
    {
        CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacity.fromValue = [NSNumber numberWithFloat:1.0];
        opacity.toValue = [NSNumber numberWithFloat:0.0];
        opacity.additive = NO;
        opacity.removedOnCompletion = NO;
        opacity.duration = kSCRPreviewBeginDismissAnimationDuration;
        
        [self.blurView.layer addAnimation:opacity forKey:@"visualEffectChanges"];
        self.blurView.alpha = (CGFloat)[opacity.toValue doubleValue];
        
        [self.bodyCollectionViewController.view.layer addAnimation:opacity forKey:@"visualEffectChanges"];
        self.bodyCollectionViewController.view.alpha = (CGFloat)[opacity.toValue doubleValue];

        CAKeyframeAnimation *stickerPosition;
        stickerPosition = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path,NULL,self.stickerPreviewConverted.center.x, self.stickerPreviewConverted.center.y);
        CGPathAddCurveToPoint(path,NULL,
                              self.stickerPreviewConverted.center.x, self.stickerPreviewConverted.center.y,
                              self.stickerPreviewConverted.center.x + 45, self.stickerPreviewConverted.center.y,
                              self.dismissSticker.center.x, self.dismissSticker.center.y);

        stickerPosition.path = path;
        stickerPosition.duration = kSCRPreviewBeginDismissAnimationDuration;

        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform"];
        scale.fromValue =   [NSValue valueWithCATransform3D:CATransform3DMakeScale(1 + self.stickerScaleFactor, 1 + self.stickerScaleFactor, 1.0)];
        scale.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        [self.bodyCollectionViewController.view.layer addAnimation:opacity forKey:@"visualEffectChanges"];
        self.bodyCollectionViewController.view.alpha = [opacity.toValue doubleValue];

        CAAnimationGroup* group = [CAAnimationGroup animation];
        group.animations = [NSArray arrayWithObjects:stickerPosition, scale, nil];
        group.duration = kSCRPreviewBeginDismissAnimationDuration;
        
        [self.dismissSticker.layer addAnimation:group forKey:@"stickerChanges"];
        self.dismissSticker.layer.position = self.stickerStartConverted.center;
        self.dismissSticker.layer.transform = [scale.toValue CATransform3DValue];

    }
    [CATransaction commit];
    
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
