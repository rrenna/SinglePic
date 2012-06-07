//
//  SPMessageManager.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <AudioToolbox/AudioServices.h>
#import "CJSONSerializer.h"
#import "SPMessageManager.h"
#import "SPRequestManager.h"
#import "SPMessageThread.h"
#import "SPMessage.h"

@interface SPMessageManager()
- (NSManagedObjectContext *) managedObjectContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (void)retrieveMessages;
- (int)unixTimeOfLastRetrieval;
@end

@implementation SPMessageManager
-(id)init
{
    self = [super init];
    if(self)
    {
    }
    return self;
}
#pragma mark
-(void)forceRefresh
{
    //Force the refresh of messages
    [self retrieveMessages];
}
-(NSArray*)activeMessageThreads
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SPMessageThread" inManagedObjectContext:[self managedObjectContext]];
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    
    //Asks core data to prefetch the Stations relationship
    //NSArray * fetchedRelationshipArray = [[NSArray alloc] initWithObjects:@"Messages",nil];
    //[fetchRequest setRelationshipKeyPathsForPrefetching:fetchedRelationshipArray];
    
    //Will always sort alphabetically
    /*NSMutableArray* sortDescriptors = [NSMutableArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"Name" ascending:YES]];
    
    if(self.sortName)
    {
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:self.sortName ascending:YES];
        //Insert any selected sort order, place sort description infront of "Name" descriptor
        [sortDescriptors insertObject:sortDescriptor atIndex:0];
    }
    [fetchRequest setSortDescriptors:sortDescriptors];
     */
    
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}
-(SPMessageThread*)getMessageThreadByUserID:(NSString*)userID
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SPMessageThread" inManagedObjectContext:[self managedObjectContext]];
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"userID == %@",userID]];
    
    //Asks core data to prefetch the Threads messages relationship
    NSArray* fetchedRelationshipArray = [NSArray arrayWithObject:@"messages"];
    [fetchRequest setRelationshipKeyPathsForPrefetching:fetchedRelationshipArray];

    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count] == 1)
    {
        return [fetchedObjects objectAtIndex:0];
    }
    return nil;
}
-(void)deleteMessageThread:(SPMessageThread*)thread
{
    [[self managedObjectContext] deleteObject:thread];
}
-(void)sendMessage:(NSString*)message toUserWithID:(NSString*)userID withCompletionHandler:(void (^)(SPMessage* message))onCompletion andErrorHandler:(void(^)())onError
{
    NSString* parameter = [NSString stringWithFormat:@"%@/msg",userID];
    NSDictionary* messageJSONData = [NSDictionary dictionaryWithObjectsAndKeys:message,@"message",nil];

    NSError *error = NULL;
    NSData *jsonData = [[CJSONSerializer serializer] serializeObject:messageJSONData error:&error];
    NSString* jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
    
    [[SPRequestManager sharedInstance] postToNamespace:REQUEST_NAMESPACE_USERS withParameter:parameter andPayload:jsonString requiringToken:YES withCompletionHandler:^(id responseObject) 
    {
        //Find the User Thread if active
        SPMessageThread* thread = nil;
        for(SPMessageThread* thread_ in [self activeMessageThreads])
        {
            if([thread_.userID isEqualToString:userID])
            {
                thread = thread_;
                break;
            }
        }
        //Create User Thread if inactive
        if(!thread)
        {
            thread = [NSEntityDescription insertNewObjectForEntityForName:@"SPMessageThread" inManagedObjectContext:[self managedObjectContext]];
            thread.userID = userID;
        }

        //Create SPMessage
        SPMessage* newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"SPMessage" inManagedObjectContext:[self managedObjectContext]];
        newMessage.content = message;
        newMessage.date = [NSDate date];
        newMessage.incoming = YES_NSNUMBER;
        
        [thread addMessagesObject:newMessage];

        [managedObjectContext save:nil];
        //Run completion block
        onCompletion(newMessage);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_SENT object:nil];
        
    } andErrorHandler:onError];
}
//Message Syncronization
-(void)sendSyncronizationReceiptWithCompletionHandler:(void (^)())onCompletion andErrorHandler:(void(^)())onError
{
    NSString* parameter = [NSString stringWithFormat:@"%@/msg/time/%d000",USER_ID_ME,[self unixTimeOfLastRetrieval]];

    [[SPRequestManager sharedInstance] deleteFromNamespace:REQUEST_NAMESPACE_USERS withParameter:parameter requiringToken:YES withCompletionHandler:^(id responseObject) 
     {
         //Reset Badge
         [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
         
         onCompletion();
     } 
     andErrorHandler:^(SPWebServiceError *error) 
     {
         onError(error);
     }];
}
#pragma mark - Private methods
-(void)retrieveMessages
{
    int unixTimeSincePreviousRetrieval = [self unixTimeOfLastRetrieval];

    NSString* parameter = [NSString stringWithFormat:@"%@/msg/time/%d000",USER_ID_ME,unixTimeSincePreviousRetrieval];
    [[SPRequestManager sharedInstance] getFromNamespace:REQUEST_NAMESPACE_USERS withParameter:parameter requiringToken:YES withCompletionHandler:^(id responseObject) 
    {
        NSError *theError = nil;
        NSArray* messagesData = [[CJSONDeserializer deserializer] deserialize:responseObject error:&theError];
        BOOL messagesRecieved = NO;
        
        for(NSDictionary* messageData in messagesData)
        {
            NSString* userID = [messageData objectForKey:@"from"];
            NSString* message = [messageData objectForKey:@"message"];
            NSNumber* unixTimeWithMillisecondsNumber = [messageData objectForKey:@"timeStamp"];
            NSString* unixTimeWithMillisecondsString = [unixTimeWithMillisecondsNumber stringValue];
            NSString* unixTimeWithoutMillisecondsString = [unixTimeWithMillisecondsString substringToIndex:10];
            int unixTimeWithoutMilliseconds = [unixTimeWithoutMillisecondsString intValue];

            
            //Find the User Thread if active
            SPMessageThread* thread = nil;
            for(SPMessageThread* thread_ in [self activeMessageThreads])
            {
                if([thread_.userID isEqualToString:userID])
                {
                    thread = thread_;
                    break;
                }
            }
            //Create User Thread if inactive
            if(!thread)
            {
                thread = [NSEntityDescription insertNewObjectForEntityForName:@"SPMessageThread" inManagedObjectContext:[self managedObjectContext]];
                thread.userID = userID;
            }
            
            //Create SPMessage
            SPMessage* newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"SPMessage" inManagedObjectContext:[self managedObjectContext]];
            newMessage.content = message;
            newMessage.incoming = NO_NSNUMBER;
            newMessage.date = [NSDate dateWithTimeIntervalSince1970:unixTimeWithoutMilliseconds];
            
            [thread addMessagesObject:newMessage];
            messagesRecieved = YES;
        }
        
        if(messagesRecieved)
        {       
            //Vibrate the device (NOTE: Does nothing on devices which do not support vibrations)
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

            double unixTime = [[NSDate date] timeIntervalSince1970];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:unixTime] forKey:UNIX_TIME_OF_LAST_MESSAGE_RETRIEVAL_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NEW_MESSAGES_RECIEVED object:nil];
            [managedObjectContext save:nil];
            
            //Inform the user that we've recieved the messages successfully
            [self sendSyncronizationReceiptWithCompletionHandler:^
            {
                //Reset Badge
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            } 
            andErrorHandler:^
            {
                
            }];
        }
        else
        {
             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NO_MESSAGES_RECIEVED object:nil];
        }
        
    } andErrorHandler:^(NSError* error)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NO_MESSAGES_RECIEVED object:nil];
    }];
}
- (int)unixTimeOfLastRetrieval
{
    //Retrieve the last stored retrieval date from NSUserDefaults
    NSNumber* unixTimeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:UNIX_TIME_OF_LAST_MESSAGE_RETRIEVAL_KEY];
    if(unixTimeNumber)
    {
        double unixTimeSeconds = [unixTimeNumber doubleValue];
        return (int)unixTimeSeconds;
    }
    return 0;
}
#pragma mark - Core data
- (NSManagedObjectContext *) managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"messageStorage" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSArray *thePathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSURL *storeUrl = [NSURL fileURLWithPath: [[thePathArray objectAtIndex:0] 
                                               stringByAppendingPathComponent: @"MessageStorage.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] 
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                  configuration:nil URL:storeUrl options:nil error:&error]) 
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator;
}
#pragma mark - Reset
-(void)clearDatabase
{
    NSArray *thePathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSURL *storeUrl = [NSURL fileURLWithPath: [[thePathArray objectAtIndex:0] 
                                               stringByAppendingPathComponent: @"MessageStorage.sqlite"]];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:storeUrl error:&error];
    if (error) 
    {
        #if defined (TESTING)
        [TestFlight passCheckpoint:@"Application failed to wipe core data storage. File doesn't exist at location (first run?)."];
        #endif
    }
    
    [persistentStoreCoordinator release];
    persistentStoreCoordinator = nil;
}
@end
