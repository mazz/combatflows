//
//  SCRFlowContentViewController.m
//  scrappling
//
//  Created by Michael Hanna on 2015-06-01.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "CMALesson.h"
#import "EBCardCollectionViewLayout.h"
#import "IAHInAppPurchaseHelper.h"
#import "MAZTableViewCell.h"
#import "SCRFlowContentCollectionViewCell.h"
#import "SCRFlowContentViewController.h"
#import "SCRGraphicGuideCardInfoTableViewCell.h"
#import "SCRHorizontalCardTableViewCell.h"
#import "SCRMultilineTableViewCell.h"
//#import "SCRPlayerViewController.h"
#import "THPlayerViewController.h"
#import "UIColor+ILSColor.h"
#import "UIImage+Scaling.h"
#import "UILabel+AutoLayout.h"
#import "UIView+AutoLayout.h"
#import "UIView+Debug.h"
#import "UIView+FLKAutoLayout.h"
#import "Util.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <Google/Analytics.h>
#import "SCRConstants.h"
#import "SCRReachabilityService.h"

#define FLKPredicate(x) [NSString stringWithFormat:@"%d", x]

static NSString* kSCRFlowContentViewTableViewCellMultilineIdentifier = @"kSCRFlowContentViewTableViewCellMultilineIdentifier";
static NSString* kSCRFlowContentViewTableViewCellGraphicCollectionIdentifier = @"kSCRFlowContentViewTableViewCellGraphicCollectionIdentifier";
static NSString* kSCRFlowContentViewPlaybackSegue = @"playbackSegue";

NSInteger kSCRFlowContentTeachingLessonIndex = 0;
NSInteger kSCRFlowContentApplicationLessonIndex = 1;
NSInteger kSCRFlowContentGraphicGuideLessonIndex = 2;

@interface SCRFlowContentViewController () <UITableViewDelegate, UITableViewDataSource> //,SCRFlowContentParentTableViewDelegate>
//@property (nonatomic, strong) THPlayerViewController* playerViewController;
//@property (weak, nonatomic) IBOutlet UIView* titleBox;
@property (strong, nonatomic) UILabel* titleLabel;
@property (strong, nonatomic) UILabel* overviewTextLabel;
//@property (strong, nonatomic) UILabel *downloadedLabel;
@property (strong, nonatomic) UIButton* playTeachingButton;
@property (strong, nonatomic) UIButton* playApplicationButton;
@property (strong, nonatomic) UIButton* playGraphicGuideButton;
//@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
//@property (strong, nonatomic) IBOutlet UIImageView *titleBoxBackgroundImage;

// view content begin   //
//@property (weak, nonatomic) IBOutlet UIView* playbackButtonBox;
@property (strong, nonatomic) UIView* headerWrapperView;
@property (strong, nonatomic) UITableView* allContentTableView;
@property (nonatomic, strong) LoremIpsum* lorem;
@property (strong, nonatomic) UILabel* guideInstructionLabel;
@property (strong, nonatomic) UICollectionView* contentCollectionView;
//@property (strong, nonatomic) NSArray* contentCollectionImages;
// view content end     //

@property (nonatomic) NSInteger currentLessonIndex;
@property (nonatomic, strong) AVQueuePlayer* player;
@end

@implementation SCRFlowContentViewController

NSUInteger kBannersPerLesson = 2;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lorem = [[LoremIpsum alloc] init];


//    NSMutableArray* mutCards = [@[] mutableCopy];
//    
//    for (NSUInteger i = 1; i < self.flow.cardPaths.count; i = i + 2) {
//        NSString* cardPath = [[[IAHInAppPurchaseHelper sharedInstance] purchasedContentPath] stringByAppendingPathComponent:self.flow.cardPaths[i]];
//        UIImage *card = [[UIImage alloc] initWithContentsOfFile:cardPath];
//        
//        [mutCards addObject:card];
//    }
    
