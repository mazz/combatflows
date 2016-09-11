//
//  SCRProductService.m
//  scrappling
//
//  Created by Michael Hanna on 2015-05-19.
//  Copyright (c) 2015 ils. All rights reserved.
//

#import "SCRProductService.h"
#import "CMACurriculum.h"
#import "CMAFlowGroup.h"
#import "CMAFlow.h"
#import "CMALesson.h"
#import "IAHInAppPurchaseHelper.h"
#import "SCRTrainingItem.h"
static NSUInteger kSCRCombatFlowBundleIndex = 2;

NSString *const SCRProductServiceFetchedProductsNotification  = @"SCRProductServiceFetchedProductsNotification";
NSString *kSCRCombatFlowBundleProductIdentifier = @"ca.ilearningsolutions.combatflows.combatflowbundle";
NSString *kSCRCombatFlowFreeProductIdentifier = @"ca.ilearningsolutions.combatflows.combatflow04";

@interface SCRProductService()
//@property (assign) BOOL fetchingProducts;
@end

@implementation SCRProductService

-(instancetype)init
{
    if ((self = [super init]))
    {
        [[NSNotificationCenter defaultCenter] addObserverForName:IAPHelperProductRequestFailedNotification object:nil queue:nil usingBlock:^(NSNotification *note)
         {
             self.productRequestFailed = YES;
             // since we failed to connect to App Store, let's make a bunch of fake SCRTrainingItems so that we
             // can at least populate the UI with something
             NSArray *fakeModelTrainingItems = [self trainingItems];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:SCRProductServiceFetchedProductsNotification object:nil userInfo:@{@"trainingItems":fakeModelTrainingItems}];
         }];

    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fetchProducts
{
//    if (!self.fetchingProducts)
//    {
//        self.fetchingProducts = YES;
        self.products = nil;
        [[IAHInAppPurchaseHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success)
            {
                self.productRequestFailed = NO;
                self.products = products; // TODO: remove this line and access [[IAHInAppPurchaseHelper sharedInstance] productService].products to display products in table
                [[IAHInAppPurchaseHelper sharedInstance] productService].products = products;
                
                for (SKProduct *prod in products)
                {
                    DDLogDebug(@"prod: %@", prod.productIdentifier);
                }
                
                NSArray *modelTrainingItems = [self trainingItems];
//                self.fetchingProducts = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:SCRProductServiceFetchedProductsNotification object:nil userInfo:@{@"trainingItems":modelTrainingItems}];
            } else {
                DDLogDebug(@"fetch failed");
            }
        }];
//    }
}

- (NSArray *)trainingItems
{
    // pack-up 'preview items' to be shown in the collection view
    //

    NSMutableArray *trainingItems = [NSMutableArray array];
    __block NSInteger initialIndex = -1;
    [[[CMACurriculum sharedCurriculum] flowGroupsSortedByNumber] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         SCRTrainingItem *item = [SCRTrainingItem new];
         CMAFlowGroup *group = (CMAFlowGroup *)obj;
         DDLogDebug(@"**current group: %@", group.name);
         
         if (group.bundled == YES)
         {
             item.flowGroup = group;
             DDLogDebug(@"added flowGroup: %@ to training item: %@", item.flowGroup.name, item);
             item.product = nil;
         }
         if (self.products.count > 0)
         {
             for (SKProduct *product in self.products)
             {
                 if ([product.productIdentifier isEqualToString:group.productIdentifier])
                 {
                     item.flowGroup = group;
                     item.product = product;
//                     item.productIdentifier = product.productIdentifier;
                     //                         if ([self indexOfProductForIdentifier:product.productIdentifier] == button.tag)
                     //                         {
                     //                             initialIndex = idx;
                     //                         }
                 }
             }
         }
         else // we didn't manage to successfully fetch products from the app store, so make some fake objects
         {
             item.flowGroup = group;
             DDLogDebug(@"else item.flowGroup: %@", item.flowGroup);
             item.product = nil;
//             item.productIdentifier = group.productIdentifier;
         }
         DDLogDebug(@"**adding ti: %@ with product identifer: %@", item, item.product.productIdentifier);
         [trainingItems addObject:item];
     }];
    
    NSArray *modelTrainingItems = trainingItems;
    if ([self hasPurchasedProductWithProductIdentifier:kSCRCombatFlowBundleProductIdentifier])
    {
        modelTrainingItems = [self deleteItemsFromDataSourceAtIndexPaths:@[[NSIndexPath indexPathForRow:kSCRCombatFlowBundleIndex inSection:0]] forTrainingItems:trainingItems];
    }

    return modelTrainingItems;
}

-(NSArray *)deleteItemsFromDataSourceAtIndexPaths:(NSArray  *)itemPaths forTrainingItems:(NSArray *)trainingItems
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSIndexPath *itemPath  in itemPaths)
    {
        [indexSet addIndex:itemPath.row];
    }
    NSMutableArray *mutPreviewItems = [trainingItems mutableCopy];
    [mutPreviewItems removeObjectsAtIndexes:indexSet];
    return [mutPreviewItems copy];
}

- (SKProduct *)productForProductIdentifier:(NSString *)pi_
{
    SKProduct *product = nil;
    for (SKProduct *prod in self.products)
    {
        if ([[prod productIdentifier] isEqualToString:pi_])
        {
            product = prod;
            break;
        }
    }
    return product;
}

- (NSInteger)indexOfProductForIdentifier:(NSString *)pi_
{
    NSInteger index = -1;
    for (uint8_t i = 0; i < [self.products count]; i++)
    {
        if ([[[self.products objectAtIndex:i] productIdentifier] isEqualToString:pi_])
        {
            index = i;
        }
    }
    return index;
}

- (NSArray *)assetNamesForProductIdentifier:(NSString *)pi_
{
//    DDLogDebug(@"pi_: %@", pi_);

    NSMutableArray *assets = [NSMutableArray array];
    
    NSArray *flows = [[[[CMACurriculum sharedCurriculum] flowGroups] objectForKey:pi_] flows];

    for (CMAFlow *flow in flows)
    {
        for (CMALesson *lesson in flow.lessons)
        {
//            DDLogDebug(@"lesson.filename: %@", lesson.filename);

            //            [assets addObject:lesson.filename];
            [assets addObject:[NSString stringWithFormat:@"%@",lesson.filename]];
//            [assets addObject:[NSString stringWithFormat:@"bogus-%@",lesson.filename]];
        }
    }
//    DDLogDebug(@"assets: %@", assets);

    return [assets copy];
}

- (BOOL)hasPurchasedProductWithProductIdentifier:(NSString *)productIdentifier
{
    if (productIdentifier == nil) return NO;
    
    NSError *err = nil;
    NSSet *purchasedItems = [NSSet setWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[IAHInAppPurchaseHelper sharedInstance] purchasedContentPath] error:&err]];
    DDLogDebug(@"purchasedItems: %@", purchasedItems);
    NSSet *productItems = [NSSet setWithArray:[self assetNamesForProductIdentifier:productIdentifier]];
//    DDLogDebug(@"productItems: %@", productItems);
    
    DDLogDebug(@"productIdentifier hasPurchasedItems: %@ %d",productIdentifier, [productItems isSubsetOfSet:purchasedItems]);
    return [productItems isSubsetOfSet:purchasedItems];

}

- (BOOL)hasPurchasedEverything
{
    return [self hasPurchasedProductWithProductIdentifier:kSCRCombatFlowBundleProductIdentifier];
}

@end
