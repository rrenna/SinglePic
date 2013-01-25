//
//  PMAProfileManager.h
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPBucket.h"
#import "SPProfiles.h"
#import "SPProfile.h"
#import "SPBaseApplicationController.h"

//Constants
static __attribute__((unused)) NSString* USER_ID_ME  = @"me";

#pragma mark
@interface SPProfileManager : NSObject

@property (weak) id<SPBaseApplicationController> baseApplicationController;

+ (SPProfileManager *)sharedInstance;

//My Profile
-(USER_TYPE)myUserType;
-(SPBucket*)myBucket;
-(NSString*)myUserID;
-(NSString*)myUserName;
-(NSDate*)myExpiry;
-(id)myImage;
-(NSString*)myIcebreaker;
-(NSString*)myEmail;
-(GENDER)myGender;
-(GENDER)myPreference;
-(BOOL)myPushTokenSynced;

//Helper Function
-(BOOL)isImageExpired;
-(BOOL)isImageSet;

//Annonymous - to be used when not in a registered state
-(SPBucket*)myAnnonymousBucket;
-(GENDER)myAnnonymousGender;
-(GENDER)myAnnonymousPreference;

//Permissions
-(BOOL)canSendMessages;

//Annonymous Set Methods
/*---can be called publicly as they do not need to be synced with the server---*/
-(void)setMyAnnonymousBucket:(SPBucket*)_bucket synchronize:(BOOL)synchronize;
-(void)setMyAnnonymousGender:(GENDER)_gender;
-(void)setMyAnnonymousPreference:(GENDER)_preference;

//Undo Methods - sets the value(s) to their previous value locally and saves the result
-(BOOL)undoMyImageWithCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError;

//Save Methods - sets the value(s) locally and saves the result
-(void)saveMyBucket:(SPBucket*)_bucket withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError;
-(void)saveMyPicture:(id)_image withCompletionHandler:(void (^)(id responseObject))onCompletion andProgressHandler:(void (^)(float progress))onProgress andErrorHandler:(void(^)())onError;
-(void)saveMyPicture:(id)image_ withProperties:(NSDictionary*)properties andCompletionHandler:(void (^)(id responseObject))onCompletion andProgressHandler:(void (^)(float progress))onProgress andErrorHandler:(void(^)())onError;
-(void)saveMyIcebreaker:(NSString*)_icebreaker withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError;
-(void)saveMyGender:(GENDER)_gender andPreference:(GENDER)_preference withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError;
-(void)saveMyIcebreaker:(NSString*)_icebreaker andGender:(GENDER)_gender andPreference:(GENDER)_preference withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError;
//Save Additional Methods - used in conjunction with Save methods
-(void)requestURLsToSaveMyPictureWithCompletionHandler:(void (^)(NSURL* imageUploadURL,NSURL* thumbnailUploadURL))onCompletion andErrorHandler:(void(^)())onError;

//Authentication
-(void)validateUserWithCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError;//Validates that the stored credentials are valid
-(void)registerDevicePushTokenWithCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError;//Registers the current device's push Token, enabling the server to push this device notifications while offline
//----Registration
-(void)registerWithEmail:(NSString*)email_ andUserName:(NSString*)userName_ andPassword:(NSString*)password_ andGender:(GENDER)gender_ andPreference:(GENDER)preference_ andBucket:(SPBucket*)bucket_ andCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError;//Registers the current annonymous user
-(void)checkUserName:(NSString*)userName_ forRegistrationWithCompletionHandler:(void (^)(bool taken))onCompletion;//Check if a given username is taken
//----Login
-(void)loginWithEmail:(NSString*)email_ andPassword:(NSString*)password_ andCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError;//Log in with an existing user
-(void)logout;//Log out of current user account

//Profiles
-(void)restartProfiles;
-(int)remainingProfiles;
-(SPProfile*)nextProfile;
-(void)retrieveProfile:(NSString*)profileID withCompletionHandler:(void (^)(SPProfile* profile))onCompletion andErrorHandler:(void(^)())onError;
-(void)retrieveProfilesWithIDs:(NSArray*)profileIDArray withCompletionHandler:(void (^)(NSArray* profiles))onCompletion andErrorHandler:(void(^)())onError;
-(void)retrieveProfilesWithCompletionHandler:(void (^)(NSArray* profiles))onCompletion andErrorHandler:(void(^)())onError;

//Images
-(void)retrieveProfileThumbnail:(SPProfile*)profile withCompletionHandler:(void (^)(id thumbnail))onCompletion andErrorHandler:(void(^)())onError;
-(void)retrieveProfileImage:(SPProfile*)profile withCompletionHandler:(void (^)(id image))onCompletion andErrorHandler:(void(^)())onError;

//Blocking Users
-(void)blockProfile:(SPProfile*)profile withCompletionHandler:(void (^)())onCompletion andErrorHandler:(void(^)())onError;
//Likes
-(BOOL)checkIsLiked:(SPProfile*)profile;
-(void)retrieveLikesWithCompletionHandler:(void (^)(NSArray* likes))onCompletion andErrorHandler:(void(^)())onError;
-(void)retrieveLikedByWithCompletionHandler:(void (^)(NSArray* likes))onCompletion andErrorHandler:(void(^)())onError;
-(void)addProfile:(SPProfile*)profile toToLikesWithCompletionHandler:(void(^)())onCompletion andErrorHandler:(void(^)())onError;
-(void)removeProfile:(SPProfile*)profile fromLikesWithCompletionHandler:(void(^)())onCompletion andErrorHandler:(void(^)())onError;
@end
