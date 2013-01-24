//
//  SPMessages.h
//  SinglePic
//
//  Created by Ryan Renna on 12-02-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

//Used to place information about SinglePic messaging that other components may need to reference

//Static Keys
static NSString* const UNIX_TIME_OF_LAST_MESSAGE_RETRIEVED_KEY = @"UNIX_TIME_OF_LAST_MESSAGE_RETRIEVED_KEY";

//Static Notifications
static NSString* const NOTIFICATION_MESSAGE_SENT = @"NOTIFICATION_MESSAGE_SENT";
static NSString* const NOTIFICATION_NEW_MESSAGES_RECIEVED = @"NOTIFICATION_NEW_MESSAGES_RECIEVED";
static NSString* const NOTIFICATION_NO_MESSAGES_RECIEVED  = @"NOTIFICATION_NO_MESSAGES_RECIEVED";
static NSString* const NOTIFICATION_NEW_MESSAGES_READ = @"NOTIFICATION_NEW_MESSAGES_READ";