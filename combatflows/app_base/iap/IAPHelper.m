//
//  IAPHelper.m
//  InAppHosted
//
//  Created by Michael Hanna on 12-12-04.
//  Copyright (c) 2012 Interactive Learning Solutions Inc. All rights reserved.
//

#import "IAHInAppPurchaseHelper.h"
#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>

//#import "BlockAlertView.h"

NSString* const IAPHelperTransactionChargedNotification = @"IAPHelperTransactionChargedNotification";
NSString* const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString* const IAPHelperDownloadProgessUpdateNotification = @"IAPHelperDownloadProgessUpdateNotification";
NSString* const IAPHelperDownloadFailedNotification = @"IAPHelperDownloadFailedNotification";
NSString* const IAPHelperTransactionFailedNotification = @"IAPHelperTransactionFailedNotification";
NSString* const IAPHelperProductRequestFailedNotification = @"IAPHelperProductRequestFailedNotification";
NSString* const IAPHelperRestoreCompletedTransactionsBeginNotification = @"IAPHelperRestoreCompletedTransactionsBeginNotification";
NSString* const IAPHelperRestoreCompletedTransactionsFinishedNotification = @"IAPHelperRestoreCompletedTransactionsFinishedNotification";
NSString* const IAPHelperRestoreCompletedTransactionsFailedNotification = @"IAPHelperRestoreCompletedTransactionsFailedNotification";

@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, strong) NSSet* purchasedProductIdentifiers;
@end

@implementation IAPHelper {
    SKProductsRequest* _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    BOOL _showingDownloadFailedAlert;
    BOOL _restoringDownloads;
}

@synthesize _productIdentifiers;

- (id)initWithProductIdentifiers:(NSSet*)productIdentifiers
{
    if ((self = [super init])) {
        // Store product identifiers
        _productIdentifiers = productIdentifiers;

        // Check for previously purchased products
        self.purchasedProductIdentifiers = [NSMutableSet set];

        for (NSString* productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                NSMutableSet* mutPurchased = [self.purchasedProductIdentifiers mutableCopy];
                [mutPurchased addObject:productIdentifier];
                self.purchasedProductIdentifiers = [mutPurchased copy];

                DDLogDebug(@"Previously purchased: %@", productIdentifier);
            }
            else {
                DDLogDebug(@"Not purchased: %@", productIdentifier);
            }
        }

        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

        _showingDownloadFailedAlert = NO;
        _restoringDownloads = NO;
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{

    // 1
    _completionHandler = [completionHandler copy];

    // 2
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    //  _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:@"TestItem1", @"TestItem2", nil]];

    _productsRequest.delegate = self;
    [_productsRequest start];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*)response
{
    DDLogDebug(@"Loaded list of products...");
    _productsRequest = nil;
    [IAHInAppPurchaseHelper sharedInstance].didFetchProducts = YES;

    NSArray* skProducts = response.products;
    for (SKProduct* skProduct in skProducts) {
        DDLogDebug(@"Found product: %@ %@ %0.2f",
            skProduct.productIdentifier,
            skProduct.localizedTitle,
            skProduct.price.floatValue);
    }

    if (_completionHandler) {
        _completionHandler(YES, skProducts);
        _completionHandler = nil;
    }
}

- (void)request:(SKRequest*)request didFailWithError:(NSError*)error
{

    DDLogDebug(@"Failed to load list of products: %@", error);
    _productsRequest = nil;

    if (_completionHandler) {
        _completionHandler(NO, nil);
        _completionHandler = nil;
    }
    [IAHInAppPurchaseHelper sharedInstance].didFetchProducts = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRequestFailedNotification object:nil userInfo:nil];
}

- (BOOL)productPurchased:(NSString*)productIdentifier
{
    return [self.purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct*)product
{
    if ([SKPaymentQueue canMakePayments]) {
        DDLogDebug(@"Buying %@...", product.productIdentifier);

        SKPayment* payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)restoreDownloads
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    _restoringDownloads = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperRestoreCompletedTransactionsBeginNotification object:nil userInfo:nil];
}

- (BOOL)restoringDownloads
{
    return _restoringDownloads;
}

#pragma mark SKPaymentTransactionObserver

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue*)queue
{
    _restoringDownloads = NO;
    DDLogDebug(@"RestoreCompletedTransactions");
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperRestoreCompletedTransactionsFinishedNotification object:nil userInfo:nil];
}

