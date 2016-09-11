//
//  CMAMove.m
//  CombatMMA01
//
//  Created by Michael Hanna on 11-10-15.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CMAFlow.h"
#import "CMALesson.h"
#import "IAHInAppPurchaseHelper.h"

NS_ASSUME_NONNULL_BEGIN

@implementation CMAFlow

NSInteger kTeachingIndex = 0;
NSInteger kApplicationIndex = 1;
NSInteger kGraphicGuideIndex = 2;
NSInteger kLessonVideoTypeIndex = 3;

- (id)initWithLessons:(NSArray*)lessonArray_ name:(NSString*)name_ flowGroup:(CMAFlowGroup*)fg_
{
    if ((self = [super init])) {
        NSMutableArray* mut = [NSMutableArray arrayWithCapacity:3]; // one for teaching, one for application, graphic guide
        [mut addObject:[NSNull null]];
        [mut addObject:[NSNull null]];
        [mut addObject:[NSNull null]];
        DDLogDebug(@"lessonArray_: %@ name: %@ fg.name: %@", lessonArray_, name_, fg_.name);
        
        NSNumberFormatter* f = [[NSNumberFormatter alloc] init];

        // parse lessons
        for (uint8_t c = 0; c < [lessonArray_ count]; c++) {
            NSString* filename = [lessonArray_ objectAtIndex:c];
            NSArray* components = [filename componentsSeparatedByString:@"-"];

            f.numberStyle = NSNumberFormatterDecimalStyle;
            self.ordinal = [f numberFromString:[components objectAtIndex:0]];
            self.nominal = [NSNumber numberWithInteger:[[components objectAtIndex:2] integerValue]];

            //        MMALessonPlaybackLessonType lt = (c == 0) ? kMMATeaching : (c == 1) ? kMMAGraphicGuide : kMMAApplication;
            //      CMALesson *l = [[CMALesson alloc] initWithDictionary:[lessonArray_ objectAtIndex:c] enabled:enabled_ flow:self lessonType:lt];

            if ([[components objectAtIndex:kLessonVideoTypeIndex] containsString:@"application"]) {
                [mut replaceObjectAtIndex:kApplicationIndex withObject:[[CMALesson alloc] initWithFilename:[lessonArray_ objectAtIndex:c] flow:self lessonType:kCMAApplication]];
            }
            else if ([[components objectAtIndex:kLessonVideoTypeIndex] containsString:@"teaching"]) {
                [mut replaceObjectAtIndex:kTeachingIndex withObject:[[CMALesson alloc] initWithFilename:[lessonArray_ objectAtIndex:c] flow:self lessonType:kCMATeaching]];
            }
            else if ([[components objectAtIndex:kLessonVideoTypeIndex] containsString:@"graphicguide"]) {
                [mut replaceObjectAtIndex:kGraphicGuideIndex withObject:[[CMALesson alloc] initWithFilename:[lessonArray_ objectAtIndex:c] flow:self lessonType:kCMAGraphicGuide]];
            }

            if (fg_.bundled) {
                [self copyBundledContent:[lessonArray_ objectAtIndex:c]];
            }
            //        [mut addObject:lesson];
        }
        
        [self setLessons:[mut copy]];
        [self setName:name_];
        [self setFlowGroup:fg_];
        
        // parse banners
        NSMutableArray *mutBannerPaths = [@[] mutableCopy];
        
        //  04-mountpositionflow-2-graphicguidebanner@3x.png,
        //  take the 2 and compare with self.nominal
        for (uint8_t c = 0; c < fg_.graphicGuideBanners.count; c++) {
            NSString* filename = [fg_.graphicGuideBanners objectAtIndex:c];
            NSArray* components = [filename componentsSeparatedByString:@"-"];
            NSInteger flowNominal =  [[components objectAtIndex:2] integerValue];
            if (flowNominal == [self.nominal integerValue]) {
                [mutBannerPaths addObject:filename];
            }
        }
        _bannerPaths = [mutBannerPaths copy];
        
        NSMutableArray* mutCardPaths = [@[] mutableCopy];
        for (NSUInteger i = 0; i < fg_.graphicGuideCards.count; i++) {
            NSString* filename = [fg_.graphicGuideCards objectAtIndex:i];
            NSArray* components = [filename componentsSeparatedByString:@"-"];
            NSInteger flowNominal =  [[components objectAtIndex:2] integerValue];
            if (flowNominal == [self.nominal integerValue]) {
                [mutCardPaths addObject:fg_.graphicGuideCards[i]];
            }
        }
        _cardPaths = [mutCardPaths copy];
    }
    return self;
}

- (void)copyBundledContent:(NSString*)filename
{
    //    filename = [NSString stringWithFormat:@"bogus-%@", filename];
    NSString* subdir = [[IAHInAppPurchaseHelper sharedInstance] purchasedContentPath];
    NSError* err = nil;

    [[NSFileManager defaultManager] createDirectoryAtPath:subdir withIntermediateDirectories:YES attributes:nil error:&err];
    DDLogDebug(@"creating subdir: %@", subdir);

    NSString* lessonPath = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension]];
    [[NSFileManager defaultManager] copyItemAtPath:lessonPath toPath:[subdir stringByAppendingPathComponent:filename] error:&err];

    DDLogDebug(@"subdir contents: %@", [[NSFileManager defaultManager] contentsOfDirectoryAtPath:subdir error:&err]);
}

@end

NS_ASSUME_NONNULL_END
