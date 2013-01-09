//
//  SPMessageManager+InMemoryDataStore.h
//  SinglePic
//
//  Created by Ryan Renna on 2013-01-09.
//
//

#import <CoreData/CoreData.h>
#import "SPMessageManager.h"

//Replaces Core Data Store with an in-memory data-store created at Test time

@interface SPMessageManager (InMemoryDataStore)

- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)createPersistentStoreCoordinator;

@end
