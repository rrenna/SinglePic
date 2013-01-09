//
//  SPMessageManager+InMemoryDataStore.m
//  SinglePic
//
//  Created by Ryan Renna on 2013-01-09.
//
//

#import "SPMessageManager+InMemoryDataStore.h"

@implementation SPMessageManager (InMemoryDataStore)

- (NSManagedObjectModel *)createManagedObjectModel
{
    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    return mom;
}
- (NSPersistentStoreCoordinator *)createPersistentStoreCoordinator
{    
    NSError *error = nil;
    NSPersistentStoreCoordinator* storeCoordinator = [[NSPersistentStoreCoordinator alloc]
                                                      initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![storeCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                        configuration:nil URL:nil options:options error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return storeCoordinator;
}


@end
