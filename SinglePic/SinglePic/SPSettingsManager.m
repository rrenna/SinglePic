//
//  SPSettingsManager.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-04.
//
//

#import "SPSettingsManager.h"

@implementation SPSettingsManager
@synthesize settings = _settings;

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
