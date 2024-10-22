//
//  SPSettingsManager.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-04.
//
//

#import "SPSettingsManager.h"

#define USER_DEFAULTS_LAST_SELECTED_ENVIRONMENT_KEY @"USER_DEFAULTS_LAST_SELECTED_ENVIRONMENT_KEY"
#define USER_DEFAULTS_SOUND_EFFECTS_ENABLED_KEY @"USER_DEFAULTS_SOUND_EFFECTS_ENABLED_KEY"
#define USER_DEFAULTS_SAVE_TO_CAMERA_ROLL_KEY @"USER_DEFAULTS_SAVE_TO_CAMERA_ROLL_KEY"
#define USER_DEFAULTS_DISPLAY_VERBOSE_ERRORS_KEY @"USER_DEFAULTS_DISPLAY_VERBOSE_ERRORS_KEY"

@interface SPSettingsManager()
{
    ENVIRONMENT _environment;

    #ifndef PUBLIC_BETA
    BOOL _imageRequiresFaceDetected;
    #endif
}
@property (retain) NSDictionary* serverSettings;
@end

@implementation SPSettingsManager

+ (SPSettingsManager *)sharedInstance
{
    static dispatch_once_t once;
    static SPSettingsManager *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[SPSettingsManager alloc] init]; });
    return sharedInstance;
}

