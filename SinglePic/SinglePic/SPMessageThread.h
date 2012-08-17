//
//  SPMessageThread.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-08-17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SPMessage, SPMessageAccount;

@interface SPMessageThread : NSManagedObject

@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) SPMessageAccount *account;
@end

@interface SPMessageThread (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(SPMessage *)value;
- (void)removeMessagesObject:(SPMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;
@end
