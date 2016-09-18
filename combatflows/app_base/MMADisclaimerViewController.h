//
//  MMADisclaimerViewController.h
//  combatflows
//
//  Created by Michael Hanna on 2016-09-17.
//  Copyright © 2016 ilearningsolutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMADisclaimerDelegate <NSObject>
- (void)disclaimerWasAccepted;
@end

@interface MMADisclaimerViewController : UIViewController
@property (nonatomic, weak) id<MMADisclaimerDelegate> delegate;
@end
