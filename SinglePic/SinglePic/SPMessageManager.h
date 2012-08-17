//
//  SPMessageManager.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPSingleton.h"
#import "SPMessages.h"

#define MESSAGE_AUTO_REFRESH_TIMER 120 //seconds

extern NSString* NOTIFICATION_NEW_MESSAGES_RECIEVED;
extern NSString* NOTIFICATION_NO_MESSAGES_RECIEVED;

@interface SPMessageManager : SPSingleton
{
    @private
    NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

//Account manipulation
-(void)setActiveMessageAccount:(NSString*)accountID;
//Messages manipulation
-(void)forceRefresh;
-(NSArray*)activeMessageThreads;
-(SPMessageThread*)getMessageThreadByUserID:(NSString*)userID;
-(void)deleteMessageThread:(SPMessageThread*)thread;
//Sending messages
-(void)sendMessage:(NSString*)message toUserWithID:(NSString*)userID withCompletionHandler:(void (^)(SPMessage* message))onCompletion andErrorHandler:(void(^)())onError;
//Message Syncronization
-(void)sendSyncronizationReceiptWithCompletionHandler:(void (^)())onCompletion andErrorHandler:(void(^)())onError;
//Reset Procedure
-(void)clearDatabase;
@end
