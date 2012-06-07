//
//  SPMessageThread.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SPMessage;

@interface SPMessageThread : NSManagedObject

@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSSet *messages;
@end

@interface SPMessageThread (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(SPMessage *)value;
- (void)removeMessagesObject:(SPMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;
@end
