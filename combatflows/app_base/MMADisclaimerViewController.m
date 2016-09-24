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
@property (weak, nonatomic) IBOutlet UILabel *disclaimerContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIImageView *disclaimerOnImage;
@property (weak, nonatomic) IBOutlet UIImageView *disclaimerOffImage;

@end

@implementation MMADisclaimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.disclaimerContentLabel.text = NSLocalizedString(@"The following is a legally binding agreement between you and the developer of this application (Interactive Learning Solutions Inc.). Please read it carefully.\n\n- By using and/or accessing this application, you acknowledge that you have read, understood, and agree to be bound by these terms and conditions and agree to comply with all applicable laws and regulations, including Federal, Provincial and/or State laws.\n\n- The techniques shown in the videos, clips and/or other recordings contained herein are for educational and entertainment purposes only.\n\n- By accepting below, you understand and acknowledge that you or your training partner may be injured, incur damages or even die if you apply or practise the techniques in this application.\n\n- Always consult a doctor first before attempting any physical activity as well as a qualified instructor that understands the physical demand and risks involved with training in the martial arts.\n\n- When applying any techniques, do so slowly, carefully and with control.  Release the hold immediately when your partner 'taps out' or tells you it is uncomfortable. Your training partner's safety is your responsibility.  Train only with people who will look out for your safety.\n\n- Attempt the techniques in this application at your own risk. The developer of this application and all other persons featured on this application, do not endorse and make no representation, warranty, guarantee, or claim regarding the accuracy, safety, effectiveness or legality of any technique illustrated, described, or demonstrated in this application.\n\n- Furthermore, the developer is not responsible in any manner whatsoever for any personal injury, damage or death that may occur from using the techniques or instructions contained in this application.  You therefore agree to hold harmless the developer, including but not limited to its agents, licensees, and officers for any action, suit, claim, loss, injury, or damage, arising from your negligence, recklessness, improper execution of the techniques, or for any damage, injury, or death that occurs pursuant to any information received, or misuse of the information contained in this application. In no event shall the developer be liable for any special, incidental, indirect or consequential damages of any kind, or any damages whatsoever, including without limitation, those resulting from reliance on the materials presented and any theory of liability, arising out of or in connection with the use of this application.\n\n- The developer may at any time revise these terms and conditions by updating this notice and/or the content in the application.  By using this application, you agree to be bound by any such revisions and should therefore periodically read this disclaimer, as amended, to determine the current terms and conditions of use for which you are bound.\n\nIf you do not agree to the terms and conditions of use as stated above, then please close and uninstall the application from your device. If you have read and accepted the terms and conditions above, then please press the button below to enter the application.\n\nI am at or above the legal age of majority and/or I have permission from a legal guardian to use this App. I have read and accept these terms and conditions of use.", @"");
//    self.disclaimerContentLabel.textColor = UIColor.combatFlowsConfetti;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kMMAUserDefaultsUserConsentedToApplicationUsageDisclaimer"] != nil)
    {
        [self.disclaimerOffImage setHidden:YES];
        [self.disclaimerOnImage setHidden:NO];
    }
}

- (IBAction)acceptTerms:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kMMAUserDefaultsUserConsentedToApplicationUsageDisclaimer"] == nil)
    {
        [self.disclaimerOnImage setHidden:NO];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"kMMAUserDefaultsUserConsentedToApplicationUsageDisclaimer"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
//        [[[[self view] window] rootViewController] dismissModalViewControllerAnimated:YES];
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(disclaimerWasAccepted)]) {
            [self.delegate disclaimerWasAccepted];
        }
    }
}

@end
