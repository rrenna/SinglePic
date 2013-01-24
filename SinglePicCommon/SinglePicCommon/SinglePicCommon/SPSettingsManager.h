//
//  SPSettingsManager.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-04.
//
//

#import "SPSettings.h"

typedef enum
{
    ENVIRONMENT_TESTING = 0, //Default
    ENVIRONMENT_BETA = 1,
    ENVIRONMENT_PRODUCTION = 2
} ENVIRONMENT;

static const NSString* ENVIRONMENT_NAMES[] = { @"ENVIRONMENT_TESTING",@"ENVIRONMENT_BETA",@"ENVIRONMENT_PRODUCTION" };

@interface SPSettingsManager : NSObject

+ (SPSettingsManager *)sharedInstance;

//Setting Helper Methods
-(BOOL)canSwitchEnvironments;
-(BOOL)canSwitchDisplayVerboseErrors;

//Validates that the app is up to date, retrieves the latest server settings
-(void)validateAppWithCompletionHandler:(void (^)(BOOL needsUpdate,NSString* title, NSString* description))onCompletion;//Validates that this version of the app is valid (non-expired)

//Client Settings (User Controlled)
-(ENVIRONMENT)environment;
-(void)setEnvironment:(ENVIRONMENT)environment;
-(BOOL)displayVerboseErrorsEnabled;
-(void)setDisplayVerboseErrorsEnabled:(BOOL)enabled;
-(BOOL)soundEffectsEnabled;
-(void)setSoundEffectsEnabled:(BOOL)enabled;
-(BOOL)saveToCameraRollEnabled;
-(void)setSaveToCameraRollEnabled:(BOOL)enabled;
//App Settings (App/Server Controlled)
-(NSString*)serverAddress;
-(float)daysPicValid;
-(BOOL)imageRequiresFaceDetected;
@end