- (void)paymentQueue:(SKPaymentQueue*)queue restoreCompletedTransactionsFailedWithError:(NSError*)error
{
    _restoringDownloads = NO;
    DDLogDebug(@"restoreCompletedTransactionsFailedWithError");
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperRestoreCompletedTransactionsFailedNotification object:nil userInfo:nil];
}

- (void)paymentQueue:(SKPaymentQueue*)queue updatedTransactions:(NSArray*)transactions
{
    for (SKPaymentTransaction* transaction in transactions) {
        NSArray* transactionProductIdentifiers = @[ transaction.payment.productIdentifier ];
        switch (transaction.transactionState) {
        case SKPaymentTransactionStatePurchased:
            [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];

            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"charged"] != nil) {
                NSMutableArray* charged = [[[NSUserDefaults standardUserDefaults] objectForKey:@"charged"] mutableCopy];
                [charged addObjectsFromArray:transactionProductIdentifiers];
                [[NSUserDefaults standardUserDefaults] setObject:charged forKey:@"charged"];
            }
            else {
                [[NSUserDefaults standardUserDefaults] setObject:transactionProductIdentifiers forKey:@"charged"];
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperTransactionChargedNotification object:nil userInfo:@{ @"productIdentifier" : transaction.payment.productIdentifier }];
            //        [self completeTransaction:transaction];
            break;
        case SKPaymentTransactionStateFailed:
            [self failedTransaction:transaction];
            break;
        case SKPaymentTransactionStateRestored:
            [self restoreTransaction:transaction];
        case SKPaymentTransactionStatePurchasing:
            DDLogDebug(@"SKPaymentTransactionStatePurchasing");
            break;
        default:
            break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue*)queue removedTransactions:(NSArray*)transactions
{
    DDLogDebug(@"removedTransactions: %@", transactions);
}

- (void)paymentQueue:(SKPaymentQueue*)queue updatedDownloads:(NSArray*)downloads
{
    for (SKDownload* download in downloads) {
        switch (download.downloadState) {
        case SKDownloadStateActive: {
            NSDictionary* dl = @{ @"progress" : [NSNumber numberWithDouble:download.progress],
                @"timeRemaining" : [NSNumber numberWithDouble:download.timeRemaining],
            };
            //[NSDictionary dictionaryWithObjectsAndKeys:iapProductIdentifer, @"productIdentifier", [NSNumber numberWithDouble:download.progress], @"progress", [NSNumber numberWithDouble:download.timeRemaining], @"timeRemaining", nil];

            [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperDownloadProgessUpdateNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:dl, @"download", download.contentIdentifier, @"productIdentifier", nil]];
            break;
        }

        case SKDownloadStateCancelled: {
            break;
        }
        case SKDownloadStateFailed: {
            DDLogDebug(@"download failed");
            //        [Utility showAlert:@"Download Failed"

            if (!_showingDownloadFailedAlert) {
#warning show an alert
                //          BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"Download Failed", @"") message:NSLocalizedString(@"There was a problem downloading the content. Please try again later.", @"")];
                //
                //          [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
                //            _showingDownloadFailedAlert = NO;
                //          }];
                //
                //          [alert show];

                _showingDownloadFailedAlert = YES;
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperDownloadFailedNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:download.contentIdentifier, @"productIdentifier", nil]];
            break;
        }

        case SKDownloadStateFinished: {
            DDLogDebug(@"SKDownloadStateFinished");

            NSError* err = nil;
            //            NSString *subdir = [self contentPathForProductIdentifier:download.contentIdentifier];
            NSString* subdir = [self purchasedContentPath];

            [[NSFileManager defaultManager] createDirectoryAtPath:subdir withIntermediateDirectories:YES attributes:nil error:&err];
            DDLogDebug(@"creating subdir: %@", subdir);

            NSString* sourceContents = [[download.contentURL relativePath] stringByAppendingPathComponent:@"Contents"];
            DDLogDebug(@"source contents: %@", [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourceContents error:&err]);

            // for each file downloaded, copy it to the new folder structure
            for (id item in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourceContents error:&err]) {
                NSString* leaf = [sourceContents stringByAppendingPathComponent:item];

                DDLogDebug(@"dir err: %@", err);
                [[NSFileManager defaultManager] copyItemAtPath:leaf toPath:[subdir stringByAppendingPathComponent:item] error:&err];
            }

            DDLogDebug(@"subdir contents: %@", [[NSFileManager defaultManager] contentsOfDirectoryAtPath:subdir error:&err]);

            if (download.transaction.transactionState == SKPaymentTransactionStatePurchased) {
                DDLogDebug(@"purchase complete");
                //          [Utility showAlert:@"Purchased Complete"
            }

            [self completeTransaction:download.transaction];
            break;
        }

        case SKDownloadStatePaused: {
            DDLogDebug(@"SKDownloadStatePaused");
            break;
        }

        case SKDownloadStateWaiting: {
            DDLogDebug(@"SKDownloadStateWaiting");
            //http://stackoverflow.com/questions/19810992/downloading-iap-hosted-content-gets-stucks-on-skdownloadstatewaiting-for-some-us
            [[SKPaymentQueue defaultQueue] startDownloads:[NSArray arrayWithObject:download]];
            break;
        }
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction*)transaction
{
    DDLogDebug(@"completeTransaction...");

    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction*)transaction
{
    DDLogDebug(@"restoreTransaction...");

//    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
//    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction*)transaction
{

    DDLogDebug(@"failedTransaction...");
    DDLogDebug(@"Transaction error: %@", transaction.error.localizedDescription);
    if (transaction.error.code != SKErrorPaymentCancelled) {
        DDLogDebug(@"Transaction error: %@", transaction.error.localizedDescription);
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperTransactionFailedNotification object:transaction userInfo:nil];
        //    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"Transaction Failed", @"") message:transaction.error.localizedDescription];
        //
        //    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
        //
        //    [alert show];
    }

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)provideContentForProductIdentifier:(NSString*)productIdentifier
{
    NSMutableSet* mutPurchased = [self.purchasedProductIdentifiers mutableCopy];
    [mutPurchased addObject:productIdentifier];
    self.purchasedProductIdentifiers = [mutPurchased copy];

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:nil userInfo:@{ @"productIdentifier" : productIdentifier }];
}

