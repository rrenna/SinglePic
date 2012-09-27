//
//  SPSettingsManager.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-04.
//
//

#import "SPSingleton.h"
#import "SPSettings.h"

typedef enum
{
    ENVIRONMENT_TESTING, //Default
    ENVIRONMENT_BETA,
    ENVIRONMENT_PRODUCTION
} ENVIRONMENT;

@interface SPSettingsManager : SPSingleton
@property (readonly) NSString* serverAddress;
@property (assign) ENVIRONMENT environment;
@property (readonly) CGFloat daysPicValid;
@property (readonly) NSString* defaultBucketID;

//Setting Helper Methods
-(BOOL)canSwitchEnvironments;
-(BOOL)shouldDisplayVerboseErrors;

//Validates that the app is up to date, retrieves the latest server settings
-(void)validateAppWithCompletionHandler:(void (^)(BOOL needsUpdate,NSString* title, NSString* description))onCompletion;//Validates that this version of the app is valid (non-expired)
@end
