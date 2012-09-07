//
//  SPSettingsManager.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-04.
//
//

#import "SPSingleton.h"

//Notifications
#define NOTIFICATION_APPLICATION_SETTINGS_CHANGED @"NOTIFICATION_APPLICATION_SETTINGS_CHANGED"

typedef enum
{
    TESTING = 0, //Default
    PRODUCTION
} ENVIRONMENT;

@interface SPSettingsManager : SPSingleton
@property (retain,readonly) NSString* serverAddress;
@property (assign) ENVIRONMENT environment;

//Helper Settings
-(BOOL)canSwitchEnvironments;

//Validates that the app is up to date, retrieves the latest server settings
-(void)validateAppWithCompletionHandler:(void (^)(BOOL needsUpdate,NSString* title, NSString* description))onCompletion;//Validates that this version of the app is valid (non-expired)
@end
