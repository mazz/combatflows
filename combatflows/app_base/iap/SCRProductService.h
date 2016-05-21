//
//  SCRProductService.h
//  scrappling
//
//  Created by Michael Hanna on 2015-05-19.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const SCRProductServiceFetchedProductsNotification;

extern NSString *kSCRCombatFlowBundleProductIdentifier;
extern NSString *kSCRCombatFlowFreeProductIdentifier;

@interface SCRProductService : NSObject
@property (nonatomic, strong) NSArray *products;
@property (assign) BOOL productRequestFailed;
- (void)fetchProducts;

- (SKProduct *)productForProductIdentifier:(NSString *)pi_;
- (NSInteger)indexOfProductForIdentifier:(NSString *)pi_;
- (NSArray *)assetNamesForProductIdentifier:(NSString *)pi_;
- (BOOL)hasPurchasedProductWithProductIdentifier:(NSString *)productIdentifier;
- (BOOL)hasPurchasedEverything;
@end
