//
//  CMACurriculum.h
//  CombatMMA01
//
//  Created by Michael Hanna on 11-10-15.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAFlowGroup.h"
@class CMALesson;
@class CMAFlow;

@interface CMACurriculum : NSObject
//@property (retain, nonatomic) NSMutableDictionary *_flows;
@property (strong, nonatomic) NSMutableDictionary *flowGroups;
//@property (strong, nonatomic) NSMutableDictionary *_enabledFlowGroups;
//@property (retain, nonatomic) NSMutableDictionary *_flowNameIndexes; // grouped by alphabetical
//@property (retain, nonatomic) NSArray *_flowNameIndexArray;

@property (nonatomic,strong) NSArray *flowGroupsSortedByNumber;
//@property (nonatomic,strong) NSArray *flowGroupsSortedByNumber;
@property (nonatomic,strong) NSArray *_sortedFlows;
//@property (nonatomic,strong) NSArray *_enabledSortedFlows;
@property (nonatomic,strong) NSArray *_sortedLessons;
@property (nonatomic,strong) NSArray *_enabledSortedLessons;
//- (NSInteger)enabledCount;
+ (CMACurriculum *)sharedCurriculum;
- (CMAFlowGroup *)flowGroupForProductIdentifier:(NSString *)productIdentifier;
//- (NSUInteger)indexForFlowGroup:(CMAFlowGroup *)f_;
//- (NSUInteger)indexForFlowGroupEnabled:(CMAFlowGroup *)f_;
//- (CMALesson*)enabledLessonAfterLesson:(CMALesson*)lesson_;
//- (CMALesson*)enabledLessonPreviousToLesson:(CMALesson*)lesson_;
//- (CMAFlow*)enabledFlowAfterFlow:(CMAFlow*)f_;
//- (CMAFlow*)enabledFlowPreviousToFlow:(CMAFlow*)f_;
@end
