//
//  SCPFlowGroupTableViewController.h
//  scrappling
//
//  Created by Michael Hanna on 2014-11-08.
//  Copyright (c) 2014 ils. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMAFlowGroup.h"
#import "CMALesson.h"

@interface SCRFlowGroupTableViewController : UITableViewController
@property (nonatomic, strong) CMAFlowGroup *flowGroup;
@property (nonatomic, strong) CMALesson *currentLesson;
@end
