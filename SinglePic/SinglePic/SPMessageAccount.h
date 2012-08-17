//
//  SPMessageAccount.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-08-17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SPMessageThread;

@interface SPMessageAccount : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSSet *threads;
@end

@interface SPMessageAccount (CoreDataGeneratedAccessors)

- (void)addThreadsObject:(SPMessageThread *)value;
- (void)removeThreadsObject:(SPMessageThread *)value;
- (void)addThreads:(NSSet *)values;
- (void)removeThreads:(NSSet *)values;
@end
