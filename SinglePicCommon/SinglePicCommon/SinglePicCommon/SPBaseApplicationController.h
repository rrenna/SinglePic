//
//  SPBaseApplicationController.h
//  SinglePicCommon
//
//  Created by Ryan Renna on 2013-01-24.
//  Copyright (c) 2013 Ryan Renna. All rights reserved.
//

@protocol SPBaseApplicationController <NSObject>

//Push
-(BOOL)canRegisterForPushNotifications;
-(void)registerForPushNotifications;
-(void)unregisterForPushNotifications;
-(NSString*)deviceToken;

//Communication
-(BOOL)canSendMail;
-(void)presentEmailWithRecipients:(NSArray*)recipients andSubject:(NSString*)subject andBody:(NSString*)body;
@end
