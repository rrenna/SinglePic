//
//  SPMessageManager.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPSingleton.h"
#import "SPMessageThread.h"
#import "SPMessages.h"

#define MESSAGE_AUTO_REFRESH_TIMER 120 //seconds

@interface SPMessageManager : SPSingleton

//Account 
-(void)setActiveMessageAccount:(NSString*)accountID;
//Messages
-(void)forceRefresh;
//--Threads
-(NSArray*)activeMessageThreads;
-(NSArray*)activeMessageThreadsSorted;
-(int)activeMessageThreadsCount;
-(SPMessageThread*)getMessageThreadByUserID:(NSString*)userID;
-(void)deleteMessageThread:(SPMessageThread*)thread;
//--Unread Messages
-(int)unreadMessagesCount;
-(void)readMessageThread:(SPMessageThread*)thread;
//--Sending Messages
-(void)sendMessage:(NSString*)message toUserWithID:(NSString*)userID withCompletionHandler:(void (^)(SPMessage* message))onCompletion andErrorHandler:(void(^)())onError;
//--Message Syncronization
-(void)sendSyncronizationReceiptWithCompletionHandler:(void (^)())onCompletion andErrorHandler:(void(^)())onError;
//Reset Procedure
-(void)clearDatabase;
@end
