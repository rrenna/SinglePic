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

@interface SPSettingsManager : SPSingleton
@property (retain) NSDictionary* settings;

-(void)validateAppWithCompletionHandler:(void (^)(BOOL needsUpdate,NSString* title, NSString* description))onCompletion;//Validates that this version of the app is valid (non-expired)
@end