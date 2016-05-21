//
//  SCRFlowGroupDetailViewController.h
//  scrappling
//
//  Created by Michael Hanna on 2015-05-21.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMAFlowGroup.h"
#import "CMALesson.h"

@interface SCRFlowGroupDetailViewController : UIViewController
@property (nonatomic, strong) CMAFlowGroup *flowGroup;
@property (nonatomic, strong) CMALesson *currentLesson;
@end
