//
//  SCRMoreViewController.m
//  scrappling
//
//  Created by Michael Hanna on 2015-06-13.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCRMoreViewController.h"
#import "Util.h"
#import "UIView+FLKAutoLayout.h"
#import "UIView+Debug.h"
#import "UILabel+AutoLayout.h"
#import "UIView+AutoLayout.h"
#import "UIColor+ILSColor.h"
#import "SCRTitleBodyTableViewCell.h"
#import "SCRAboutUsViewController.h"
#import "SCRDedicationViewController.h"
#import "SCRSocialViewController.h"
#import "IAHInAppPurchaseHelper.h"

@interface SCRMoreViewController () <UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NSArray *rowImages;
@property (nonatomic, strong) LoremIpsum *lorem;
@property (strong, nonatomic) UIAlertController *alertController;
@end

#define FLKPredicate(x) [NSString stringWithFormat:@"%d", x]

static NSString *kSCRTitleBodyTableViewCell = @"kSCRTitleBodyTableViewCell";

@implementation SCRMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lorem = [[LoremIpsum alloc] init];
    self.tableData = @[
                       @{@"title": NSLocalizedString(@"About Us", @""), @"body": NSLocalizedString(@"Find out who we are and what drives us to build the best training apps for you.", @"")},
                       @{@"title": NSLocalizedString(@"Dedication", @""), @"body": NSLocalizedString(@"We owe our success to those who helped us along in our journey.", @"")},
//                       @{@"title": NSLocalizedString(@"Combat MMA Apps", @""), @"body": NSLocalizedString(@"Discover more of our training apps we offer comprehensive MMA training.", @"")},
                       @{@"title": NSLocalizedString(@"Social", @""), @"body": NSLocalizedString(@"Follow us and keep us with the latest deals and info on new and current apps.", @"")},
//                       @{@"title": NSLocalizedString(@"Help Guide", @""), @"body": NSLocalizedString(@"Go through our help guide to understand all the best features of our CombatMMA Apps", @"")},
                       @{@"title": NSLocalizedString(@"Disclaimer", @""), @"body": NSLocalizedString(@"This is our comprehensive agreement between our users and our training apps.", @"")},
//                       @{@"title": NSLocalizedString(@"Free PDF Training Guide", @""), @"body": NSLocalizedString(@"Get your free MMA warm up training guide for comprehensive muscle warm up exercises.", @"")},
                       @{@"title": NSLocalizedString(@"Restore", @""), @"body": NSLocalizedString(@"Restore your in-app purchases.", @"")}
                       ];
    
    self.rowImages = @[
                       [UIImage imageNamed:@"icn_more_about"],
                       [UIImage imageNamed:@"icn_more_dedication"],
//                       [UIImage imageNamed:@"icn_more_cmma_apps"],
                       [UIImage imageNamed:@"icn_more_social"],
//                       [UIImage imageNamed:@"icn_more_help"],
                       [UIImage imageNamed:@"icn_more_disclaimer"],
//                       [UIImage imageNamed:@"icn_more_free"],
                       [UIImage imageNamed:@"icn_more_restore"]
                       ];
    
    // ~~ table view
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    
    [self.tableView alignToView:self.view];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[SCRTitleBodyTableViewCell class] forCellReuseIdentifier:@"kSCRTitleBodyTableViewCell"];
    //    self.tableView.estimatedRowHeight = 144.0;
    //    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    self.tableView.bounces = NO;
    [self.tableView reloadData];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:10.0/255.0 blue:20.0/255.0 alpha:1.0];//[UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = (SCRTitleBodyTableViewCell *)[self cellForIndexPath:indexPath];
    //    MAZTableViewCell *cell = (MAZTableViewCell *)[self cellForIndexPath:indexPath];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
/*    CGFloat height;
    SCRTitleBodyTableViewCell *cell = (SCRTitleBodyTableViewCell *)[self cellForIndexPath:indexPath];
    
    // Get the actual height required for the cell
    height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    height += 1;
 */
    return 80.0;
}

- (UITableViewCell *)cellForIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell;
    SCRTitleBodyTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"kSCRTitleBodyTableViewCell"];
//    cell.backgroundColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0];

    cell.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
    cell.titleLabel.text = self.tableData[indexPath.row][@"title"];

    cell.bodyLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    cell.bodyLabel.text = self.tableData[indexPath.row][@"body"];
    cell.backgroundColor = UIColor.clearColor;
    [cell.button setImage:self.rowImages[indexPath.row] forState:UIControlStateNormal];

    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(cell.bounds));

        //            cell.bodyLabel.text =
//        cell.bodyLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Overview", @""), self.flow.name];
//    }

    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        SCRAboutUsViewController *aboutUsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SCRAboutUsViewController"];
        [self.navigationController pushViewController:aboutUsViewController animated:YES];
    }
    if (indexPath.row == 1) {
        SCRDedicationViewController *dedicationViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SCRDedicationViewController"];
        [self.navigationController pushViewController:dedicationViewController animated:YES];
    }
    if (indexPath.row == 2) {
        SCRSocialViewController *socialViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SCRSocialViewController"];
        [self.navigationController pushViewController:socialViewController animated:YES];
    }
    if (indexPath.row == 4) { // Restore downloads
//        [[IAHInAppPurchaseHelper sharedInstance] restoreDownloads];

        dispatch_async(dispatch_get_main_queue(), ^{

            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Restore all in-app purchases made with %@?", @""), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
            self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Restore Purchases", @"Alert view controller title") message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *actionRestore = [UIAlertAction actionWithTitle:NSLocalizedString(@"Restore", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[IAHInAppPurchaseHelper sharedInstance] restoreDownloads];
                });
            }];
            [self.alertController addAction:actionCancel];
            [self.alertController addAction:actionRestore];

            [self presentViewController:self.alertController animated:YES completion:nil];
        });
        
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != self.tableData.count-1)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.backgroundColor = UIColor.blackColor;// [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0];

    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
//    //    }
//    cell.backgroundColor = [UIColor scrapplingBackgroundBlueColor];
}

@end