//- (NSString *)contentPathForProductIdentifier:(NSString *)pi_
//{
//  // fetch the Documents dir and create the folder structure where things will get stored
//  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//  NSString *documentsDirectory = nil;
//  NSError *err = nil;
//
//  // use the IAPProductIdentifier to generate the folder structure to look like: /Documents/CombatMMA/<appname>/purchased_content/<package downloaded name> from
//  // ca.ilearningsolutions.<appname>.<package downloaded name>
//  NSArray *pidComponentArray = [pi_ componentsSeparatedByString:@"."];
//  NSString *packageName = [pidComponentArray lastObject];
//  NSString *appBundleName = [pidComponentArray objectAtIndex:([pidComponentArray indexOfObject:[pidComponentArray lastObject]] - 1)];
//
//  if ([paths count] > 0)
//  {
//    documentsDirectory = [paths objectAtIndex:0];
//  }
//
//  NSString *subdir = nil;
//  subdir = [documentsDirectory stringByAppendingPathComponent:@"CombatMMA"];
//  subdir = [subdir stringByAppendingPathComponent:appBundleName];
//  subdir = [subdir stringByAppendingPathComponent:@"purchased_content"];
//  DDLogDebug(@"purchased_content contents: %@", [[NSFileManager defaultManager] contentsOfDirectoryAtPath:subdir error:&err]);
//
////  subdir = [subdir stringByAppendingPathComponent:packageName];
//
//  DDLogDebug(@"subdir: %@", subdir);
//  return subdir;
//}

- (NSString*)purchasedContentPath
{

    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = nil;
    NSError* err = nil;

    NSString* subdir = nil;

    if ([paths count] > 0) {
        documentsDirectory = [paths objectAtIndex:0];
        subdir = [documentsDirectory stringByAppendingPathComponent:@"CombatMMA"];
        subdir = [subdir stringByAppendingPathComponent:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] lowercaseString]];
        subdir = [subdir stringByAppendingPathComponent:@"purchased_content"];
        DDLogDebug(@"purchased_content contents: %@", [[NSFileManager defaultManager] contentsOfDirectoryAtPath:subdir error:&err]);
    }

    return subdir;
}

@end
