//
//  SPErrorManager.h
//  SinglePic
//
//  Created by Ryan Renna on 12-02-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import "SPBaseApplicationController.h"
#import "SPErrorNotifierController.h"

@interface SPErrorManager : NSObject

@property (assign) id<SPBaseApplicationController> baseApplicationController;
@property (retain) id<SPErrorNotifierController> errorNotifierController;

+ (SPErrorManager *)sharedInstance;

//Used for non-critical alerts
-(void)alertWithTitle:(NSString*)title Description:(NSString*)description;
//Used for unexpected errors
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser; //Allows Reporting
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser allowReporting:(BOOL)allowReporting;

//Callback methods to be used by an Error Notifer Controller
-(NSError*)errorFromIdentifier:(int)identifier;
-(void)errorIdentifiedBy:(int)identifier presentedToUserRequiringFeedback:(BOOL)requiresFeedback;
-(void)errorIdentifiedBy:(int)identifier gatheredFeedback:(NSDictionary*)feedbackDictionary;
@end
