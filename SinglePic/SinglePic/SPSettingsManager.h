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
    ENVIRONMENT_TESTING, //Default
    ENVIRONMENT_BETA,
    ENVIRONMENT_PRODUCTION
} ENVIRONMENT;

@interface SPSettingsManager : NSObject
@property (readonly) NSString* serverAddress;
@property (assign) ENVIRONMENT environment;
@property (readonly) CGFloat daysPicValid;
@property (readonly) NSString* defaultBucketID;

+ (SPSettingsManager *)sharedInstance;

//Setting Helper Methods
-(BOOL)canSwitchEnvironments;
-(BOOL)canSwitchDisplayVerboseErrors;

//Validates that the app is up to date, retrieves the latest server settings
-(void)validateAppWithCompletionHandler:(void (^)(BOOL needsUpdate,NSString* title, NSString* description))onCompletion;//Validates that this version of the app is valid (non-expired)
//Client Settings
-(BOOL)displayVerboseErrorsEnabled;
-(void)setDisplayVerboseErrorsEnabled:(BOOL)enabled;
-(BOOL)soundEffectsEnabled;
-(void)setSoundEffectsEnabled:(BOOL)enabled;
-(BOOL)saveToCameraRollEnabled;
-(void)setSaveToCameraRollEnabled:(BOOL)enabled;
@end
