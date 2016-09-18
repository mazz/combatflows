//
//  SCRSocialViewController.m
//
//  Created by Michael Hanna on 2016-02-04.
//  Copyright © 2016 ils. All rights reserved.
//

#import "SCRSocialViewController.h"
#import <Accounts/ACAccountStore.h>
#import <Accounts/ACAccountType.h>
#import <Social/Social.h>
#import "SCRSociallAccountsViewController.h"
#import "SCROverlayTransitioningDelegate.h"

@interface SCRSocialViewController () <SCRSocialAccountsViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *followUsOnLabel;
@property (strong, nonatomic) IBOutlet UIButton *twitterButton;
@property (strong, nonatomic) IBOutlet UIButton *followSuccessButton;
@property (strong, nonatomic) IBOutlet UILabel *pleaseTryAgainLaterLabel;
@property (strong, nonatomic) UIAlertController *alertController;
@property (strong, nonatomic) SCROverlayTransitioningDelegate *overlayTransitioningDelegate;
@end

@implementation SCRSocialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.twitterButton.layer.cornerRadius = 9.0;
    self.twitterButton.layer.masksToBounds = YES;
}

- (IBAction)followUsOnTwitter:(id)sender {
    
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SCRSociallAccountsViewController *socialAccountsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SCRSociallAccountsViewController"];
                        socialAccountsViewController.accounts = [accountStore accountsWithAccountType:accountType];
                        socialAccountsViewController.delegate = self;
                        socialAccountsViewController.modalPresentationStyle = UIModalPresentationCustom;
                        socialAccountsViewController.transitioningDelegate = self.overlayTransitioningDelegate;
                        
                        //                                        [detailViewController setFlowGroup:[[[CMACurriculum sharedCurriculum] flowGroupsSortedByNumber] objectAtIndex:idx]];
                        [self presentViewController:socialAccountsViewController animated:YES completion:nil];
                        //                    self.promoContentProduct = product;
                    });
                }
                else
                {
                    ACAccount *firstAccount = [[accountStore accountsWithAccountType:accountType] objectAtIndex:0];
                    if (firstAccount != nil)
                    {
                        [self doFollow:firstAccount];
//                        self.promoContentProduct = product;
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Alert view controller title") message:NSLocalizedString(@"There was a problem when attempting to access a Twitter account.", @"") preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                            [self.alertController addAction:actionOK];
                            [self presentViewController:self.alertController animated:YES completion:nil];
                        });
                    }
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Alert view controller title") message:NSLocalizedString(@"A twitter account could not be found.", @"") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [self.alertController addAction:actionOK];
                    [self presentViewController:self.alertController animated:YES completion:nil];
                });
            }
        }
    }];

}

- (void)accountWasSelected:(ACAccount *)selectedAccount
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self doFollow:selectedAccount];
    });
}

- (void)doFollow:(ACAccount *)account
{
    // http://stackoverflow.com/questions/18664519/acaccountstore-trying-to-follow-on-twitter-410-error
    NSDictionary *parameters = @{@"screen_name" : @"combatmma",
                                 @"follow" : @"true"};
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"] parameters:parameters];
    [postRequest setAccount:account];
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                if (urlResponse.statusCode != 200) {
                    self.pleaseTryAgainLaterLabel.hidden = NO;
                }
                else {
                    self.followSuccessButton.hidden = NO;
                }
            } else {
                self.pleaseTryAgainLaterLabel.hidden = NO;
            }
        });
    }];
}

@end
