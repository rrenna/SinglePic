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
#import "SPMessageAccount.h"
#import "SPMessageThread.h"
#import "SPMessage.h"
#import <Crashlytics/Crashlytics.h>

@interface SPMessageManager()
{
    BOOL retrievalInProgress;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}
@property (retain) SPMessageAccount* activeAccount;
- (NSManagedObjectContext *) managedObjectContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
-(NSSet*)messageThreads;
- (void)retrieveMessages;
- (SPMessage*)saveMessage:(NSString*)messageBody toThread:(SPMessageThread*)thread isIncoming:(BOOL)incoming atTime:(NSDate*)time;
-(long long)unixTimeOfLastMessage;
@end

@implementation SPMessageManager
@synthesize activeAccount;

-(id)init
{
    self = [super init];
    if(self)
    {
        retrievalInProgress = NO;
    }
    return self;
}
#pragma mark - Accounts
-(void)setActiveMessageAccount:(NSString*)accountID
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SPMessageAccount"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"identifier == %@",accountID]];
    
        //Asks core data to prefetch the Threads messages relationship
    NSArray* fetchedRelationshipArray = @[@"threads",@"activeThreads"];
    [fetchRequest setRelationshipKeyPathsForPrefetching:fetchedRelationshipArray];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count] == 1)
    {
        self.activeAccount =  [fetchedObjects objectAtIndex:0];
    }
    else
    {
            //Create a Message Account object for this accountID
        self.activeAccount = [NSEntityDescription insertNewObjectForEntityForName:@"SPMessageAccount" inManagedObjectContext:[self managedObjectContext]];
        self.activeAccount.identifier = accountID;
    }
}
#pragma mark - Messages
-(void)forceRefresh
{
        //Force the refresh of messages
    [self retrieveMessages];
}
-(NSArray*)activeMessageThreads
{
    [[self managedObjectContext] refreshObject:self.activeAccount mergeChanges:YES];
    NSSet* activeThreads = [self.activeAccount activeThreads];
    return activeThreads.allObjects;
}
-(SPMessageThread*)getMessageThreadByUserID:(NSString*)userID
{
    SPMessageThread* thread = nil;
    for(SPMessageThread* thread_ in [self messageThreads])
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
        thread.account = self.activeAccount;
    }
    
    return thread;
}
-(NSArray*)activeMessageThreadsSorted
{
    return [[self activeMessageThreads] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        SPMessageThread* thread1 = (SPMessageThread*)obj1;
        SPMessageThread* thread2 = (SPMessageThread*)obj2;
        
        NSTimeInterval interval = [thread1.lastActivity timeIntervalSinceDate:thread2.lastActivity];
        
        return (interval < 0);
    }];
}
-(int)activeMessageThreadsCount
{
    return [[self activeMessageThreads] count];
}
-(void)deleteMessageThread:(SPMessageThread*)thread
{
    [[self managedObjectContext] deleteObject:thread];
    [[self managedObjectContext] save:nil];
}
#pragma mark - Unread Messages
-(int)unreadMessagesCount
{
        //TODO: Implement unread message count
    return 0;
}
#pragma mark - Sending Messages
-(void)sendMessage:(NSString*)messageBody toUserWithID:(NSString*)userID withCompletionHandler:(void (^)(SPMessage* message))onCompletion andErrorHandler:(void(^)())onError
{
    NSString* parameter = [NSString stringWithFormat:@"%@/msg",userID];
    NSDictionary* payload = [NSDictionary dictionaryWithObjectsAndKeys:messageBody,@"message",nil];
    
    __unsafe_unretained SPMessageManager* weakSelf = self;
    [[SPRequestManager sharedInstance] postToNamespace:REQUEST_NAMESPACE_USERS withParameter:parameter andPayload:payload requiringToken:YES withCompletionHandler:^(id responseObject)
     {
         NSDate* now = [NSDate date];
         
             //Find the User Thread if active
         SPMessageThread* thread = [weakSelf getMessageThreadByUserID:userID];
         
         SPMessage* newMessage = [weakSelf saveMessage:messageBody toThread:thread isIncoming:NO atTime:now];
         
         [managedObjectContext save:nil];
             //Run completion block
         onCompletion(newMessage);
         
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_SENT object:nil];
         
     } andErrorHandler:^(SPWebServiceError *error) {
         
         if(onError)
         {
             onError();
         }
         
     }];
}
#pragma mark - Message Syncronization
-(void)sendSyncronizationReceiptWithCompletionHandler:(void (^)())onCompletion andErrorHandler:(void(^)())onError
{
    long long unixTimeOfLastMessage = [self unixTimeOfLastMessage];
    
    NSString* parameter;
    if(unixTimeOfLastMessage == 0)
    {
        parameter = [NSString stringWithFormat:@"%@/msg/time/0",USER_ID_ME];
    }
    else
    {
        parameter = [NSString stringWithFormat:@"%@/msg/time/%lld",USER_ID_ME,unixTimeOfLastMessage];
    }
    
    #ifndef RELEASE
    LogMessageCompat(@"Clear Messages with parameter : %@",parameter);
    #endif
    
    [[SPRequestManager sharedInstance] deleteFromNamespace:REQUEST_NAMESPACE_USERS withParameter:parameter requiringToken:YES withCompletionHandler:^(id responseObject)
     {
             //Reset Badge
         [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
         
         onCompletion();
     }
     andErrorHandler:^(SPWebServiceError *error)
     {
         if(onError)
         {
             onError(error);
         }
     }];
}
#pragma mark - Private methods
-(NSSet*)messageThreads
{
    return [self.activeAccount threads];
}
-(void)retrieveMessages
{
    if(retrievalInProgress) return;
    
    retrievalInProgress = YES;
    long long unixTimeOfLastMessage = [self unixTimeOfLastMessage];
    
    NSString* parameter;
    if(unixTimeOfLastMessage == 0)
    {
        parameter = [NSString stringWithFormat:@"%@/msg/time/0",USER_ID_ME];
    }
    else
    {
        parameter = [NSString stringWithFormat:@"%@/msg/time/%lld",USER_ID_ME,unixTimeOfLastMessage];
    }
    
    #ifndef RELEASE
    LogMessageCompat(@"Retieve Messages with parameter : %@",parameter);
    #endif
    
    __unsafe_unretained SPMessageManager* weakSelf = self;
    [[SPRequestManager sharedInstance] getFromNamespace:REQUEST_NAMESPACE_USERS withParameter:parameter requiringToken:YES withCompletionHandler:^(id responseObject)
     {
         NSError *theError = nil;
         NSArray* messagesData = [[CJSONDeserializer deserializer] deserialize:responseObject error:&theError];
         
         #ifndef RELEASE
         LogMessageCompat(@"%@",messagesData);
         #endif
         
         if([messagesData count] > 0)
         {
             NSMutableArray* newMessages = [NSMutableArray array];
             BOOL messagesRecieved = NO;
             long long newestUnixTime = 0;
             
             //Update the Unix time of our retrieval (sets to the latest timestamp that can be found in the retrieved messages
             // to ensure we are consistent with the server's time
             for(NSDictionary* messageData in messagesData)
             {
                 NSNumber* unixTimeNumber = [messageData objectForKey:@"timeStamp"];
                 long long unixTime = [unixTimeNumber longLongValue];
                 
                 //We update the unix time to allow for syncronization with the server
                 if(unixTime > newestUnixTime)
                 {
                     newestUnixTime = unixTime; //Finds the unix time of the youngest message
                 }
             }
             
             //Saves the unix time of the youngest message (sent the latests)
             [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:newestUnixTime] forKey:UNIX_TIME_OF_LAST_MESSAGE_RETRIEVED_KEY];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             //Inform the user that we've recieved the messages successfully
             [weakSelf sendSyncronizationReceiptWithCompletionHandler:^
              {
                  for(NSDictionary* messageData in messagesData)
                  {
                      NSString* userID = [messageData objectForKey:@"from"];
                      NSString* message = [messageData objectForKey:@"message"];
                      NSNumber* unixTimeNumber = [messageData objectForKey:@"timeStamp"];
                      long long unixTime = [unixTimeNumber longLongValue];
                      
                    //Find the User Thread if active
                      SPMessageThread* thread = [weakSelf getMessageThreadByUserID:userID];
                      
                      //We store the NSDate for sorting
                      //NSDate deals with seconds instead of milliseconds, device by 1000 to remove
                      NSDate* time = [NSDate dateWithTimeIntervalSince1970:(unixTime/1000)];
                      
                      [weakSelf saveMessage:message toThread:thread isIncoming:YES atTime:time];
                  }
                  
                  //Reset Badge
                  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                  
                  //Vibrate the device (NOTE: Does nothing on devices which do not support vibrations)
                  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                      
                  NSError* error = nil;
                  [managedObjectContext save:&error];
                      
                  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NEW_MESSAGES_RECIEVED object:nil];
                  
                  #ifndef RELEASE
                  LogMessageCompat(@"Syncronization complete");
                  #endif
                  
                  retrievalInProgress = NO;
              }
              andErrorHandler:^
              {
                  #ifndef RELEASE
                  LogMessageCompat(@"Syncronization failure!!");
                  #endif
                  
                  //Resets the unix time to it's initial value
                  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:unixTimeOfLastMessage] forKey:UNIX_TIME_OF_LAST_MESSAGE_RETRIEVED_KEY];
                  [[NSUserDefaults standardUserDefaults] synchronize];
                  
                  
                  retrievalInProgress = NO;
                  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NO_MESSAGES_RECIEVED object:nil];
              }];
             
         }
         else
         {
             retrievalInProgress = NO;
             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NO_MESSAGES_RECIEVED object:nil];
         }
         
     } andErrorHandler:^(NSError* error)
     {
         retrievalInProgress = NO;
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NO_MESSAGES_RECIEVED object:nil];
     }];
    
        //}
}
- (SPMessage*)saveMessage:(NSString*)messageBody toThread:(SPMessageThread*)thread isIncoming:(BOOL)incoming atTime:(NSDate*)time
{
    thread.lastActivity = time;
    thread.active = YES_NSNUMBER;
    
        //Create SPMessage
    SPMessage* newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"SPMessage" inManagedObjectContext:[self managedObjectContext]];
    newMessage.content = messageBody;
    newMessage.incoming = (incoming) ? YES_NSNUMBER : NO_NSNUMBER;
    newMessage.date = time;
    
    [thread addMessagesObject:newMessage];
    
    return newMessage;
}
- (long long)unixTimeOfLastMessage
{
    //Retrieve the last stored retrieval date from NSUserDefaults in seconds
    NSNumber* unixTimeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:UNIX_TIME_OF_LAST_MESSAGE_RETRIEVED_KEY];
    if(unixTimeNumber)
    {
        return [unixTimeNumber longLongValue];
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
#pragma mark - Complete Wipe
-(void)clearDatabase
{
    NSArray *thePathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSURL *storeUrl = [NSURL fileURLWithPath: [[thePathArray objectAtIndex:0]
                                               stringByAppendingPathComponent: @"MessageStorage.sqlite"]];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:storeUrl error:&error];
    if (error)
    {
#if defined (BETA)
        [TestFlight passCheckpoint:@"Application failed to wipe core data storage. File doesn't exist at location (first run?)."];
#endif
    }
    
    [managedObjectContext release];
    managedObjectContext = nil;
    [persistentStoreCoordinator release];
    persistentStoreCoordinator = nil;
}
@end