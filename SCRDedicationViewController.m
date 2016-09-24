//
//  SCRDedicationViewController.m
//  scrappling
//
//  Created by Michael Hanna on 2016-02-04.
//  Copyright © 2016 ils. All rights reserved.
//

#import "SCRDedicationViewController.h"
#import "UIColor+ILSColor.h"

@interface SCRDedicationViewController ()
@property (strong, nonatomic) IBOutlet UILabel *thisAppIsLabel;
@property (strong, nonatomic) IBOutlet UILabel *iWouldAlsoLike;

@end

@implementation SCRDedicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.thisAppIsLabel.text =  @"This App is dedicated to Makoto Kabayama, my inspiration in Jeet Kune Do and martial arts philosophy. It is also dedicated to the memory of Bruce Lee and Larry Hartsell.";
    self.thisAppIsLabel.textColor = UIColor.combatFlowsConfetti;
    self.iWouldAlsoLike.text = @"I would also like to thank the following for their involvement in the recording of the App.\n\nIlya Strashun\nBoris Zaytsev\nRicardo Vasquez\nRay Bennett\nTom Roniotis\nPatrick Roberts\n\nCheers and thanks for helping me continue to 'find my way'.\nPeter Chassikos";
    self.iWouldAlsoLike.textColor = UIColor.combatFlowsConfetti;
}

@end
