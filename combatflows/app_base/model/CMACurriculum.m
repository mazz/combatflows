//
//  CMACurriculum.m
//  CombatMMA01
//
//  Created by Michael Hanna on 11-10-15.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CMACurriculum.h"
#import "CMAFlow.h"

@interface CMACurriculum()
- (void)setupFlows;
- (NSArray *)presortFlowGroupsByNumber;
//- (NSArray *)presortEnabledFlowGroupsByNumber;
- (void)generateSortedLessonArray;
//- (void)generateEnabledSortedLessonArray;
- (void)generateSortedFlowArray;
//- (void)generateEnabledSortedFlowArray;

@end

@implementation CMACurriculum
//@synthesize _flowGroups;
//@synthesize _enabledFlowGroups;
@synthesize _sortedFlows;
//@synthesize _enabledSortedFlows;
@synthesize _sortedLessons;
@synthesize _enabledSortedLessons;

// we use the singleton approach, one collection for the entire application
static CMACurriculum *sharedInstance = nil;

+ (CMACurriculum *)sharedCurriculum {
  @synchronized(self) {
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
  }
  return sharedInstance;
}

//+ (id)allocWithZone:(NSZone *)zone {
//  @synchronized(self) {
//    if (sharedInstance == nil) {
//      sharedInstance = [super allocWithZone:zone];
//      return sharedInstance;  // assignment and return on first allocation
//    }
//  }
//  return nil; //on subsequent allocation attempts return nil
//}
//
//- (id)copyWithZone:(NSZone *)zone {
//  return self;
//}
//
//- (id)retain {
//  return self;
//}
//
//- (unsigned)retainCount {
//  return UINT_MAX;  //denotes an object that cannot be released
//}
//
//- (oneway void)release {
//  //do nothing
//}
//
//- (id)autorelease {
//  return self;
//}


// setup the data collection
- init {
	if (self = [super init]) 
  {
//    _enabledCount = 0;
		[self setupFlows];
	}
	return self;
}

//- (NSInteger)enabledCount
//{
//  return _enabledCount;
//}

//- (CMAFlow*)enabledFlowAfterFlow:(CMAFlow*)f_
//{
//  NSArray *flows = [[CMACurriculum sharedCurriculum] _enabledSortedFlows];
//  NSUInteger flowIndex = [flows indexOfObjectIdenticalTo:f_];
//  CMAFlow *result = nil;
//  
//  if (flowIndex != NSNotFound)
//  {
//    if (flowIndex == [flows count]-1) // last index, get the first flow
//    {
//      result = [flows objectAtIndex:0];
//    }
//    else
//    {
//      result = [flows objectAtIndex:flowIndex+1];
//    }
//  }
//  
//  return result;
//}

//- (CMAFlow*)enabledFlowPreviousToFlow:(CMAFlow*)f_
//{
//  NSArray *flows = [[CMACurriculum sharedCurriculum] _enabledSortedFlows];
//  NSUInteger flowIndex = [flows indexOfObjectIdenticalTo:f_];
//  CMAFlow *result = nil;
//  
//  if (flowIndex != NSNotFound)
//  {
//    if (flowIndex == 0) // first index, get the last lesson
//    {
//      result = [flows objectAtIndex:[flows count]-1];
//    }
//    else
//    {
//      result = [flows objectAtIndex:flowIndex-1];
//    }
//  }
//  
//  return result;
//}

