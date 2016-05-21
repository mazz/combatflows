//
//  SCRFlowContentViewController.h
//  scrappling
//
//  Created by Michael Hanna on 2015-06-01.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMAFlow.h"

@interface SCRFlowContentViewController : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic) CMAFlow *flow;
@end
