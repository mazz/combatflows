//
//  CMAIntroMovieViewController.m
//  scrappling
//
//  Created by Michael Hanna on 2016-05-24.
//  Copyright © 2016 ils. All rights reserved.
//

#import "CMAMovieViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface CMAMovieViewController ()

@end

@implementation CMAMovieViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"appintro_sequence_retina4" ofType:@"m4v"]]];
    [self.player play];
}

- (NSUInteger)supportedInterfaceOrientations
{
    // Do not return UIInterfaceOrientationPortrait
    return UIInterfaceOrientationMaskPortrait;
}

@end
