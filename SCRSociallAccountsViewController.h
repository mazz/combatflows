//
//  SCRSociallAccountsViewController.h
//  scrappling
//
//  Created by Michael Hanna on 2015-06-16.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@protocol SCRSocialAccountsViewDelegate <NSObject>
- (void)accountWasSelected:(ACAccount *)selectedAccount;
@end

@interface SCRSociallAccountsViewController : UIViewController <UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, weak) id<SCRSocialAccountsViewDelegate> delegate;
@end