//    self.contentCollectionImages = [mutCards copy];

    // ~~ table view
    self.allContentTableView = [[UITableView alloc] init];
    self.allContentTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.allContentTableView];

    [self.allContentTableView alignLeadingEdgeWithView:self.view predicate:FLKPredicate(0)];
    [self.allContentTableView alignTrailingEdgeWithView:self.view predicate:FLKPredicate(0)];
    [self.allContentTableView alignBottomEdgeWithView:self.view predicate:FLKPredicate(0)];
    //    [self.allContentTableView constrainTopSpaceToView:self.view predicate:FLKPredicate(10)];
    [self.allContentTableView alignTopEdgeWithView:self.view predicate:FLKPredicate(0)];

    self.allContentTableView.delegate = self;
    self.allContentTableView.dataSource = self;

    [self.allContentTableView registerClass:[SCRMultilineTableViewCell class] forCellReuseIdentifier:kSCRFlowContentViewTableViewCellMultilineIdentifier];
    [self.allContentTableView registerClass:[MAZTableViewCell class] forCellReuseIdentifier:@"MAZTableViewCell"];
    [self.allContentTableView registerClass:[SCRGraphicGuideCardInfoTableViewCell class] forCellReuseIdentifier:@"SCRGraphicGuideCardInfoTableViewCell"];
    [self.allContentTableView registerClass:[SCRHorizontalCardTableViewCell class] forCellReuseIdentifier:kSCRFlowContentViewTableViewCellGraphicCollectionIdentifier];
    [self.allContentTableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([UITableViewHeaderFooterView class])];

    //        self.allContentTableView.estimatedRowHeight = 144.0;
    //        self.allContentTableView.rowHeight = UITableViewAutomaticDimension;
    //    self.allContentTableView.bounces = NO;
    [self.allContentTableView reloadData];
    self.allContentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.allContentTableView.backgroundColor = UIColor.clearColor;

    NSString* bannerPath = [[[IAHInAppPurchaseHelper sharedInstance] purchasedContentPath] stringByAppendingPathComponent:@"04-combatflow-1-graphicguidebanner@3x"];
    UIImage* scaledImage = [UIImage imageWithImage:[[UIImage alloc] initWithContentsOfFile:bannerPath] scaledToWidth:self.view.frame.size.width];
    UIImageView* headerImage = [[UIImageView alloc] initWithImage:scaledImage];
    [headerImage.layer setMinificationFilter:kCAFilterTrilinear];

    headerImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.headerWrapperView addSubview:headerImage];
    [self.headerWrapperView alignToView:headerImage];

    self.headerWrapperView = [[UIView alloc] initWithFrame:headerImage.frame];
    [self.headerWrapperView addSubview:headerImage];

    self.playTeachingButton = [[UIButton alloc] init];
    [self.playTeachingButton setImage:[UIImage imageNamed:@"gg_video_btn_vid"] forState:UIControlStateNormal];
    [self.headerWrapperView addSubview:self.playTeachingButton];

    //    [headerImage addSubview:self.playTeachingButton];
    [self.playTeachingButton alignLeadingEdgeWithView:self.headerWrapperView predicate:FLKPredicate(10)];
    [self.playTeachingButton alignBottomEdgeWithView:headerImage predicate:FLKPredicate(-10)];
    //    [self.playTeachingButton alignCenterWithView:headerImage];
    [self.playTeachingButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];

    self.playApplicationButton = [[UIButton alloc] init];
    [self.playApplicationButton setImage:[UIImage imageNamed:@"gg_video_btn_app"] forState:UIControlStateNormal];

    [self.headerWrapperView addSubview:self.playApplicationButton];
    [self.playApplicationButton constrainLeadingSpaceToView:self.playTeachingButton predicate:FLKPredicate(10)];
    [self.playApplicationButton alignBottomEdgeWithView:headerImage predicate:FLKPredicate(-10)];
    [self.playApplicationButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];

    self.playGraphicGuideButton = [[UIButton alloc] init];
    [self.playGraphicGuideButton setImage:[UIImage imageNamed:@"gg_video_btn_app"] forState:UIControlStateNormal];
    
    [self.headerWrapperView addSubview:self.playGraphicGuideButton];
    [self.playGraphicGuideButton constrainLeadingSpaceToView:self.playApplicationButton predicate:FLKPredicate(10)];
    [self.playGraphicGuideButton alignBottomEdgeWithView:headerImage predicate:FLKPredicate(-10)];
    [self.playGraphicGuideButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];

    
    
    //    [self.playTeachingButton alignCenterWithView:fakeHeaderView];
    //    self.allContentTableView.tableHeaderView = tableHeaderView;

    self.guideInstructionLabel = [UILabel newAutoLayoutLabel];
    self.guideInstructionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.guideInstructionLabel];

    //    CAGradientLayer *gradient = [CAGradientLayer layer];
    //    gradient.frame = self.titleBox.bounds;
    //    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor scrapplingForegroundBlueColor] CGColor], (id)[[UIColor colorWithWhite:0.9 alpha:1.0] CGColor], nil];
    //    [self.titleBox.layer insertSublayer:gradient atIndex:0];
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.headerWrapperView.frame.size.height;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView* header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([UITableViewHeaderFooterView class])];
    if (section == 0) {
        [header.contentView addSubview:self.headerWrapperView];
    }
    return header;
}

