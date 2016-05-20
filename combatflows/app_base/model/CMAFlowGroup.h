//
//  CMAFlowGroup.h
//  ScrapplingMain
//
//  Created by Michael Hanna on 12-09-28.
//  Copyright (c) 2012 Interactive Learning Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMABaseContent.h"

@interface CMAFlowGroup : CMABaseContent
//@property (assign, nonatomic) BOOL _enabled;
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *text;
@property (retain, nonatomic) NSString *detail;
@property (retain, nonatomic) NSNumber *number;
//@property (retain, nonatomic) NSString *_tableImageName;
//@property (retain, nonatomic) NSString *_tableImageApplicationName;
//@property (retain, nonatomic) NSString *_tableImageGraphicGuideName;
@property (retain, nonatomic) NSArray  *flows;
@property (retain, nonatomic) NSString *listViewImage;
@property (strong, nonatomic) NSString *productIdentifier;
@property (assign, nonatomic) BOOL bundled;

@property (strong, nonatomic) NSArray *thumbs;
@property (strong, nonatomic) NSArray *graphicGuideCards;
@property (strong, nonatomic) NSArray *graphicGuideTitles;
@property (strong, nonatomic) NSArray *graphicGuideBanners;

- (id)initWithDictionary:(NSDictionary *)aDictionary;
@end
