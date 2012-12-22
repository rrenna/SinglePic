//
//  SPErrorManager.h
//  SinglePic
//
//  Created by Ryan Renna on 12-02-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@interface SPErrorManager : NSObject <UIAlertViewDelegate,MFMailComposeViewControllerDelegate>

+ (SPErrorManager *)sharedInstance;

//Used for non-critical alerts
-(void)alertWithTitle:(NSString*)title Description:(NSString*)description;
//Used for unexpected errors
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser; //Allows Reporting
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser allowReporting:(BOOL)allowReporting;
@end