//- (CMALesson*)enabledLessonAfterLesson:(CMALesson*)lesson_
//{
//  NSArray *lessons = [[CMACurriculum sharedCurriculum] _enabledSortedLessons];
//  NSUInteger lessonIndex = [lessons indexOfObjectIdenticalTo:lesson_];
//  CMALesson *result = nil;
//
//  if (lessonIndex != NSNotFound)
//  {
//    if (lessonIndex == [lessons count]-1) // last index, get the first lesson
//    {
//      result = [lessons objectAtIndex:0];
//    }
//    else
//    {
//      result = [lessons objectAtIndex:lessonIndex+1];
//    }
//  }
//
//  return result;
//}
//
//- (CMALesson*)enabledLessonPreviousToLesson:(CMALesson*)lesson_
//{
//  NSArray *lessons = [[CMACurriculum sharedCurriculum] _enabledSortedLessons];
//  NSUInteger lessonIndex = [lessons indexOfObjectIdenticalTo:lesson_];
//  CMALesson *result = nil;
//  
//  if (lessonIndex != NSNotFound)
//  {
//    if (lessonIndex == 0) // first index, get the last lesson
//    {
//      result = [lessons objectAtIndex:[lessons count]-1];
//    }
//    else
//    {
//      result = [lessons objectAtIndex:lessonIndex-1];
//    }
//  }
//  
//  return result;
//}

- (void)setupFlows 
{
	// create dictionaries that contain the arrays of element data indexed by
	// name
	[self setFlowGroups:[NSMutableDictionary dictionary]];
//  [self set_flowNameIndexes:[NSMutableDictionary dictionary]];
	
	// read the element data from the plist
//    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"FlowGroupsFull_gg_bogus" ofType:@"json"];
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"flows" ofType:@"json"];
    
    NSArray *rawFlowGroups = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath options:NSDataReadingMappedAlways error:nil] options:0 error:nil];
    uint8_t c = 1;
	// iterate over the values in the raw flows dictionary
	for (NSDictionary *rawFlowGroup in rawFlowGroups)
	{
//        if ([[rawFlowGroup objectForKey:@"enabled"] boolValue] == YES)
//        {
//          _enabledCount++;
//        }

        NSMutableDictionary *mut = [rawFlowGroup mutableCopy];
        [mut setObject:[NSNumber numberWithInteger:c] forKey:@"number"];
//        NSLog(@"mut: %@", mut);
        CMAFlowGroup *flowGroup = [[CMAFlowGroup alloc] initWithDictionary:[mut copy]];
        NSLog(@"flowGroup.name: %@", flowGroup.name);
        // store that item in the elements dictionary with the name as the key
        [_flowGroups setObject:flowGroup forKey:flowGroup.productIdentifier];

//        if ([flowGroup enabled])
//        {
//        [_enabledFlowGroups setObject:flowGroup forKey:flowGroup.name];
//        }
        
            // get the element's initial letter
    //		NSString *firstLetter = [flowGroup._name substringToIndex:1];
    //		NSMutableArray *existingArray;
    //
    //		// if an array already exists in the name index dictionary
    //		// simply add the element to it, otherwise create an array
    //		// and add it to the name index dictionary with the letter as the key
    //		if ((existingArray = [_flowNameIndexes valueForKey:firstLetter]))
    //		{
    //      [existingArray addObject:flowGroup];
    //		} else {
    //			NSMutableArray *tempArray = [NSMutableArray array];
    //			[_flowNameIndexes setObject:tempArray forKey:firstLetter];
    //			[tempArray addObject:flowGroup];
    //		}
            
        c++;
  }

//  [self presortFlowInitialLetterIndexes];
  [self setFlowGroupsSortedByNumber:[self presortFlowGroupsByNumber]];
//  [self setflowGroupsSortedByNumber:[self presortEnabledFlowGroupsByNumber]];

  // once all the sorted flow groups are loaded, make a flat lesson list and a flat enabled lesson list
  [self generateSortedLessonArray];
//  [self generateEnabledSortedLessonArray];

  // once all the sorted lessons are loaded, make a flat flow list and a flat enabled flow list
  [self generateSortedFlowArray];
//  [self generateEnabledSortedFlowArray];

}

- (CMAFlowGroup *)flowGroupForProductIdentifier:(NSString *)productIdentifier
{
    for (NSString *flowGroupProductIdentifier in [[self flowGroups] allKeys])
    {
        if ([flowGroupProductIdentifier isEqualToString:productIdentifier])
        {
            return self.flowGroups[productIdentifier];
        }
    }
    return nil;
}

