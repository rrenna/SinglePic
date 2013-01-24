//
//  SPAppDelegate.m
//  SinglePic
//
//  Created by Ryan Renna on 11-12-06.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPAppDelegate.h"
#import "SPBaseController.h"
#import <objc/runtime.h>

//--NSUserDefault Keys--
//Device Keys
#define USER_DEFAULT_KEY_DEVICE_PUSH_TOKEN @"USER_DEFAULT_KEY_DEVICE_PUSH_TOKEN"

@interface SPAppDelegate()
@property (strong, nonatomic) SPBaseController *baseController;

-(void)setDeviceToken:(NSString*)token;
@end

@implementation SPAppDelegate
+(SPBaseController*)baseController
{
    SPAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.baseController;
}
#pragma mark
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    #if defined (BETA)
    [TestFlight takeOff:@"632bedfea5ff8b9b87a78088cf860d27_NDAyNTMyMDExLTExLTExIDA4OjI0OjAyLjEyMDQ1OQ"];
    #endif
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.baseController = [[SPBaseController alloc] initWithNibName:@"SPBaseController" bundle:nil];
    self.window.rootViewController = self.baseController;
    [self.window makeKeyAndVisible];
    
    //Setup Crashlytics Reporting
    [Crashlytics startWithAPIKey:@"9741e90523aaddc2c850b566f7fab4df77250742"];
    
    return YES;
}
#pragma mark - Push Notifications
-(NSString*)deviceToken
{
    NSString* _deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_DEVICE_PUSH_TOKEN];
    return _deviceToken;
}

-(void)registerForPushNotifications
{
    /* Device Push Notification Management */
    UIRemoteNotificationType requiredNotificationTypes = (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert);
        //We are not registered for all required notification types
        //Placing the registration here allows us to handle the case where the user presses 'NO' for allowing push notifications, then with the app minimized, changes it in the settings.
        // Let the device know we want to receive push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:requiredNotificationTypes];
}
-(void)unregisterForPushNotifications
{
     [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}
-(void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //Informs app of push notification being recieved
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PUSH_NOTIFICATION_RECIEVED object:nil];
    
    //Recieved a push notification from Apple's servers
    if([[SPProfileManager sharedInstance] myUserType] == USER_TYPE_PROFILE)
    {
        //Inform the application that a new message was recieved
        [[SPMessageManager sharedInstance] forceRefresh];
    }
}
-(void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //Recieved local notification - queued to be displayed by this app
}
-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken_
{
    NSString* deviceTokenString = [[[deviceToken_ description]
                                     stringByReplacingOccurrencesOfString: @"<" withString: @""] 
                                     stringByReplacingOccurrencesOfString: @">" withString: @""];
    
    #if defined (BETA)
    [TestFlight passCheckpoint:@"Registered for Remote Notification"];
    #endif
    
    [self setDeviceToken:deviceTokenString];
}
-(void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    //If registration has failed, a new registration will be attempted on the next wake
    #if defined (BETA)
    NSString *failString = [error description];
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Failed to register for Remote Notification : %@",failString]];
    #endif
}
#pragma mark
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}
#pragma mark - Private methods
-(void)setDeviceToken:(NSString*)token
{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:USER_DEFAULT_KEY_DEVICE_PUSH_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_PUSH_TOKEN_CHANGED object:nil];
}
@end