//- (void)scrollViewDidScroll:(UIScrollView*)scrollView
//{
//    CGFloat trim = self.headerWrapperView.frame.size.height - self.allContentTableView.contentOffset.y;
////    DDLogDebug(@"contentOffset.y: %f", self.allContentTableView.contentOffset.y);
////    DDLogDebug(@"size.height: %f", self.headerWrapperView.frame.size.height);
//
////    DDLogDebug(@"trim: %f", trim);
//    if (trim > 39.0 && trim < self.headerWrapperView.frame.size.height) {
////        DDLogDebug(@"trim inside: %f", trim);
//        //        self.allContentTableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
//        self.allContentTableView.contentInset = UIEdgeInsetsMake(-self.allContentTableView.contentOffset.y, 0, 0, 0);
//        // setting the contentOffset to itself allows us to render the new contentInset WITHOUT needing to -reloadData!
//        self.allContentTableView.contentOffset = self.allContentTableView.contentOffset;
//    }
//}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell;
    if (indexPath.row == 3) {
        cell = (SCRHorizontalCardTableViewCell*)[self cellForIndexPath:indexPath];
    }
    else {
        cell = (MAZTableViewCell*)[self cellForIndexPath:indexPath];
    }
//        MAZTableViewCell *cell = (MAZTableViewCell *)[self cellForIndexPath:indexPath];
//        [UIView colorViewsRandomly:cell.contentView];
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat height;
    if (indexPath.row == 3) {
        height = 200.0;
    }
    else {
        MAZTableViewCell* cell = (MAZTableViewCell*)[self cellForIndexPath:indexPath];

        // Get the actual height required for the cell
        height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

        // Add an extra point to the height to account for the cell separator, which is added between the bottom
        // of the cell's contentView and the bottom of the table view cell.
        height += 1;
    }

    return height;
}

- (UITableViewCell*)cellForIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell;
    if (indexPath.row < 3) {
        MAZTableViewCell* cell = [self.allContentTableView dequeueReusableCellWithIdentifier:@"MAZTableViewCell"];
        if (indexPath.row == 0) {
            //            cell.bodyLabel.text = self.tableData[indexPath.row][@"body"];
            //            cell.bodyLabel.text =
            cell.bodyLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
            cell.bodyLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Overview", @""), self.flow.name];
            cell.bodyLabel.textColor = UIColor.whiteColor;
//            cell.bodyLabel.textAlignment = NSTextAlignmentCenter;
        }
        else if (indexPath.row == 1) {
            //            cell.bodyLabel.text = self.tableData[indexPath.row][@"body"];
            NSLayoutConstraint* topMarginConstraint = cell.topMarginConstraints[0];
            topMarginConstraint.constant = 0;

            cell.bodyLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
            cell.bodyLabel.text = self.flow.flowGroup.text;
            cell.bodyLabel.textColor = UIColor.whiteColor;
//            cell.bodyLabel.textAlignment = NSTextAlignmentCenter;

            NSLayoutConstraint* bottomMarginConstraint = cell.bottomMarginConstraints[0];
            bottomMarginConstraint.constant = 0;
        }
        else if (indexPath.row == 2) {
            //            NSLayoutConstraint *topMarginConstraint  = cell.topMarginConstraints[0];
            //            topMarginConstraint.constant = 0;
            cell.bodyLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
            cell.bodyLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Flow 0%lld: Graphic Guide", @""), self.flow.nominal.integerValue];
        }

        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.allContentTableView.bounds), CGRectGetHeight(cell.bounds));
        return cell;
    }
    else if (indexPath.row == 3) {
        SCRHorizontalCardTableViewCell* cell = [self.allContentTableView dequeueReusableCellWithIdentifier:kSCRFlowContentViewTableViewCellGraphicCollectionIdentifier];
        //        cell.delegate = self;
        //        cell.bodyLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        //        cell.bodyLabel.text = @"Flow Title";
        return cell;
    }
    else if (indexPath.row == 4) {
        SCRGraphicGuideCardInfoTableViewCell* cell = [self.allContentTableView dequeueReusableCellWithIdentifier:@"SCRGraphicGuideCardInfoTableViewCell"];

        NSUInteger found = [self.flow.flowGroup.flows indexOfObjectIdenticalTo:self.flow];
        if (found != NSNotFound) {
            cell.instructions = self.flow.flowGroup.graphicGuideTitles[found];
            cell.instructionLabel.text = cell.instructions[cell.pageControl.currentPage];
            cell.instructionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
        }
        //            cell.instructionLabel.text = [self.lorem words:arc4random() % 4 + 1];
        cell.pageControl.numberOfPages = [self.flow.flowGroup.graphicGuideTitles[found] count];
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.allContentTableView.bounds), CGRectGetHeight(cell.bounds));
        return cell;
    }
    return cell;
}