- (NSUInteger)indexForFlowGroup:(CMAFlowGroup *)f_
{
  return [[self flowGroupsSortedByNumber] indexOfObject:f_];
}

//- (NSUInteger)indexForFlowGroupEnabled:(CMAFlowGroup *)f_
//{
//  return [[self flowGroupsSortedByNumber] indexOfObject:f_];
//}

- (void)generateSortedLessonArray
{
  NSMutableArray *array = [NSMutableArray array];
  
  for (id flowGroup in [self flowGroupsSortedByNumber])
  {
    for (CMAFlow *flow in [flowGroup flows])
    {
      for (id lesson in [flow lessons])
      {
        [array addObject:lesson];
      }
    }
  }
  [self set_sortedLessons:[array copy]];
}

//- (void)generateEnabledSortedLessonArray
//{
//  NSMutableArray *array = [NSMutableArray array];
//  
//  for (id flowGroup in [self flowGroupsSortedByNumber])
//  {
//    for (id flow in [flowGroup flows])
//    {
//      for (id lesson in [flow lessons])
//      {
//        [array addObject:lesson];
//      }
//    }
//  }
//  [self set_enabledSortedLessons:[array copy]];
//}

- (void)generateSortedFlowArray
{
  NSMutableArray *array = [NSMutableArray array];
  
  for (id flowGroup in [self flowGroupsSortedByNumber])
  {
    for (id flow in [flowGroup flows])
    {
      [array addObject:flow];
    }
  }
  [self set_sortedFlows:[array copy]];
}

//- (void)generateEnabledSortedFlowArray
//{
//  NSMutableArray *array = [NSMutableArray array];
//  
//  for (id flowGroup in [self flowGroupsSortedByNumber])
//  {
//    for (id flow in [flowGroup _flows])
//    {
//      [array addObject:flow];
//    }
//  }
//  [self set_enabledSortedFlows:[array copy]];
//}

// return an array of elements for an initial letter (ie A, B, C, ...)
//- (NSArray *)flowsWithInitialLetter:(NSString*)aKey {
//	return [_flowNameIndexes objectForKey:aKey];
//}

// presort the name index arrays so the elements are in the correct order
//- (void)presortFlowInitialLetterIndexes {
//  [self set_flowNameIndexArray:[[_flowNameIndexes allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
//	for (NSString *eachNameIndex in _flowNameIndexArray) {
//		[self presortFlowNamesForInitialLetter:eachNameIndex];
//	}
//}

//- (void)presortFlowNamesForInitialLetter:(NSString *)aKey {
//	NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] ;
//	
//	NSArray *descriptors = [NSArray arrayWithObject:nameDescriptor];
//	[[_flowNameIndexes objectForKey:aKey] sortUsingDescriptors:descriptors];
//	[nameDescriptor release];
//}

- (NSArray *)presortFlowGroupsByNumber
{
	NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES selector:@selector(compare:)];
	
	NSArray *descriptors = [NSArray arrayWithObject:nameDescriptor];
	NSArray *sortedElements = [[_flowGroups allValues] sortedArrayUsingDescriptors:descriptors];
	return sortedElements;
}

//- (NSArray *)presortEnabledFlowGroupsByNumber
//{
//	NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES selector:@selector(compare:)];
//	
//	NSArray *descriptors = [NSArray arrayWithObject:nameDescriptor];
//	NSArray *sortedElements = [[_flowGroups allValues] sortedArrayUsingDescriptors:descriptors];
//  
//  NSMutableArray *enabled = [NSMutableArray array];
//  
//  for (id elem in sortedElements)
//  {
//    if ([elem _enabled])
//    {
//      [enabled addObject:elem];
//    }
//  }
//
//    return sortedElements;
//}
@end
