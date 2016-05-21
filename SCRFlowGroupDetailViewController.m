//
//  SCRFlowGroupDetailViewController.m
//  scrappling
//
//  Created by Michael Hanna on 2015-05-21.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCRFlowGroupDetailViewController.h"
#import "UIColor+ILSColor.h"
#import "SCRFlowContentViewController.h"

@interface SCRFlowGroupDetailViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *flowSegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *parentView;
@property (strong, nonatomic) NSArray *childViewControllers;
@property (nonatomic) NSUInteger selectedControllerIndex;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentControlViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentControlTopMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentControlBottomMarginConstraint;
@property (strong, nonatomic) IBOutlet UIView *segmentedControlBox;
@property (strong, nonatomic) IBOutlet UILabel *singleFlowLabel;
- (IBAction)segmentControlValueChanged:(id)sender;
@end

@implementation SCRFlowGroupDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.segmentControlViewHeightConstraint.constant = 0;
    
    [self.flowSegmentedControl removeAllSegments];
    NSArray *flows = [self.flowGroup flows];
    
    NSMutableArray *viewControllers = [NSMutableArray array];
    self.singleFlowLabel.hidden = YES;// !(flows.count == 1);
    self.flowSegmentedControl.hidden = (flows.count == 1);

    for (NSUInteger i = 0; i < flows.count; i++)
    {
        [self.flowSegmentedControl insertSegmentWithTitle:[NSString stringWithFormat:@"Flow 0%lu", i+1] atIndex:i animated:NO];
        
        SCRFlowContentViewController *flowContentViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SCRFlowContentViewController"];
        [flowContentViewController setFlow:flows[i]];
        //        [self.navigationController pushViewController:flowContentViewController animated:YES];
        [viewControllers addObject:flowContentViewController];
    }
    [self.flowSegmentedControl setTintColor:UIColor.whiteColor];

    self.childViewControllers = [viewControllers copy];

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0],
                                                                      NSForegroundColorAttributeName:UIColor.whiteColor}];
    self.navigationItem.title = [[[self.flowGroup name] lowercaseString] capitalizedString];
    self.flowSegmentedControl.selectedSegmentIndex = 0;
    self.selectedControllerIndex = 0;
    
    [self addChildViewController:self.childViewControllers[0]];
    [self.parentView addSubview:[self.childViewControllers[0] view]];
    [self.childViewControllers[0] view].frame = self.parentView.bounds;
    [self.childViewControllers[0] didMoveToParentViewController:self];

    

//    for (CMAFlow *flow in [self.flowGroup flows])
//    {
//        [self.flowSegmentedControl insertSegmentWithTitle:[NSString stringWithFormat:@"Flow 0%llu", [flows indexOfObject:flow]+1 atIndex: animated:<#(BOOL)#>]
//    }
//    
//    CMAFlow *flow = [[self.flowGroup flows] objectAtIndex:section];
//    return [[flow _lessons] count];
}

//-(void)viewWillAppear:(BOOL)animated {
//    self.navigationController.navigationBar.barTintColor = UIColor.scrapplingForegroundBlueColor;
//    self.navigationController.navigationBar.tintColor = UIColor.whiteColor;
//    self.segmentedControlBox.backgroundColor = UIColor.scrapplingForegroundBlueColor;
//}

- (IBAction)segmentControlValueChanged:(id)sender
{
    UIViewController *originalViewController = [self.childViewControllers objectAtIndex:[self selectedControllerIndex]];
    UIViewController *destinationViewController = [self.childViewControllers objectAtIndex:[[self flowSegmentedControl] selectedSegmentIndex]];
    [[originalViewController view] removeFromSuperview];
    [originalViewController removeFromParentViewController];

    [self addChildViewController:destinationViewController];
    [self.parentView addSubview:[destinationViewController view]];
    [destinationViewController view].frame = self.parentView.bounds;
    [destinationViewController didMoveToParentViewController:self];
    
    self.selectedControllerIndex = self.flowSegmentedControl.selectedSegmentIndex;

//    for (int i = 0; i < self.childViewControllers.count; i++)
//    {
//        [self.childViewControllers[i] view].hidden = YES;
//    }
//    [self.childViewControllers[self.flowSegmentedControl.selectedSegmentIndex] view].hidden = NO;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
