//
//  CMAFlowGroup.m
//  ScrapplingMain
//
//  Created by Michael Hanna on 12-09-28.
//  Copyright (c) 2012 Interactive Learning Solutions. All rights reserved.
//

#import "CMAFlow.h"
#import "CMAFlowGroup.h"
#import "IAHInAppPurchaseHelper.h"

NS_ASSUME_NONNULL_BEGIN

@implementation CMAFlowGroup

- (id)initWithDictionary:(NSDictionary*)aDictionary
{
    if (self = [super init]) {
        NSLog(@"productIdentifier: %@", [aDictionary objectForKey:@"productIdentifier"]);
        self.bundled = [[aDictionary objectForKey:@"bundled"] boolValue];
        [self setName:[aDictionary objectForKey:@"name"]];
        [self setText:[aDictionary objectForKey:@"text"]];
        [self setDetail:[aDictionary objectForKey:@"detail"]];
        [self setNumber:[aDictionary objectForKey:@"number"]];
        [self setListViewImage:[aDictionary objectForKey:@"listviewimage"]];
        [self setProductIdentifier:[aDictionary objectForKey:@"productIdentifier"]];
        _graphicGuideCards = aDictionary[@"graphicGuideCards"];
        _graphicGuideTitles = aDictionary[@"graphicGuideTitles"];
        _graphicGuideBanners = aDictionary[@"graphicGuideBanners"];

        NSMutableArray* thumbs = [NSMutableArray array];

        for (NSString* thumbPath in [aDictionary objectForKey:@"thumbs"]) {
            NSRange rangeOfDot = [thumbPath rangeOfString:@"."];
            
            NSString* path = [[NSBundle mainBundle] pathForResource:[thumbPath substringToIndex:rangeOfDot.location] ofType:@"m4v"];
//            NSString* path = [[NSBundle mainBundle] pathForResource:@"00_bundled-thumb-600" ofType:@"m4v"];

            [thumbs addObject:path];
        }
        self.thumbs = thumbs;

        if (self.bundled) {
            for (uint8_t c = 0; c < [self.graphicGuideCards count]; c++) {
                [self copyBundledGraphicGuideContent:self.graphicGuideCards[c]];
            }
            for (uint8_t c = 0; c < [self.graphicGuideBanners count]; c++) {
                [self copyBundledGraphicGuideContent:self.graphicGuideBanners[c]];
            }
        }

        NSMutableArray* mut = [NSMutableArray array];
        NSArray* flows = [aDictionary objectForKey:@"flows"];
        for (NSUInteger c = 0; c < flows.count; c++) {
            NSArray* flow = flows[c];

            //            CMAFlow* f = [[CMAFlow alloc] initWithLessons:flow name:[self name] flowGroup:self];
            CMAFlow* f = [[CMAFlow alloc] initWithLessons:flow name:self.name flowGroup:self];
            [mut addObject:f];
        }

        [self setFlows:[mut copy]];
    }
    return self;
}

- (void)copyBundledGraphicGuideContent:(NSString*)filename
{
    NSLog(@"copyBundledGraphicGuideContent: %@", filename);
    NSString* subdir = [[IAHInAppPurchaseHelper sharedInstance] purchasedContentPath];
//    subdir = [subdir stringByAppendingPathComponent:@"graphicGuide"];
    BOOL isDir;
    NSError* err = nil;

    if (![[NSFileManager defaultManager] fileExistsAtPath:subdir isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:subdir withIntermediateDirectories:YES attributes:nil error:&err];
        NSLog(@"creating subdir: %@", subdir);
    }

    NSString* graphicGuideAsset = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension]];
    [[NSFileManager defaultManager] copyItemAtPath:graphicGuideAsset toPath:[subdir stringByAppendingPathComponent:filename] error:&err];
}

@end

NS_ASSUME_NONNULL_END
