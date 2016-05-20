//
//  IAHInAppPurchaseHelper.m
//  InAppHosted
//
//  Created by Michael Hanna on 12-12-04.
//  Copyright (c) 2012 Interactive Learning Solutions Inc. All rights reserved.
//

#import "IAHInAppPurchaseHelper.h"

@interface IAHInAppPurchaseHelper()
@property (nonatomic, strong) SCRProductService *productService;
@end

@implementation IAHInAppPurchaseHelper

+ (IAHInAppPurchaseHelper *)sharedInstance
{
  static dispatch_once_t once;
  static IAHInAppPurchaseHelper * sharedInstance;
    
  dispatch_once(&once, ^{
//#ifdef SCRAPPLING_FAMILY
    // CMACurriculum MUST be initialized BEFORE IAHInAppPurchaseHelper because it contains
    // the productIdentifiers required to initialize the IAHInAppPurchaseHelper
//    NSArray *flowGroups = [[CMACurriculum sharedCurriculum] flowGroupsSortedByNumber];

    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"flows" ofType:@"json"];
    NSArray *rawFlowGroups = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath options:NSDataReadingMappedAlways error:nil] options:0 error:nil];

    NSMutableSet *productIdentifiers = [NSMutableSet set];
    for (NSDictionary *dict in rawFlowGroups)
    {
        [productIdentifiers addObject:[dict objectForKey:@"productIdentifier"]];
    }
//#else
//    NSSet * productIdentifiers = [NSSet setWithObjects:
//                                  @"ca.ilearningsolutions.scrappling.mountposition",
//                                  @"ca.ilearningsolutions.scrappling.guardposition",
//                                  @"ca.ilearningsolutions.scrappling.inopponenthalfguard",
//                                  @"ca.ilearningsolutions.scrappling.inopponentguard",
//                                  @"ca.ilearningsolutions.scrappling.crossbodyposition",
//                                  @"ca.ilearningsolutions.scrappling.kesagetamiposition",
//                                  nil];
//    
//#endif

      sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
      sharedInstance->_productService = [[SCRProductService alloc] init];

  });

    return sharedInstance;
}

@end
