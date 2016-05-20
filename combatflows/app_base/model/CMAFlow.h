//
//  CMAMove.h
//  CombatMMA01
//
//  Created by Michael Hanna on 11-10-15.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMABaseContent.h"
#import "CMAFlowGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMAFlow : CMABaseContent
//@property (assign, nonatomic) BOOL _enabled;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *detail;
@property (strong, nonatomic) NSNumber *ordinal;
@property (strong, nonatomic) NSNumber *nominal;
@property (strong, nonatomic) NSArray  *lessons;
@property (strong, nonatomic) NSString *thumb;
@property (weak, nonatomic) CMAFlowGroup *flowGroup;
@property (strong, nonatomic) NSArray  *bannerPaths;
@property (strong, nonatomic) NSArray  *cardPaths;
- (id)initWithLessons:(NSArray *)lessonArray_ name:(NSString *)name_ flowGroup:(CMAFlowGroup *)fg_;
@end

NS_ASSUME_NONNULL_END
