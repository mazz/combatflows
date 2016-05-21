//
//  SCRPreviewBuyViewController.h
//  scrappling
//
//  Created by Michael Hanna on 2014-09-30.
//  Copyright (c) 2014 ils. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/SKProduct.h>

@interface SCRPreviewViewController : UIViewController
@property (nonatomic, weak) NSArray *products;
- (instancetype)initWithItems:(NSArray *)items initialItemIndex:(NSUInteger)initialItemIndex backgroundImageView:(UIImageView *)biv;
@end
