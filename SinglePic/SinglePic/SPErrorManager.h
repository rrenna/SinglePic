//
//  SPErrorManager.h
//  SinglePic
//
//  Created by Ryan Renna on 12-02-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPSingleton.h"
#import <MessageUI/MessageUI.h>

@interface SPErrorManager : SPSingleton <UIAlertViewDelegate,MFMailComposeViewControllerDelegate>
{
@private
    NSMutableArray* errors;
    NSArray* knownErrors; // Known errors are url + httpMethod + error code combinations that when reported are given special treatment
}

//Used for non-critical alerts
-(void)alertWithTitle:(NSString*)title Description:(NSString*)description;
//Used for unexpected errors
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser; //Allows Reporting
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser allowReporting:(BOOL)allowReporting;
@end