#pragma mark
-(id)init
{
    self = [super init];
    if(self)
    {
        #ifndef RELEASE
        ENVIRONMENT lastSelectedEnvironment = (ENVIRONMENT)[[NSUserDefaults standardUserDefaults] integerForKey:USER_DEFAULTS_LAST_SELECTED_ENVIRONMENT_KEY];
        _environment = lastSelectedEnvironment;
        _imageRequiresFaceDetected = YES;
        #else
        _environment = ENVIRONMENT_PRODUCTION;
        #endif
        
        [Crashlytics setObjectValue:ENVIRONMENT_NAMES[_environment] forKey:@"settings_environment"];
    }
    return self;
}
#pragma mark - Setting Helper Methods
-(BOOL)canSwitchEnvironments
{
    #ifdef PRIVATE
    return YES;
    #else
    return NO;
    #endif
}
-(BOOL)canSwitchDisplayVerboseErrors
{
    #ifdef PRIVATE
    return YES;
    #else
    return NO;
    #endif
}
#pragma mark
//Validates that this version of the app is valid (non-expired)
-(void)validateAppWithCompletionHandler:(void (^)(BOOL needsUpdate,NSString* title, NSString* description))onCompletion
{
    //We perform different validation depending on if we're TESTING on TestFlight or not
    #if defined (PUBLIC_BETA)
    //This is used to enforce beta client expiry for Public beta testing
    //Expires on
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
    [components setYear:BETA_EXPIRY_YEAR];
    [components setMonth:BETA_EXPIRY_MONTH];
    [components setDay:BETA_EXPIRY_DAY];
    NSDate* expiryDate = [calendar dateFromComponents:components];
    
    BOOL needsUpdate = NO;
    NSString* title = nil;
    NSString* description = nil;
    
    if([[NSDate date] earlierDate:expiryDate] == expiryDate)
    {
        needsUpdate = YES;
        title = @"SinglePic Beta has expired";
        description = @"This version of SinglePic has expired. You will recieve an email when a newer version has been released. You may also check on www.testflightapp.com.";
    }
    
    onCompletion(needsUpdate,title,description);
    #else
    
    //Sends app version, and that this is the iOS app to the server to be validated
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSDictionary* payload = [NSDictionary dictionaryWithObjectsAndKeys:version,@"version",@"iOS/iPhone",@"platform",nil];
    
    [[SPRequestManager sharedInstance] postToNamespace:REQUEST_NAMESPACE_APP withParameter:nil andPayload:payload requiringToken:NO withCompletionHandler:^(id responseObject)
     {
        //retrieve server settings
        NSError* theError = nil;
        NSData* responseData = (NSData*)responseObject;
        NSDictionary* settingsDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&theError];
         
        self.serverSettings = settingsDictionary;
         
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SERVER_SETTINGS_CHANGED object:nil];
         
        BOOL needsUpdate = NO;
        NSString* title = nil;
        NSString* description = nil;
         
        NSNumber* needsUpdateValue = [settingsDictionary objectForKey:@"needUpdate"];
        if([needsUpdateValue boolValue])
        {
            needsUpdate = YES;
            title = NSLocalizedString(@"SinglePic is out of date",nil);
            description = NSLocalizedString(@"This version of SinglePic is too old.",nil);
        }
         
         NSNumber* imagesRequireFaceDetectedValue = [settingsDictionary objectForKey:@"imagesRequireFaceDetected"];
         if(imagesRequireFaceDetectedValue)
         {
             _imageRequiresFaceDetected = [imagesRequireFaceDetectedValue boolValue];
         }
         
        onCompletion(needsUpdate,title,description);
         
     } andErrorHandler:^(SPWebServiceError *error)
     {
  
     }];
    #endif
}
#pragma mark - Client Settings (User Controlled)
-(ENVIRONMENT)environment
{
    #ifdef PUBLIC
        return ENVIRONMENT_PRODUCTION;
    #else
        return _environment;
    #endif
}
-(void)setEnvironment:(ENVIRONMENT)environment
{
    NSAssert([self canSwitchEnvironments], @"An attempt to switch environments has been made in an instance that shouldn't be able to.");
    
    #ifndef RELEASE
        [[NSUserDefaults standardUserDefaults] setInteger:environment forKey:USER_DEFAULTS_LAST_SELECTED_ENVIRONMENT_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    
        _environment = environment;
    
        [Crashlytics setObjectValue:ENVIRONMENT_NAMES[_environment] forKey:@"settings_environment"];
    #endif
}
-(BOOL)displayVerboseErrorsEnabled
{
    #ifdef PRIVATE
    if([[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_DISPLAY_VERBOSE_ERRORS_KEY])
    {
        return [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_DISPLAY_VERBOSE_ERRORS_KEY];
    }
    else
    {
        return YES;
    }
    #else
    return NO;
    #endif
}
-(void)setDisplayVerboseErrorsEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:USER_DEFAULTS_DISPLAY_VERBOSE_ERRORS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CLIENT_SETTINGS_CHANGED object:nil];
}
//Client Settings
-(BOOL)soundEffectsEnabled
{
    if([[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_SOUND_EFFECTS_ENABLED_KEY])
    {
        return [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_SOUND_EFFECTS_ENABLED_KEY];
    }
    else
    {
        return SOUND_EFFECTS_ENABLED_DEFAULT;
    }
}
-(void)setSoundEffectsEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:USER_DEFAULTS_SOUND_EFFECTS_ENABLED_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CLIENT_SETTINGS_CHANGED object:nil];
}
-(BOOL)saveToCameraRollEnabled
{
    if([[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_SAVE_TO_CAMERA_ROLL_KEY])
    {
        return [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_SAVE_TO_CAMERA_ROLL_KEY];
    }
    else
    {
        return SAVE_TO_CAMERA_ROLL_DEFAULT;
    }
}
-(void)setSaveToCameraRollEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:USER_DEFAULTS_SAVE_TO_CAMERA_ROLL_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CLIENT_SETTINGS_CHANGED object:nil];
}
#pragma mark - App Settings (App/Server Controlled)
-(NSString*)serverAddress
{
    #ifdef PUBLIC
        return PRODUCTION_ADDRESS;
    #else
        if([self environment] == ENVIRONMENT_PRODUCTION)
        {
            return PRODUCTION_ADDRESS;
        }
        else
        {
            return TESTING_ADDRESS;
        }
    #endif
}
-(CGFloat)daysPicValid
{
    #ifdef DEBUG
        return 0.25; //When debugging reduce time until expiry to 6 hours
    #endif
        
    #ifdef PRIVATE_BETA
        return PHOTO_EXPIRY_DAYS / 2; //During beta tests reduce time until expiry by 50%
    #endif
        
    #ifdef PUBLIC_BETA
        return PHOTO_EXPIRY_DAYS - 5; //During beta tests reduce time until expiry by 5 days (currently 2 days)
    #endif
        
    #ifdef PUBLIC_RELEASE
        return PHOTO_EXPIRY_DAYS;
    #endif
}
-(BOOL)imageRequiresFaceDetected
{
    #if defined (PUBLIC_BETA)
    //Public beta users do not retrieve dynamic server settings, this setting is hard-coded for them
    return YES;
    #endif
    
    return _imageRequiresFaceDetected;
}
@end
