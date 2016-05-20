//
//  CMAVideo.m
//  MMATableTest
//
//  Created by Michael Hanna on 12-03-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMALesson.h"

@implementation CMALesson
- (instancetype)initWithFilename:(NSString *)filename flow:(CMAFlow *)flow lessonType:(CMALessonPlaybackLessonType)lessonType
{
    if ((self = [super init]))
    {
        [self setFlow:flow];
        [self setFilename:filename];
        [self setLessonType:lessonType];
    }
    return self;
}

@end
