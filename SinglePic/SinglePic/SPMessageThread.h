//
//  SPMessageThread.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-09.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SPMessage, SPMessageAccount;

@interface SPMessageThread : NSManagedObject

@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSDate * lastActivity;
@property (nonatomic, retain) SPMessageAccount *account;
@property (nonatomic, retain) NSSet *messages;
@end

@interface SPMessageThread (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(SPMessage *)value;
- (void)removeMessagesObject:(SPMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;
@end