- (BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    return NO;
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(SCRHorizontalCardTableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    cell.backgroundColor = UIColor.clearColor;
    if (indexPath.row == 3) {
        [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
    }
}

//- (void)graphicGuidePageChange:(NSNotification *)note
//{
////    [self.allContentTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:4 inSection:0]] withRowAnimation:UITableViewRowAnimationNone]; // update the row with the page control
//}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;//self.contentCollectionImages.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    SCRFlowContentCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SCRFlowContentCollectionViewCell" forIndexPath:indexPath];
//    cell.mainImageView.image = self.contentCollectionImages[indexPath.row];
//    [cell setNeedsUpdateConstraints];
//    [cell updateConstraintsIfNeeded];

    return cell;
}

#pragma mark AVPlayerViewController

- (IBAction)play:(id)sender
{
    if (sender == self.playTeachingButton) {
        [self setCurrentLessonIndex:kSCRFlowContentTeachingLessonIndex];
    }
    else if (sender == self.playApplicationButton) {
        [self setCurrentLessonIndex:kSCRFlowContentApplicationLessonIndex];
    }
    else if (sender == self.playGraphicGuideButton) {
        [self setCurrentLessonIndex:kSCRFlowContentGraphicGuideLessonIndex];
    }
    CMALesson * lesson = self.flow.lessons[self.currentLessonIndex];
    
    //    [self doPlaybackWithLesson:[self currentLesson]];
    
    
    NSString *formatter = @"%@ - Flow %d";
    NSString *displayString = [NSString stringWithFormat:NSLocalizedString(formatter, @""), self.flow.name, self.flow.nominal.integerValue];
    NSString *trackingString = [NSString stringWithFormat:formatter, self.flow.name, (long)self.flow.nominal.integerValue];
    // kGAIEventCategoryWatchVideo
    //    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // track connection type
    
    NSString *connection = @"unknown";
    if (![[SCRReachabilityService sharedInstance] isOffline]) {
        if ([[SCRReachabilityService sharedInstance] isCellular]) {
            connection = @"cellular";
        } else {
            connection = @"wifi";
        }
    } else {
        connection = @"offline";
    }
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:kGAIEventCategoryWatchVideo
                                                                                        action:kGAIEventActionWatchVideoConnectionType
                                                                                         label:connection
                                                                                         value:nil] build]];
    
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:kGAIEventCategoryWatchVideo
                                                          action:trackingString
                                                           label:lesson.filename
                                                           value:nil] build]];

    
    
    [self performSegueWithIdentifier:kSCRFlowContentViewPlaybackSegue sender:sender];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSURL *url = [self assetURLForLesson:self.flow.lessons[self.currentLessonIndex]]; ;//(sender == self.playTeachingButton) ? self.localURL : self.streamingURL;
    THPlayerViewController *controller = [segue destinationViewController];
    controller.assetURL = url;
}

//- (void)doPlaybackWithLesson:(CMALesson*)l_
//{
//    //    self.player = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObject:[self playerItemForLesson:l_]]];
//
////    self.playerViewController = [[THPlayerViewController alloc] initWithAssetURL:[self assetURLForLesson:l_]];
//    
//    NSString *formatter = @"%@ - Flow %d";
//    NSString *displayString = [NSString stringWithFormat:NSLocalizedString(formatter, @""), self.flow.name, self.flow.nominal.integerValue];
//    NSString *trackingString = [NSString stringWithFormat:formatter, self.flow.name, (long)self.flow.nominal.integerValue];
//    // kGAIEventCategoryWatchVideo
////    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    
//    // track connection type
//    
//    NSString *connection = @"unknown";
//    if (![[SCRReachabilityService sharedInstance] isOffline]) {
//        if ([[SCRReachabilityService sharedInstance] isCellular]) {
//            connection = @"cellular";
//        } else {
//            connection = @"wifi";
//        }
//    } else {
//        connection = @"offline";
//    }
//    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:kGAIEventCategoryWatchVideo
//                                                                                        action:kGAIEventActionWatchVideoConnectionType
//                                                                                         label:connection
//                                                                                         value:nil] build]];
//
//    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:kGAIEventCategoryWatchVideo
//                                                          action:trackingString
//                                                           label:l_.filename
//                                                           value:nil] build]];
//
//    
////    self.playerViewController.title = displayString;
////
////    [self presentViewController:self.playerViewController animated:YES completion:^{
////        //        UILabel *label = [[UILabel alloc] init];
////        //        label.text = @"TEST";
////        //        label.textColor = UIColor.whiteColor;
////        //        [label sizeToFit];
////        //        [self.playerViewController.contentOverlayView addSubview:label];
////        //        [label alignCenterWithView:self.playerViewController.contentOverlayView];
////        //        DDLogDebug(@"complete");
////    }];
//}

