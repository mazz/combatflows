//
//  CMAVideo.h
//  MMATableTest
//
//  Created by Michael Hanna on 12-03-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMABaseContent.h"
#import "CMAFlow.h"

@interface CMALesson : CMABaseContent
@property (nonatomic, weak) CMAFlow *flow;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic) CMALessonPlaybackLessonType lessonType;
- (instancetype)initWithFilename:(NSString *)filename flow:(CMAFlow *)flow lessonType:(CMALessonPlaybackLessonType)lessonType;
@end
