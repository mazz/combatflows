//
//  SCPFlowGroupTableViewController.m
//  scrappling
//
//  Created by Michael Hanna on 2014-11-08.
//  Copyright (c) 2014 ils. All rights reserved.
//

#import "SCRFlowGroupTableViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
//#import "SCRPlayerViewController.h"
#import "IAHInAppPurchaseHelper.h"

@interface SCRFlowGroupTableViewController ()
@property (nonatomic, strong) AVPlayerViewController *playerViewController;
@end

@implementation SCRFlowGroupTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
//    self.playerViewController = [[SCRPlayerViewController alloc] init];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.flowGroup flows] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CMAFlow *flow = [[self.flowGroup flows] objectAtIndex:section];
    return [[flow lessons] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *flowString = NSLocalizedString(@"FLOW 0%d", @"");
    return [NSString stringWithFormat: flowString, section+1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForIndexPath:indexPath];
    //    }
    return cell;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CMAFlowGroup *group = [[[CMACurriculum sharedCurriculum] flowGroupsSortedByNumber] objectAtIndex:[indexPath row]];
//    
//    //    if ([[NSUserDefaults standardUserDefaults] boolForKey:[group _productIdentifier]])
//    //    {
////    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
////    //    }
////    cell.backgroundColor = [UIColor scrapplingBackgroundBlueColor];
//}

- (UITableViewCell *)cellForIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
//    cell.textLabel.text = @"foo";
    
    cell.textLabel.text = [self.flowGroup name];
    CMALesson *lesson = [[[[self.flowGroup flows] objectAtIndex:indexPath.section] lessons] objectAtIndex:indexPath.row];
    [cell.detailTextLabel setText:@"TODO: lesson name here"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setCurrentLesson:[self lessonForIndexPath:indexPath]];
    [self doPlaybackWithLesson:[self currentLesson]];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    NSLog(@"reached the end of %@", notification);
//    AVQueuePlayer *qp = [self.players objectAtIndex:[self.playerItems indexOfObjectIdenticalTo:[notification object]]];
//    [qp removeAllItems];
//    
//    AVPlayerItem *p = [notification object];
//    [p seekToTime:kCMTimeZero];
//    
//    [qp insertItem:p afterItem:nil];
}

- (void)doPlaybackWithLesson:(CMALesson*)l_
{

    NSString *path = [NSString stringWithFormat:@"%@/%@",[[IAHInAppPurchaseHelper sharedInstance] purchasedContentPath], [l_ filename]];

//scr_bpd_fl01_teach_4_4s.m4v
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"scr_bpd_fl01_teach_4_4s" withExtension:@"m4v"] options:nil];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
    if (item != nil)
    {
        //
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:item];
    }
    
    AVQueuePlayer *p = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObject:item]];
    [self.playerViewController setPlayer:p];
    p.allowsExternalPlayback = YES;
    p.usesExternalPlaybackWhileExternalScreenIsActive = YES;
    [p seekToTime:kCMTimeZero];
    [p play];
    
    
    [self presentViewController:self.playerViewController animated:YES completion:^{
        NSLog(@"complete");
    }];
    
}

- (CMALesson*)lessonForIndexPath:(NSIndexPath*)indexPath_
{
    CMAFlow *selectedFlow = [[_flowGroup flows] objectAtIndex:[indexPath_ section]];
    return [[selectedFlow lessons] objectAtIndex:[indexPath_ row]];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
