//
//  MMADisclaimerViewController.m
//  combatflows
//
//  Created by Michael Hanna on 2016-09-17.
//  Copyright © 2016 ilearningsolutions. All rights reserved.
//

#import "MMADisclaimerViewController.h"
#import "UIColor+ILSColor.h"

@interface MMADisclaimerViewController ()
@property (weak, nonatomic) IBOutlet UITextView *disclaimerTextView;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIImageView *disclaimerOnImage;
@property (weak, nonatomic) IBOutlet UIImageView *disclaimerOffImage;
@property BOOL acceptedConditions;

@end

@implementation MMADisclaimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.acceptedConditions = ([[NSUserDefaults standardUserDefaults] objectForKey:@"kMMAUserDefaultsUserConsentedToApplicationUsageDisclaimer"] != nil);
    [self.disclaimerOffImage setHidden:self.acceptedConditions];
    [self.disclaimerOnImage setHidden:!self.acceptedConditions];
    
    self.disclaimerTextView.backgroundColor = UIColor.clearColor;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView performWithoutAnimation:^{
            [self.disclaimerTextView scrollRangeToVisible:NSMakeRange(0, 0)];
        }];
    });
}

- (IBAction)acceptTerms:(id)sender {
    if (!self.acceptedConditions) {
        [self.disclaimerOnImage setHidden:self.acceptedConditions];
        [self.disclaimerOffImage setHidden:!self.acceptedConditions];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"kMMAUserDefaultsUserConsentedToApplicationUsageDisclaimer"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(disclaimerWasAccepted)]) {
            [self.delegate disclaimerWasAccepted];
        }
    }
}

@end