- (NSURL*)assetURLForLesson:(CMALesson*)lesson
{
    NSString* path = [NSString stringWithFormat:@"%@/%@", [[IAHInAppPurchaseHelper sharedInstance] purchasedContentPath], [lesson filename]];
    //scr_bpd_fl01_teach_4_4s.m4v
    return [NSURL fileURLWithPath:path];
}
//- (AVPlayerItem*)playerItemForLesson:(CMALesson*)lesson
//{
//
//    NSString* path = [NSString stringWithFormat:@"%@/%@", [[IAHInAppPurchaseHelper sharedInstance] purchasedContentPath], [lesson filename]];
//
//    //scr_bpd_fl01_teach_4_4s.m4v
//    AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
//    //    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"scr_bpd_fl01_teach_4_4s" withExtension:@"m4v"] options:nil];
//    AVPlayerItem* item = [[AVPlayerItem alloc] initWithAsset:asset];
//    if (item != nil) {
//        //
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(playerItemDidReachEnd:)
//                                                     name:AVPlayerItemDidPlayToEndTimeNotification
//                                                   object:item];
//    }
//
//    return item;
//}

//- (void)playerItemDidReachEnd:(NSNotification*)notification
//{
//    DDLogDebug(@"reached the end of %@", notification);
//
//    NSString* title = ([self.currentLesson lessonType] == kCMATeaching) ? NSLocalizedString(@"Teaching", @"") : ([self.currentLesson lessonType] == kCMAApplication) ? NSLocalizedString(@"Application", @"") : @"";
//    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    UIAlertAction* actionReplay = [UIAlertAction actionWithTitle:NSLocalizedString(@"Replay", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
//        [self.player removeAllItems];
//
//        AVPlayerItem* p = [notification object];
//        [p seekToTime:kCMTimeZero];
//
//        [self.player insertItem:p afterItem:nil];
//    }];
//
//    AVPlayerItem* alternateItem = nil;
//    NSString* alternateTitle;
//    if ([self.currentLesson lessonType] == kCMATeaching) {
//        alternateTitle = NSLocalizedString(@"Application", @"");
//        [self setCurrentLesson:self.flow.lessons[kCMAApplication]];
//        alternateItem = [self playerItemForLesson:self.currentLesson];
//    }
//    else if ([self.currentLesson lessonType] == kCMAApplication) {
//        alternateTitle = NSLocalizedString(@"Teaching", @"");
//        [self setCurrentLesson:self.flow.lessons[kCMATeaching]];
//        alternateItem = [self playerItemForLesson:self.currentLesson];
//    }
//
//    UIAlertAction* actionPlayAlternateLesson = [UIAlertAction actionWithTitle:alternateTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
//        [self.player removeAllItems];
//        [alternateItem seekToTime:kCMTimeZero];
//        [self.player insertItem:alternateItem afterItem:nil];
//    }];
//
//    UIAlertAction* actionGraphicGuide = [UIAlertAction actionWithTitle:NSLocalizedString(@"Graphic Guide", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
//        [self.playerViewController dismissViewControllerAnimated:YES completion:nil];
//    }];
//
//    [alertController addAction:actionReplay];
//    [alertController addAction:actionPlayAlternateLesson];
//    [alertController addAction:actionGraphicGuide];
//    [self.playerViewController presentViewController:alertController animated:YES completion:nil];
//
//    //    AVQueuePlayer *qp = [self.players objectAtIndex:[self.playerItems indexOfObjectIdenticalTo:[notification object]]];
//    //    [qp removeAllItems];
//    //
//    //    AVPlayerItem *p = [notification object];
//    //    [p seekToTime:kCMTimeZero];
//    //
//    //    [qp insertItem:p afterItem:nil];
//}

@end
