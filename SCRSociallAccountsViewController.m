//
//  SCRSociallAccountsViewController.m
//  scrappling
//
//  Created by Michael Hanna on 2015-06-16.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCRSociallAccountsViewController.h"
#import "SCROverlayPresentationController.h"
//#import "SCRYoinkPresentationAnimationController.h"

@interface SCRSociallAccountsViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation SCRSociallAccountsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.layer.cornerRadius = 9.0;
    self.view.layer.shadowColor = UIColor.blackColor.CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0, 0);
    self.view.layer.shadowRadius = 10;
    self.view.layer.shadowOpacity = 0.5;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.accounts count];
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
    
    ACAccount *account = self.accounts[indexPath.row];
    cell.textLabel.text = account.username;
//    CMALesson *lesson = [[[[self.flowGroup flows] objectAtIndex:indexPath.section] lessons] objectAtIndex:indexPath.row];
//    [cell.detailTextLabel setText:@"TODO: lesson name here"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(accountWasSelected:)])
    {
        [self.delegate accountWasSelected:self.accounts[indexPath.row]];
    }
    [self dismiss:nil];
}


//- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
//{
//    if (presented == self)
//    {
//        return [[SCRDimmingInsetPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
//    }
//    return nil;
//}
//
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
//{
//    if (presented == self)
//    {
//        return [[SCRYoinkPresentationAnimationController alloc] initWithPresenting:YES];
//    }
//    return nil;
//}
//
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
//{
//    if (dismissed == self)
//    {
//        return [[SCRYoinkPresentationAnimationController alloc] initWithPresenting:NO];
//    }
//    else
//    {
//        return nil;
//    }
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
