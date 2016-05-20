//
//  SCRPreviewItem.h
//  scrappling
//
//  Created by Michael Hanna on 2014-10-14.
//  Copyright (c) 2014 ils. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/SKProduct.h>
#import "CMAFlowGroup.h"

@interface SCRTrainingItem : NSObject
@property (strong, nonatomic) SKProduct *product;
@property (strong, nonatomic) CMAFlowGroup *flowGroup;
//@property (strong, nonatomic) NSString *productIdentifier;
@end
