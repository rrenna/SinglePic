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

@interface SPErrorManager : NSObject

@property (assign) id<SPBaseApplicationController> baseApplicationController;

+ (SPErrorManager *)sharedInstance;

//Used for non-critical alerts
-(void)alertWithTitle:(NSString*)title Description:(NSString*)description;
//Used for unexpected errors
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser; //Allows Reporting
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser allowReporting:(BOOL)allowReporting;
@end
