//
//  SCRMainViewController.m
//  scrappling
//
//  Created by Michael Hanna on 2015-06-13.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCRMainViewController.h"
#import "UIColor+ILSColor.h"
#import "SCRGetTrainedViewController.h"
#import "SCRFavoritesViewController.h"
#import "SCRMoreViewController.h"
#import "MMADisclaimerViewController.h"

@interface SCRMainViewController () <MMADisclaimerDelegate>
@property (weak, nonatomic) IBOutlet UIView *parentView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mainSegmentedControl;
@property (strong, nonatomic) NSArray *childViewControllers;
@property (nonatomic) NSUInteger selectedControllerIndex;
@property (strong, nonatomic) MMADisclaimerViewController *disclaimerViewController;
- (IBAction)segmentControlValueChanged:(id)sender;
@end

@implementation SCRMainViewController
{
    UIImageView *_navBarHairlineImageView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _navBarHairlineImageView.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.mainSegmentedControl setTintColor:UIColor.whiteColor];
    self.mainSegmentedControl.selectedSegmentIndex = 0;
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0],
                                                                      NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundColor:UIColor.blackColor];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSMutableArray *viewControllers = [NSMutableArray array];
    [viewControllers addObject:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SCRGetTrainedViewController"]];
    [viewControllers addObject:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SCRFavoritesViewController"]];
    [viewControllers addObject:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SCRMoreViewController"]];

    self.childViewControllers = [viewControllers copy];
    [self addChildViewController:self.childViewControllers[0]];
    [self.parentView addSubview:[self.childViewControllers[0] view]];
    [self.childViewControllers[0] view].frame = self.parentView.bounds;
    [self.childViewControllers[0] didMoveToParentViewController:self];

    _navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kMMAUserDefaultsUserConsentedToApplicationUsageDisclaimer"] == nil) {
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.disclaimerViewController = (MMADisclaimerViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"MMADisclaimerViewController"];
        self.disclaimerViewController.delegate = self;
        
        [self presentViewController:self.disclaimerViewController animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view
{
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0)
    {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews)
    {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView)
        {
            return imageView;
        }
    }
    return nil;
}

- (IBAction)segmentControlValueChanged:(id)sender
{
    UIViewController *originalViewController = [self.childViewControllers objectAtIndex:[self selectedControllerIndex]];
    UIViewController *destinationViewController = [self.childViewControllers objectAtIndex:[[self mainSegmentedControl] selectedSegmentIndex]];
    [[originalViewController view] removeFromSuperview];
    [originalViewController removeFromParentViewController];
    
    [self addChildViewController:destinationViewController];
    [self.parentView addSubview:[destinationViewController view]];
    [destinationViewController view].frame = self.parentView.bounds;
    [destinationViewController didMoveToParentViewController:self];
    DDLogDebug(@"destinationViewController: %@", NSStringFromClass([destinationViewController class]));
    
    self.selectedControllerIndex = self.mainSegmentedControl.selectedSegmentIndex;
    
    //    for (int i = 0; i < self.childViewControllers.count; i++)
    //    {
    //        [self.childViewControllers[i] view].hidden = YES;
    //    }
    //    [self.childViewControllers[self.flowSegmentedControl.selectedSegmentIndex] view].hidden = NO;
}

#pragma mark MMADisclaimerDelegate

- (void)disclaimerWasAccepted {
    [self.disclaimerViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
