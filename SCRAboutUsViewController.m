//
//  SCRAboutUsViewController.m
//  scrappling
//
//  Created by Michael Hanna on 2016-02-04.
//  Copyright © 2016 ils. All rights reserved.
//

#import "SCRAboutUsViewController.h"

@interface SCRAboutUsViewController ()
@property (strong, nonatomic) IBOutlet UILabel *combatmmaIsDedicatedLabel;
@property (strong, nonatomic) IBOutlet UIButton *urlButton;
@property (strong, nonatomic) IBOutlet UILabel *ourAppsAreIntendedLabel;
@property (strong, nonatomic) IBOutlet UILabel *weHaveAUniqueLabel;
@property (strong, nonatomic) IBOutlet UILabel *atCombatmmaLabel;
@property (strong, nonatomic) IBOutlet UILabel *bruceLeeQuoteLabel;

@end

@implementation SCRAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.combatmmaIsDedicatedLabel.text = @"Combat MMA is dedicated to providing you with cutting-edge martial arts training through a medium that can be taken anywhere.";
    [self.urlButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.urlButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.ourAppsAreIntendedLabel.text =  @"Our apps are intended for martial artists of all styles and levels of ability. These apps focus on continuity of technique or flow, and are different from (some say superior to) any other martial arts training apps that are currently available in the App Store.";
    self.weHaveAUniqueLabel.text = @"We have a unique user interface that allows for easy navigation, that also features a thumbnail preview of all martial arts techniques featured on the app (they all play at the same time-just click on the one you want to see full screen). Our videos are shot in HD and take advantage of the iPhone's retina display. With Airplay® built into these apps, you release the full viewing potential of the HD footage on your high definition television using Apple TV® (sold separately)";
    self.atCombatmmaLabel.text = @"At CombatMMA, we are inspired by those that seek constant improvement and those that strive for self perfection.";
    
    self.bruceLeeQuoteLabel.text = @"\"Use no way as way, and have no limitation as limitation\" - Bruce Lee";
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)gotoUrl:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.combatmma.ca/"]];
}

@end
