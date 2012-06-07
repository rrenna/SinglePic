//
//  SPAppDelegate.h
//  SinglePic
//
//  Created by Ryan Renna on 11-12-06.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPBaseController;

//Notifications
#define NOTIFICATION_APPLICATION_SETTINGS_CHANGED @"NOTIFICATION_APPLICATION_SETTINGS_CHANGED"
#define NOTIFICATION_DEVICE_PUSH_TOKEN_CHANGED @"NOTIFICATION_DEVICE_PUSH_TOKEN_CHANGED"
#define NOTIFICATION_PUSH_NOTIFICATION_RECIEVED @"NOTIFICATION_PUSH_NOTIFICATION_RECIEVED"

@interface SPAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

+(SPBaseController*)baseController;
-(NSString*)deviceToken;
-(NSDictionary*)settings;

@end
