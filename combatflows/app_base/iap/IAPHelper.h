//
//  IAPHelper.h
//  InAppHosted
//
//  Created by Michael Hanna on 12-12-04.
//  Copyright (c) 2012 Interactive Learning Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperTransactionChargedNotification;
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString *const IAPHelperDownloadProgessUpdateNotification;
UIKIT_EXTERN NSString *const IAPHelperDownloadFailedNotification;
UIKIT_EXTERN NSString *const IAPHelperTransactionFailedNotification;
UIKIT_EXTERN NSString *const IAPHelperProductRequestFailedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject

@property (nonatomic, strong) NSSet * _productIdentifiers;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreDownloads;

//- (NSString *)contentPathForProductIdentifier:(NSString *)pi_;
- (NSString *)purchasedContentPath;
@end