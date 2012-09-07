//
//  SPSettingsManager.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-04.
//
//

#import "SPSettingsManager.h"

#define USER_DEFAULTS_LAST_SELECTED_ENVIRONMENT_KEY @"USER_DEFAULTS_LAST_SELECTED_ENVIRONMENT_KEY"

@interface SPSettingsManager()
{
    #ifndef RELEASE
    ENVIRONMENT _environment;
    #endif
}
@property (retain) NSDictionary* settings;
@end

@implementation SPSettingsManager
@synthesize settings = _settings;
@dynamic environment,serverAddress,defaultBucketID;

#pragma mark - Dynamic Properties
-(ENVIRONMENT)environment
{
    #ifdef RELEASE
    return PRODUCTION;
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
    #endif
}
-(NSString*)serverAddress
{
    #ifdef RELEASE
    return PRODUCTION_ADDRESS;
    #else
    if(_environment == TESTING)
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
    //When debugging reduce time until expiry
    #if defined (DEBUG)
    return 0.0013888; //2 minutes
    #else
    return 1;
    #endif
}
-(int)defaultBucketID
{
    return @"1";
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
        #endif
    }
    return self;
}
#pragma mark - Setting Helper Methods
-(BOOL)canSwitchEnvironments
{
    #ifdef RELEASE
    return NO;
    #else
    return YES;
    #endif
}
#pragma mark
//Validates that this version of the app is valid (non-expired)
-(void)validateAppWithCompletionHandler:(void (^)(BOOL needsUpdate,NSString* title, NSString* description))onCompletion
{
    //We perform different validation depending on if we're TESTING on TestFlight or not
    #if defined (TESTING)
    //This is used to enforce beta client expiry
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
        NSString* description = @"This version of SinglePic has expired. You will recieve an email when a newer version has been released. You may also check on www.testflightapp.com.";
    }
    
    onCompletion(needsUpdate,title,description);
    #else
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        //Re-enable below if we need to validate build number
        //NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    
    NSDictionary* validateDataDictionary = [NSDictionary dictionaryWithObjectsAndKeys:version,@"version",@"iOS/iPhone",@"platform",nil];
    NSData *jsonData = [[CJSONSerializer serializer] serializeObject:validateDataDictionary error:nil];
    NSString* payload = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
    
    [[SPRequestManager sharedInstance] postToNamespace:REQUEST_NAMESPACE_APP withParameter:nil andPayload:payload requiringToken:NO withCompletionHandler:^(id responseObject)
     {
        //retrieve server settings
        NSDictionary* settingsDictionary = [[CJSONDeserializer deserializer] deserialize:responseObject error:nil];
        self.settings = settingsDictionary;
         
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_APPLICATION_SETTINGS_CHANGED object:settingsDictionary];
         
        BOOL needsUpdate = NO;
        NSString* title = nil;
        NSString* description = nil;
         
        NSNumber* needsUpdateValue = [settingsDictionary objectForKey:@"needUpdate"];
        if([needsUpdateValue boolValue])
        {
            needsUpdate = YES;
            title = @"SinglePic is out of date";
            description = @"This version of SinglePic is (too) old. You should download the latest version on the App Store before continuing.";
        }
         
        onCompletion(needsUpdate,title,description);
         
     } andErrorHandler:^(SPWebServiceError *error)
     {
     }];
    #endif
}
@end
