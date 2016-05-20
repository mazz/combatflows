//
//  IAHInAppPurchaseHelper.h
//  InAppHosted
//
//  Created by Michael Hanna on 12-12-04.
//  Copyright (c) 2012 Interactive Learning Solutions Inc. All rights reserved.
//

#import "IAPHelper.h"
#import "SCRProductService.h"

@interface IAHInAppPurchaseHelper : IAPHelper
+ (IAHInAppPurchaseHelper *)sharedInstance;
@property (nonatomic) BOOL didFetchProducts;
- (SCRProductService  *)productService;
@end
