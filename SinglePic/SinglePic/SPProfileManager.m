//
//  PMAProfileManager.m
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPProfileManager.h"
#import "SPProfile.h"

@interface SPProfileManager()
{
    BOOL _hasProfileImage;
    NSCache* _thumbnails;
    NSMutableArray* _likes;
    NSArray* _likedBy;
}
@property (retain) NSMutableArray* profiles;
@property (assign) USER_TYPE userType;
@property (retain) SPBucket* bucket;
@property (retain) UIImage* image;
@property (retain) UIImage* lastImage;
@property (retain) NSString* userID;
@property (retain) NSString* userName;
@property (retain) NSDate* expiry;
@property (retain) NSString* icebreaker;
@property (retain) NSString* email;
@property (assign) GENDER gender;
@property (assign) GENDER preference;
@property (assign) BOOL hasProfileImageSet;

//Set Methods - sets the value(s) locally, optionally callinging syncronize when completed - should only be called from within the SPProfileManager
-(void)setMyImage:(UIImage*)_image;
-(void)setMyIcebreaker:(NSString*)_icebreaker synchronize:(BOOL)synchronize;
-(void)setMyEmail:(NSString*)_email synchronize:(BOOL)synchronize;
-(void)setMyGender:(GENDER)_gender synchronize:(BOOL)synchronize;
-(void)setMyPreference:(GENDER)_preference synchronize:(BOOL)synchronize;
-(void)setMyBucket:(SPBucket*)bucket_ synchronize:(BOOL)synchronize;
-(void)setMyUserID:(NSString*)userID synchronize:(BOOL)synchronize;
-(void)setMyUserName:(NSString*)userID synchronize:(BOOL)synchronize;
-(void)setMyExpiry:(NSDate*)expiry_ synchronize:(BOOL)synchronize;
-(void)setMyPushTokenSynced:(BOOL)synced synchronize:(BOOL)synchronize;

//Used for generating a JSON string to set a new profile
-(NSMutableDictionary*)generateProfileDataWithIcebreaker:(NSString*)_icebreaker andGender:(GENDER)_gender andPreference:(GENDER)_preference;

//Helper methods
-(void) clearProfile;
-(void) wipeProfiles;
@end

//--NSUserDefault Keys--
//Device Keys
#define USER_DEFAULT_KEY_DEVICE_PUSH_TOKEN_SYNCED @"USER_DEFAULT_KEY_DEVICE_PUSH_TOKEN" /*The token was succesfully sent to the server */
//Profile Keys
#define USER_DEFAULT_KEY_USER_TYPE @"USER_DEFAULT_KEY_USER_TYPE"
#define USER_DEFAULT_KEY_USER_ID @"USER_DEFAULT_KEY_USER_ID"
#define USER_DEFAULT_KEY_USER_NAME @"USER_DEFAULT_KEY_USER_NAME"
#define USER_DEFAULT_KEY_EXPIRY @"USER_DEFAULT_KEY_EXPIRY"
#define USER_DEFAULT_KEY_USER_BUCKET @"USER_DEFAULT_KEY_USER_BUCKET"
#define USER_DEFAULT_KEY_USER_IMAGE_ORIENTATION @"USER_DEFAULT_KEY_USER_IMAGE_ORIENTATION"
#define USER_DEFAULT_KEY_USER_ICEBREAKER @"USER_DEFAULT_KEY_USER_ICEBREAKER"
#define USER_DEFAULT_KEY_USER_EMAIL @"USER_DEFAULT_KEY_USER_EMAIL"
#define USER_DEFAULT_KEY_USER_GENDER @"USER_DEFAULT_KEY_USER_GENDER"
#define USER_DEFAULT_KEY_USER_PREFERENCE @"USER_DEFAULT_KEY_USER_PREFERENCE"
//Annonymous Keys
#define USER_DEFAULT_KEY_ANNONYMOUS_BUCKET @"USER_DEFAULT_KEY_ANNONYMOUS_BUCKET"
#define USER_DEFAULT_KEY_ANNONYMOUS_GENDER @"USER_DEFAULT_KEY_ANNONYMOUS_GENDER"
#define USER_DEFAULT_KEY_ANNONYMOUS_PREFERENCE @"USER_DEFAULT_KEY_ANNONYMOUS_PREFERENCE"

@implementation SPProfileManager

+ (SPProfileManager *)sharedInstance
{
    static dispatch_once_t once;
    static SPProfileManager *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[SPProfileManager alloc] init]; });
    return sharedInstance;
}

@dynamic hasProfileImageSet;
#pragma mark - Dynamic Properties
-(BOOL)hasProfileImageSet
{
    [self myImage]; //Ensure's we attempt to load an image - which will record a flag telling us if the image is custom
    return _hasProfileImage;
}
#pragma mark
-(id)init
{
    self = [super init];
    if(self)
    {
        self.profiles = [NSMutableArray array];
        _thumbnails = [NSCache new];
        _likes = [NSMutableArray new];
    }
    return self;
}
#pragma mark - My Profile
-(USER_TYPE)myUserType
{
    if(!self.userType)
    {
        if([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_USER_TYPE])
        {
            NSNumber* userTypeValue = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_USER_TYPE];
            self.userType = (USER_TYPE)[userTypeValue intValue];
        }
        else
        {
            self.userType = USER_TYPE_ANNONYMOUS;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.userType] forKey:USER_DEFAULT_KEY_USER_TYPE];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    return self.userType;
}
-(NSString*)myUserID
{
    if(!self.userID)
    {
        self.userID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_USER_ID];
    }
    return self.userID;
}
-(NSString*)myUserName
{
    if(!self.userName)
    {
        self.userName = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_USER_NAME];
    }
    return self.userName;
}
-(NSDate*)myExpiry
{
    if(!self.expiry)
    {
        self.expiry = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_EXPIRY];
    }
    return self.expiry;
}
-(SPBucket*)myBucket
{
    if(!self.bucket)
    {
        NSData* encodedBucketData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_USER_BUCKET];
        self.bucket = [NSKeyedUnarchiver unarchiveObjectWithData: encodedBucketData];
    }
    return self.bucket;
}
-(UIImage*)myImage
{
    if(!self.image)
    {
        _hasProfileImage = YES;
        // Create file manager
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:[self myUserID]];
        self.image = [UIImage imageWithContentsOfFile:path];
        
        if(!self.image)
        {
            _hasProfileImage = NO;
        }
    }
    
    return self.image;
}
-(NSString*)myIcebreaker
{
    if(!self.icebreaker)
    {
        self.icebreaker = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_USER_ICEBREAKER];
        if(!self.icebreaker) self.icebreaker = @""; //Default icebreaker, if none has been set, is an empty string
    }
    
    return self.icebreaker;
}
-(NSString*)myEmail
{
    if(!self.email)
    {
        self.email = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_USER_EMAIL];
        if(!self.email) self.email = @""; //Default email, if none has been set, is an empty string
    }
    
    return self.email;
}
static BOOL RETRIEVED_GENDER_FROM_DEFAULTS = NO;
-(GENDER)myGender
{
    if(!RETRIEVED_GENDER_FROM_DEFAULTS)
    {
        NSNumber* genderNumber =[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_USER_GENDER];
        if(genderNumber) self.gender = (GENDER)[genderNumber intValue];
        RETRIEVED_GENDER_FROM_DEFAULTS = YES;
    }
    return self.gender;
}
static BOOL RETRIEVED_PREFERENCE_FROM_DEFAULTS = NO;
-(GENDER)myPreference
{
    if(!RETRIEVED_PREFERENCE_FROM_DEFAULTS)
    {
        NSNumber* preferenceNumber =[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_USER_PREFERENCE];
        if(preferenceNumber) self.preference = (GENDER)[preferenceNumber intValue];
        RETRIEVED_PREFERENCE_FROM_DEFAULTS = YES;
    }
    return self.preference;
}
-(BOOL)myPushTokenSynced
{
    NSNumber* pushTokenRegistered = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_DEVICE_PUSH_TOKEN_SYNCED];
    //If we've recorded no push token registration flag, or it's false return NO
    if(!pushTokenRegistered || ![pushTokenRegistered boolValue])
    {
        return NO;
    }
    return YES;
}
#pragma mark - Helper Function
-(BOOL)isImageExpired
{
    NSDate* expiry = [self myExpiry];
    NSTimeInterval interval = [expiry timeIntervalSinceNow];
    
    return (interval <= 0);
}
-(BOOL)isImageSet
{
    return self.hasProfileImageSet;
}
#pragma mark - Annonymous
-(SPBucket*)myAnnonymousBucket
{
    NSData* encodedBucketData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_ANNONYMOUS_BUCKET];
    return [NSKeyedUnarchiver unarchiveObjectWithData: encodedBucketData];
}
-(GENDER)myAnnonymousGender
{
    GENDER annonymousGender = GENDER_UNSPECIFIED;
    NSNumber* genderNumber =[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_ANNONYMOUS_GENDER];
    if(genderNumber) annonymousGender = (GENDER)[genderNumber intValue];
    
    return annonymousGender;
}
-(GENDER)myAnnonymousPreference
{
    GENDER annonymousPreference = GENDER_UNSPECIFIED;
    NSNumber* genderNumber =[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_ANNONYMOUS_PREFERENCE];
    if(genderNumber) annonymousPreference = (GENDER)[genderNumber intValue];
    
    return annonymousPreference;
}
#pragma mark - Set Profile Methods
-(void)setMyImage:(UIImage*)image_
{
    if (image_ != nil)
    {
        _hasProfileImage = YES;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent: 
                          [NSString stringWithString: [self myUserID] ] ];
        NSData* data = UIImageJPEGRepresentation(image_,1.0);
        
        //Save image to disk
        [data writeToFile:path atomically:YES];
        
        //Save orientation to NSUserDefaults
        [[NSUserDefaults standardUserDefaults] setInteger:image_.imageOrientation forKey:USER_DEFAULT_KEY_USER_IMAGE_ORIENTATION];
        
        self.image = image_;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MY_IMAGE_CHANGED object:nil];
    }
}
-(void)setMyIcebreaker:(NSString*)icebreaker_ synchronize:(BOOL)synchronize
{
    self.icebreaker = icebreaker_;
    [[NSUserDefaults standardUserDefaults] setObject:self.icebreaker forKey:USER_DEFAULT_KEY_USER_ICEBREAKER];
    
    if(synchronize)[[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MY_ICEBREAKER_CHANGED object:nil];
}
-(void)setMyEmail:(NSString*)email_ synchronize:(BOOL)synchronize
{
    self.email = email_;
    [[NSUserDefaults standardUserDefaults] setObject:self.email forKey:USER_DEFAULT_KEY_USER_EMAIL];
    
    if(synchronize)[[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MY_EMAIL_CHANGED object:nil];
}
-(void)setMyGender:(GENDER)gender_ synchronize:(BOOL)synchronize
{
    if([self myGender] != gender_)
    {
        //After a gender/preference has successfully been set, reset the profile stream
        [[SPProfileManager sharedInstance] restartProfiles];
        
        self.gender = gender_;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.gender] forKey:USER_DEFAULT_KEY_USER_GENDER];
        
        if(synchronize) [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MY_GENDER_CHANGED object:nil];
    }
}
-(void)setMyPreference:(GENDER)preference_ synchronize:(BOOL)synchronize
{
    if([self myPreference] != preference_)
    {
        //After a gender/preference has successfully been set, reset the profile stream
        [[SPProfileManager sharedInstance] restartProfiles];
        
        self.preference = preference_;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.preference] forKey:USER_DEFAULT_KEY_USER_PREFERENCE];
    
        if(synchronize) [[NSUserDefaults standardUserDefaults] synchronize];
    
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MY_PREFERENCE_CHANGED object:nil];
    }
}
-(void)setMyBucket:(SPBucket*)bucket_ synchronize:(BOOL)synchronize
{
    self.bucket = bucket_;
    
    [Crashlytics setObjectValue:bucket_ forKey:@"profile_bucket"];
    
    NSData *encodedBucket = [NSKeyedArchiver archivedDataWithRootObject:bucket_];
    [[NSUserDefaults standardUserDefaults] setObject:encodedBucket forKey:USER_DEFAULT_KEY_USER_BUCKET];
    
    if(synchronize) [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MY_BUCKET_CHANGED object:nil];
}
-(void)setMyUserID:(NSString*)userID_ synchronize:(BOOL)synchronize
{
    self.userID = userID_;
    
    [Crashlytics setObjectValue:userID_ forKey:@"profile_userid"];
    
    [[NSUserDefaults standardUserDefaults] setObject:userID_ forKey:USER_DEFAULT_KEY_USER_ID];
    
    if(synchronize) [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MY_USER_ID_CHANGED object:nil];
}
-(void)setMyUserName:(NSString*)userName_ synchronize:(BOOL)synchronize
{
    self.userName = userName_;
    
     [Crashlytics setObjectValue:userName_ forKey:@"profile_username"];
    
    [[NSUserDefaults standardUserDefaults] setObject:userName_ forKey:USER_DEFAULT_KEY_USER_NAME];
    
    if(synchronize) [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MY_USER_NAME_CHANGED object:nil];
}
-(void)setMyExpiry:(NSDate*)expiry_ synchronize:(BOOL)synchronize
{
    self.expiry = expiry_;
    
    //Schedule local notification on expiry (and clear any currently scheduled ones)
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if(![self isImageExpired])
    {
        UILocalNotification* expiryNotification = [[UILocalNotification alloc] init];
        expiryNotification.fireDate = expiry_;
        expiryNotification.alertBody = NOTIFICATION_BODY_IMAGE_EXPIRY;
        [[UIApplication sharedApplication] scheduleLocalNotification:expiryNotification];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.expiry forKey:USER_DEFAULT_KEY_EXPIRY];
    
    if(synchronize) [[NSUserDefaults standardUserDefaults] synchronize];  
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MY_EXPIRY_CHANGED object:nil];
}
-(void)setMyPushTokenSynced:(BOOL)synced synchronize:(BOOL)synchronize
{
    if(synced)
    {
        [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:USER_DEFAULT_KEY_DEVICE_PUSH_TOKEN_SYNCED];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_KEY_DEVICE_PUSH_TOKEN_SYNCED];
    }
    
    if(synchronize) [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark - Annonymous Set methods
-(void)setMyAnnonymousBucket:(SPBucket*)bucket_ synchronize:(BOOL)synchronize
{
    NSData *encodedBucket = [NSKeyedArchiver archivedDataWithRootObject:bucket_];
    [[NSUserDefaults standardUserDefaults] setObject:encodedBucket forKey:USER_DEFAULT_KEY_ANNONYMOUS_BUCKET];
        
    if(synchronize) [[NSUserDefaults standardUserDefaults] synchronize];
        
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MY_ANNONYMOUS_BUCKET_CHANGED object:nil];
}
-(void)setMyAnnonymousGender:(GENDER)gender_
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:gender_] forKey:USER_DEFAULT_KEY_ANNONYMOUS_GENDER];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MY_ANNONYMOUS_GENDER_CHANGED object:nil];
}
-(void)setMyAnnonymousPreference:(GENDER)preference_
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:preference_] forKey:USER_DEFAULT_KEY_ANNONYMOUS_PREFERENCE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MY_ANNONYMOUS_PREFERENCE_CHANGED object:nil];
}
#pragma mark - Permissions
-(BOOL)canSendMessages
{
    return (self.hasProfileImageSet && (![self isImageExpired]) );
}
#pragma mark - Undo Methods
-(BOOL)undoMyImageWithCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError
{
    if(self.lastImage)
    {
        [self saveMyPicture:self.lastImage withCompletionHandler:onCompletion andProgressHandler:nil andErrorHandler:onError];
        return YES;
    }
    else
    {
        //If an undo is unavaliable
        return NO;
    }
}
#pragma mark - Save Methods
-(void)saveMyBucket:(SPBucket*)bucket_ withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError
{
    NSString* parameter = [NSString stringWithFormat:@"%@",[bucket_ identifier]];
    
    __unsafe_unretained SPProfileManager* weakSelf = self;
    [[SPRequestManager sharedInstance] postToNamespace:REQUEST_NAMESPACE_BUCKETS withParameter:parameter andPayload:nil requiringToken:YES withCompletionHandler:^(id responseObject)
     {         
         [weakSelf setMyBucket:bucket_ synchronize:YES];
         onCompletion(responseObject);
         
     } 
     andErrorHandler:^(NSError* error)
     {
         if(onError)
         {
             onError();
             
         }
     }];
}
-(void)saveMyIcebreaker:(NSString*)icebreaker_ withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError
{
    [self saveMyIcebreaker:icebreaker_ andGender:nil andPreference:nil withCompletionHandler:onCompletion andErrorHandler:onError];
}
static CGSize MAXIMUM_IMAGE_SIZE = {275.0,275.0};
static CGSize MAXIMUM_THUMBNAIL_SIZE = {146.0,146.0};
-(void)saveMyPicture:(UIImage*)image_ withCompletionHandler:(void (^)(id responseObject))onCompletion andProgressHandler:(void (^)(float progress))onProgress andErrorHandler:(void(^)())onError
{
    __unsafe_unretained SPProfileManager* weakSelf = self;
    void (^imageAndThumbnailUploaded)(id completedResponseObject) = ^(id completedResponseObject)
    {
        //Confirm with the server that the images have been uploaded. This tells the server to set the current time as your upload time.
        NSString* parameter = [NSString stringWithFormat:@"%@/imageupdated",USER_ID_ME];
        [[SPRequestManager sharedInstance] postToNamespace:REQUEST_NAMESPACE_USERS withParameter:parameter andPayload:nil requiringToken:YES withCompletionHandler:^(id responseObject)
        {
            //If there has been an image set, store it in an historic state (for an undo operation)
            if(weakSelf.image)
            {
                weakSelf.lastImage = weakSelf.image;
            }
            
            NSTimeInterval interval = SECONDS_PER_DAY * [[SPSettingsManager sharedInstance] daysPicValid];
            //Set my Expiry
            [weakSelf setMyExpiry:[NSDate dateWithTimeIntervalSinceNow:interval] synchronize:NO];
            //Set my Image
            [weakSelf setMyImage:image_];
            
            onCompletion(completedResponseObject);
            
        }
        andErrorHandler:^(SPWebServiceError *error) 
        {
            if(onError)
            {
                onError();
            }
        }];
    };

    [self requestURLsToSaveMyPictureWithCompletionHandler:^(NSURL *imageUploadURL, NSURL *thumbnailUploadURL) 
    {
        //Upload Image & Thumbnail
        __block BOOL imageUploaded = NO;
        __block BOOL thumbnailUploaded = NO;
        
        //Upload the fullsized image
        //Never uploads the full quality image ( > 7mb on iPhone 4)
        UIImage *resizedImage = [image_ resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:MAXIMUM_IMAGE_SIZE interpolationQuality:kCGInterpolationHigh];
        
        //Upload the thumbnail image
        UIImage *resizedThumbnail = [resizedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:MAXIMUM_THUMBNAIL_SIZE interpolationQuality:kCGInterpolationHigh];
        
        [[SPRequestManager sharedInstance] putToURL:imageUploadURL withPayload:resizedImage withCompletionHandler:^(id responseObject)
         {
             //Flag that the image has been uploaded, and if the thumbnail has been uploaded, we are done
             imageUploaded = YES;
             if(thumbnailUploaded)
             {
                 imageAndThumbnailUploaded(responseObject);
             }
         }
         andProgressHandler:^(float progress)
         {
             if(onProgress)
             {
                 onProgress(progress);
             }
         }
         andErrorHandler:^(NSError* error)
         {
             if(onError)
             {
                 onError();
             }
         }];
        
        [[SPRequestManager sharedInstance] putToURL:thumbnailUploadURL withPayload:resizedThumbnail withCompletionHandler:^(id responseObject)
         {
             //Flag that the image has been uploaded, and if the thumbnail has been uploaded, we are done
             thumbnailUploaded = YES;
             if(imageUploaded)
             {
                 imageAndThumbnailUploaded(responseObject);
             }
         }
         andProgressHandler:^(float progress) {
             
             if(onProgress)
             {
                 onProgress(progress);
             }
         }
         andErrorHandler:^(NSError* error)
         {
             if(onError)
             {
                 onError();
             }
         }];

    } 
    andErrorHandler:^
    {
        if(onError)
        {
            onError();
            
        }
    }];
}
-(void)saveMyGender:(GENDER)gender_ andPreference:(GENDER)preference_ withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError
{
    [self saveMyIcebreaker:nil andGender:gender_ andPreference:preference_ withCompletionHandler:onCompletion andErrorHandler:onError];
}
-(void)saveMyIcebreaker:(NSString*)icebreaker_ andGender:(GENDER)gender_ andPreference:(GENDER)preference_ withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError
{
    NSDictionary* payload = [self generateProfileDataWithIcebreaker:icebreaker_ andGender:gender_ andPreference:preference_];
    
    __unsafe_unretained SPProfileManager* weakSelf = self;
    [[SPRequestManager sharedInstance] postToNamespace:REQUEST_NAMESPACE_USERS withParameter:USER_ID_ME andPayload:payload requiringToken:YES withCompletionHandler:^(id responseObject) 
     {
         #ifdef PRIVATE
         LogMessageCompat(@"Updated Icebreaker/Gender/Preference with payload : %@",payload);
         #endif
         
         if(icebreaker_)
         {
             [weakSelf setMyIcebreaker:icebreaker_ synchronize:NO];
         }
         if(gender_)
         {
             [weakSelf setMyGender:gender_ synchronize:NO];
         }
         if(preference_)
         {
             [weakSelf setMyPreference:preference_ synchronize:YES];
         }
         onCompletion(responseObject);
         
     } 
     andErrorHandler:^(SPWebServiceError *error) 
     {
        #ifdef PRIVATE
        LogMessageCompat(@"Failed to updated Icebreaker/Gender/Preference with payload : %@",payload);
        #endif
         
        if(onError)
        {
            onError();
        }
     }];
}
#pragma mark - Additonal Save Methods
//Not only is used to generate URL's to save images and thumbnails, but can be called in advance to cache the urls for an upcoming upload
static NSURL* _imageUploadURLCache = nil;
static NSURL* _thumbnailUploadURLCache = nil;
-(void)requestURLsToSaveMyPictureWithCompletionHandler:(void (^)(NSURL* imageUploadURL,NSURL* thumbnailUploadURL))onCompletion andErrorHandler:(void(^)())onError
{
    //Returned any cached url
    if(_imageUploadURLCache && _thumbnailUploadURLCache)
    {
        onCompletion(_imageUploadURLCache,_thumbnailUploadURLCache);
        
        _imageUploadURLCache = nil;
        _thumbnailUploadURLCache = nil;
    }
    //Make a new request
    else
    {
        NSString* parameter = [NSString stringWithFormat:@"%@/imageputurl",USER_ID_ME];
        [[SPRequestManager sharedInstance] getFromNamespace:REQUEST_NAMESPACE_USERS withParameter:parameter requiringToken:YES withCompletionHandler:^(id responseObject) 
         {
             NSError *theError = nil;
             
             NSData* responseData = (NSData*)responseObject;
             NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&theError];
             
             NSString* imageUploadURLString = [responseDictionary objectForKey:@"urlFullImage"];
             NSString* thumbnailUploadURLString = [responseDictionary objectForKey:@"urlThumbImage"];
             
             //Clear any previously cached URLs
             _imageUploadURLCache = nil;
             _thumbnailUploadURLCache = nil;
             
             _imageUploadURLCache = [NSURL URLWithString:imageUploadURLString];
             _thumbnailUploadURLCache = [NSURL URLWithString:thumbnailUploadURLString];
             
             onCompletion(_imageUploadURLCache,_thumbnailUploadURLCache);
             
             
         }
         andErrorHandler:^(SPWebServiceError *error) 
         {
             if(onError)
             {
                 onError();
                 
             }
         }];
    }
}
#pragma mark - Authentication methods
#define AUTHENTICATION_RETRY_COUNT 2
//Validates that the stored credentials are valid
-(void)validateUserWithCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError
{
    //We cannot provide the User Token as a parameter without making it URL safe, as it's 64bit encoding may allow a '/' character
    NSString* userToken = [[SPRequestManager sharedInstance] userToken];
    NSString * escapedUserToken = (__bridge_transfer NSString*) CFURLCreateStringByAddingPercentEscapes(
                                                                                      NULL,
                                                                                      (CFStringRef)userToken,
                                                                                      NULL,
                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                      kCFStringEncodingUTF8 );
    
    __unsafe_unretained SPProfileManager* weakSelf = self;
    [[SPRequestManager sharedInstance] getFromNamespace:REQUEST_NAMESPACE_TOKENS withParameter:escapedUserToken requiringToken:NO withRetryCount:AUTHENTICATION_RETRY_COUNT withCompletionHandler:^(id responseObject)
    {
        //User Token is valid
        
        #if defined (BETA)
        [TestFlight passCheckpoint:@"User Token validated"];
        #endif
    
        //We now confirm this user has synced this device's push token with their user profile
        if(![weakSelf myPushTokenSynced])
        {
            //If not, we attempt to sync the device's push token with the user's profile
            [weakSelf registerDevicePushTokenWithCompletionHandler:^(id responseObject) {} andErrorHandler:^{}];
        }
        
        //After validation set this user as the active message account
        [[SPMessageManager sharedInstance] setActiveMessageAccount:[weakSelf myUserID]];
        
        //On successful validation - register for device push notifications
        SPAppDelegate* delegate = (SPAppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate registerForPushNotifications];
        
        onCompletion(responseObject);
        
    }
    andErrorHandler:^(SPWebServiceError *error)
    {
        #if defined (BETA)
        NSString* errorString = [NSString stringWithFormat:@"User Token invalid. Reason : %@",[error localizedFailureReason]];
        [TestFlight passCheckpoint:errorString];
        #endif
        
            //Token is invalid - reset user type
        weakSelf.userType = USER_TYPE_ANNONYMOUS;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:USER_TYPE_ANNONYMOUS] forKey:USER_DEFAULT_KEY_USER_TYPE];
        [[NSUserDefaults standardUserDefaults] synchronize];
            // remove token - any other stored information about this profile
        [weakSelf clearProfile];
        
        //On failed validation - deregister for device push notifications
        SPAppDelegate* delegate = (SPAppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate unregisterForPushNotifications];
        
        if(onError)
        {
            onError();
            
        }
    }];
}
-(void)loginWithEmail:(NSString*)email_ andPassword:(NSString*)password_ andCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError
{
    NSDictionary* payload = [NSDictionary dictionaryWithObjectsAndKeys:email_,@"email",password_,@"password",nil];
    
    __unsafe_unretained SPProfileManager* weakSelf = self;
    [[SPRequestManager sharedInstance] postToNamespace:REQUEST_NAMESPACE_TOKENS withParameter:nil andPayload:payload requiringToken:NO withCompletionHandler:^(id responseObject)
     {
         NSError *theError = nil;
         
         NSData* responseData = (NSData*)responseObject;
         NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&theError];

         //Retrieve server generated attributes
         NSString* userToken_ = [responseDictionary objectForKey:@"token"];
         NSDictionary* user_ = [responseDictionary objectForKey:@"user"];//Retrieve the user profile
         NSString* userID_ = [user_ objectForKey:@"id"];
         NSString* userName_ = [user_ objectForKey:@"userName"];
         NSString* userBucketID_ = [user_ objectForKey:@"bucket"];
         NSString* userIcebreaker_ = [user_ objectForKey:@"icebreaker"];
         NSString* userGender_ = [user_ objectForKey:@"gender"];
         NSString* userPreference_ = [user_ objectForKey:@"lookingForGender"];
         NSString* lastUpdatedServerTime_ = [user_ objectForKey:@"lastUpdated"];
         NSString* imageURL_ = [user_ objectForKey:@"imageURL"];
         
         NSDate* lastUpdated = [TimeHelper dateWithServerTime:lastUpdatedServerTime_];
         NSDate* expiry = [lastUpdated dateByAddingTimeInterval:SECONDS_PER_DAY * [[SPSettingsManager sharedInstance] daysPicValid]];
         
         void (^onImageRecieved)(UIImage*) = ^(UIImage* responseImage) {
         
             [[SPBucketManager sharedInstance] retrieveBucketsWithCompletionHandler:^(NSArray *buckets)
              {
                  //Find the appropriate bucket object
                  SPBucket* userBucket_ = nil;
                  for(SPBucket* bucket_ in buckets)
                  {
                      if([[bucket_ identifier] isEqualToString:userBucketID_])
                      {
                          userBucket_ = bucket_; break;
                      }
                  }
                  //Ensure the bucket id was found (is a valid bucket)
                  if(userBucket_)
                  {
                      [[SPRequestManager sharedInstance] setUserToken:userToken_ synchronize:NO]; //Tells the request manager to not synchronize the user token setting, as the NSUserDefaults will be synchronized at the end of this block
                      [weakSelf setMyUserID:userID_ synchronize:NO];
                      [weakSelf setMyUserName:userName_ synchronize:NO];
                      [weakSelf setMyEmail:email_ synchronize:NO]; //Tells the profile manager to not synchronize the user token setting, as the NSUserDefaults will be synchronized at the end of this block
                                                                   //NOTE : Should not cache the password
                      [weakSelf setMyBucket:userBucket_ synchronize:NO];
                      [weakSelf setMyIcebreaker:userIcebreaker_ synchronize:NO];
                      [weakSelf setMyGender:GENDER_FROM_NAME(userGender_) synchronize:NO];
                      [weakSelf setMyPreference:GENDER_FROM_NAME(userPreference_) synchronize:NO];
                      [weakSelf setMyExpiry:expiry synchronize:NO];
                      [weakSelf setMyImage:responseImage];
                      
                      
                      weakSelf.userType = USER_TYPE_PROFILE;
                      [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:weakSelf.userType] forKey:USER_DEFAULT_KEY_USER_TYPE];
                      [[NSUserDefaults standardUserDefaults] synchronize];
                      
                      //After login set this user as the active message account
                      [[SPMessageManager sharedInstance] setActiveMessageAccount:[weakSelf myUserID]];
                      
                      //Registers for Push notifications
                      [weakSelf registerDevicePushTokenWithCompletionHandler:^(id responseObject)
                      {
                      } andErrorHandler:nil];
                      
                      //On successful login - register for device push notifications
                      SPAppDelegate* delegate = (SPAppDelegate*)[[UIApplication sharedApplication] delegate];
                      [delegate registerForPushNotifications];
                      
                      onCompletion(responseObject);
                      
                      //Notify application that the user type has changed
                      [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MY_USER_TYPE_CHANGED object:nil];
                  }
                  //If the bucket wasn't found, than the process cannot continue
                  else {
                      
                      if(onError)
                      {
                          onError();
                      }
                  }
                  
              }
              andErrorHandler:^
              {
                  if(onError)
                  {
                      onError();
                  }
              }];
         };
         
         //If an image URL is defined, attempt to download the image
         if(![imageURL_ isEqualToString:@""])
         {
             [[SPRequestManager sharedInstance] getImageFromURL:[NSURL URLWithString:imageURL_] withCompletionHandler:onImageRecieved
             andErrorHandler:^(NSError* error)
             {
                 if(onError)
                 {
                     //Report login failed due to failed image download
                     [[SPErrorManager sharedInstance] logError:error alertUser:YES allowReporting:YES];
                     onError();
                 }
             }];
         }
         else
         {
             //Continue without an image
             onImageRecieved(nil);
         }
             
     } andErrorHandler:^(NSError *error) {
         
         if(onError)
         {
             onError();
         }
     }];
}
-(void)logout
{
    #if defined (BETA)
    [TestFlight passCheckpoint:@"User logged out"];
    #endif
    
    //Token is invalid - reset user type
    self.userType = USER_TYPE_ANNONYMOUS;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:USER_TYPE_ANNONYMOUS] forKey:USER_DEFAULT_KEY_USER_TYPE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // remove token - any other stored information about this profile
    [self clearProfile];
    
    SPAppDelegate* delegate = (SPAppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate unregisterForPushNotifications];
    
    //Notify application that the user type has changed
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MY_USER_TYPE_CHANGED object:nil];
}
#pragma mark - Registration
-(void)registerWithEmail:(NSString*)email_ andUserName:(NSString*)userName_ andPassword:(NSString*)password_ andGender:(GENDER)gender_ andPreference:(GENDER)preference_ andBucket:(SPBucket*)bucket_ andCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError
{
    if(self.myUserType != USER_TYPE_ANNONYMOUS)
    {
        return; //Already registered
    }
    
    NSMutableDictionary* payload = [NSMutableDictionary dictionaryWithObjectsAndKeys:userName_,@"userName",email_,@"email",password_,@"password",GENDER_NAMES[gender_],@"gender",GENDER_NAMES[preference_],@"lookingForGender",[bucket_ identifier],@"bucket",nil];
    
    //If we have an approximate location for this user, pass it into the registration process
    CLLocation* location = [[SPLocationManager sharedInstance] location];
    if(location)
    {
        NSString* latString = [NSString stringWithFormat:@"%f",location.coordinate.latitude]; 
        NSString* lonString = [NSString stringWithFormat:@"%f",location.coordinate.longitude]; 
        
        [payload setObject:latString forKey:@"lattitude"];
        [payload setObject:lonString forKey:@"longitude"];
    }
    
    __unsafe_unretained SPProfileManager* weakSelf = self;
    [[SPRequestManager sharedInstance] postToNamespace:REQUEST_NAMESPACE_USERS withParameter:nil andPayload:payload requiringToken:NO withCompletionHandler:^(id responseObject) 
    {
        NSError *theError = nil;
        
        NSData* responseData = (NSData*)responseObject;
        NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&theError];

        //Retrieve server generated attributes
        NSString* userID_ = [[responseDictionary objectForKey:@"id"] stringValue];
        NSString* userToken_ = [responseDictionary objectForKey:@"token"];
        
        //'synchronize:NO' tells the profile manager to not synchronize the specific setting, as the NSUserDefaults will be synchronized at the end of this block
        [[SPRequestManager sharedInstance] setUserToken:userToken_ synchronize:NO];
        [weakSelf setMyUserID:userID_ synchronize:NO];
        [weakSelf setMyUserName:userName_ synchronize:NO];
        [weakSelf setMyEmail:email_ synchronize:NO]; 
        [weakSelf setMyGender:gender_ synchronize:NO];
        [weakSelf setMyPreference:preference_ synchronize:NO];
        [weakSelf setMyBucket:bucket_ synchronize:NO];
        [weakSelf setMyExpiry:nil synchronize:NO];
        
        //NOTE : Should not cache the password
        weakSelf.userType = USER_TYPE_PROFILE;
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:weakSelf.userType] forKey:USER_DEFAULT_KEY_USER_TYPE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //Set Message Account
        [[SPMessageManager sharedInstance] setActiveMessageAccount:[weakSelf myUserID]];
        
        //Registers for Push notifications
        [weakSelf registerDevicePushTokenWithCompletionHandler:^(id responseObject) 
         {
         } andErrorHandler:^
         {
         }];
        
        onCompletion(responseObject);
        
        
        //Notify application that the user type has changed
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MY_USER_TYPE_CHANGED object:nil];
    } 
    andErrorHandler:^(NSError* error)
    {
        //If for any reason registration fails. We should ensure that no User Token is cached, another registration attempt can then be retried.
        [weakSelf clearProfile];
        
        if(onError)
        {
            onError();
            
        }
    }];
}
-(void)checkUserName:(NSString*)userName_ forRegistrationWithCompletionHandler:(void (^)(bool taken))onCompletion
{
    [[SPRequestManager sharedInstance] getFromNamespace:REQUEST_NAMESPACE_USERNAMES withParameter:userName_ requiringToken:NO withCompletionHandler:^(id responseObject)
    {
        onCompletion(YES);
        
    }
    andErrorHandler:^(SPWebServiceError *error)
    {
        onCompletion(NO);
        
    }];
}
-(void)registerDevicePushTokenWithCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)())onError
{
    //Register profile for future requests
    SPAppDelegate* delegate = (SPAppDelegate*)[UIApplication sharedApplication].delegate;
    NSString* deviceToken = [delegate deviceToken];

    if(deviceToken)
    {        
        NSString* parameter = [NSString stringWithFormat:@"%@/pushToken",USER_ID_ME];

        __unsafe_unretained SPProfileManager* weakSelf = self;
        [[SPRequestManager sharedInstance] postToNamespace:REQUEST_NAMESPACE_USERS withParameter:parameter andPayload:@{@"pushToken":deviceToken} requiringToken:YES withCompletionHandler:^(id responseObject)
         {
             #if defined (BETA)
             [TestFlight passCheckpoint:@"Registered Device Push Token"];
             #endif
             
             [weakSelf setMyPushTokenSynced:YES synchronize:YES];
             onCompletion(responseObject);
             
         } 
         andErrorHandler:^(NSError* error)
         {
            #if defined (BETA)
            [TestFlight passCheckpoint:@"Failed to register Device Push Token - call failed"];
            #endif
             
            [weakSelf setMyPushTokenSynced:NO synchronize:YES];//If we've logged into an account on this device before, we may have the flag set to true. This absolutely ensure's the flag is set to false, so another token registration is attempted in the future
             
             if(onError)
             {
                 onError();
                 
             }
         }];
    }
    else
    {
        #if defined (BETA)
        [TestFlight passCheckpoint:@"Failed to register Device Push Token - no device token recorded"];
        #endif
         
        [self setMyPushTokenSynced:NO synchronize:YES];//If we've logged into an account on this device before, we may have the flag set to true. This absolutely ensure's the flag is set to false, so another token registration is attempted in the future
        
        if(onError)
        {
            onError();
            
        }
    }
}
#pragma mark - Profiles
//Used to keep track of the current profile index
static int profileCounter = 0;
-(void)restartProfiles
{
    profileCounter = 0;
}
-(int)remainingProfiles
{
    int remainingProfiles = [self.profiles count] - profileCounter;
    return MAX(0, remainingProfiles);
}
-(SPProfile*)nextProfile
{
    if([self.profiles count] > profileCounter)
    {
        id profile = [self.profiles objectAtIndex:profileCounter];
        profileCounter++;
        
        return profile;
    }
    else
    {
        return nil;
    }
}
-(void)retrieveProfile:(NSString*)profileID withCompletionHandler:(void (^)(SPProfile* profile))onCompletion andErrorHandler:(void(^)())onError
{
    [self retrieveProfilesWithIDs:[NSArray arrayWithObject:profileID] withCompletionHandler:^(NSArray *profiles) 
    {
        //If a single profile is returned, as expected, return it
        if([profiles count] == 1)
        {
            onCompletion([profiles objectAtIndex:0]);
            
        }
        else
        {
            if(onError)
            {
                onError();
                
            }
        }

    } 
    andErrorHandler:^
    {
        if(onError)
        {
            onError();
            
        }
    }];
}
-(void)retrieveProfilesWithIDs:(NSArray*)profileIDArray withCompletionHandler:(void (^)(NSArray* profiles))onCompletion andErrorHandler:(void(^)())onError
{
    [[SPRequestManager sharedInstance] postToNamespace:REQUEST_NAMESPACE_USERS withParameter:nil andPayload:profileIDArray requiringToken:YES withCompletionHandler:^(id responseObject) 
     {
         NSMutableArray* _pickedProfiles = [NSMutableArray array];
         NSError *theError = nil;
         
         NSData* responseData = (NSData*)responseObject;
         NSDictionary* profilesData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&theError];

         @autoreleasepool {
             
             for(NSDictionary* userData in profilesData)
             {
                 SPProfile* profile = [[SPProfile alloc] initWithData:userData];
                 [_pickedProfiles addObject:profile];
             }
         }

         //Return the retrieved profiles
         onCompletion(_pickedProfiles);
         
     } 
     andErrorHandler:^(NSError* error)
     {
         if(onError)
         {
             onError();
             
         }
     }];
}
-(void)retrieveProfilesWithCompletionHandler:(void (^)(NSArray* profiles))onCompletion andErrorHandler:(void(^)())onError
{
    [self restartProfiles];
    
    double currenTimeInterval = [[NSDate date] timeIntervalSince1970];
    //Start Time (default = 7 days ago)
    #if defined (PUBLIC)
    int intStartTime = (int)(currenTimeInterval - (SECONDS_PER_DAY * PHOTO_EXPIRY_DAYS));
    #else
    int intStartTime = 0; 
    #endif
    //End Time (now)
    int intCurrentTime = (int)currenTimeInterval;
    
    if([self myUserType] == USER_TYPE_ANNONYMOUS)
    {
        NSString* parameter = [NSString stringWithFormat:@"undefined/gender/%@/lookingforgender/%@/starttime/%d000/endtime/%d000",GENDER_NAMES[GENDER_UNSPECIFIED],GENDER_NAMES[GENDER_UNSPECIFIED],intStartTime,intCurrentTime];
        
        __unsafe_unretained SPProfileManager* weakSelf = self;
        [[SPRequestManager sharedInstance] getFromNamespace:REQUEST_NAMESPACE_BUCKETS withParameter:parameter requiringToken:NO withCompletionHandler:^(id responseObject) 
         {
             [weakSelf.profiles removeAllObjects];
             //
             NSError *theError = nil;
             
             NSData* responseData = (NSData*)responseObject;
             NSDictionary* feedData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&theError];
             
             NSArray* bucketData = [feedData objectForKey:@"users"];
             
             @autoreleasepool {
                 
                 for(NSDictionary* userData in bucketData)
                 {
                     SPProfile* profile = [[SPProfile alloc] initWithData:userData];
                     [weakSelf.profiles addObject:profile];
                 }
             }

             onCompletion(weakSelf.profiles);
             
             //Inform application that the notifications have changed
             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROFILES_CHANGED object:nil];
         } 
         andErrorHandler:^(NSError* error)
         {
             if(onError)
             {
                 onError();
             }
         }];
    }
    else if([self myUserType] == USER_TYPE_REGISTERED)
    {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"No bucket set",NSLocalizedFailureReasonErrorKey,@"Please contact us and let us know about this issue. It's totally our fault.",NSLocalizedDescriptionKey, nil];
        NSError* incompleteProfileError = [NSError errorWithDomain:@"" code:0 userInfo:userInfo];
 
        [[SPErrorManager sharedInstance] logError:incompleteProfileError alertUser:YES];
        
        if(onError)
        {
            onError();
        }
    }
    else if([self myUserType] == USER_TYPE_PROFILE)
    {
        //TODO: Perform ad-hoc profile retrieval
        //Ad-hoc profile retrieval consists of an initial call to get a 'chunck' of profiles from your bucket
        // and scheduling periodic updates to check for new additions.
        // Current implementation : Retrieve all profiles that were last updated within the last X days (X = photo expiry timeout)
        NSString* parameter = [NSString stringWithFormat:@"%@/starttime/%d000/endtime/%d000",USER_ID_ME,intStartTime,intCurrentTime];
        
        NSLog(@"User retrieval parameter isn't finished in 'retrieveProfilesWithCompletionHandler:andErrorHandler:'");
        
        __unsafe_unretained SPProfileManager* weakSelf = self;
        [[SPRequestManager sharedInstance] getFromNamespace:REQUEST_NAMESPACE_BUCKETS withParameter:parameter requiringToken:YES withCompletionHandler:^(id responseObject) 
         {
             [weakSelf.profiles removeAllObjects];
             
             NSError *theError = nil;
             
             NSData* responseData = (NSData*)responseObject;
             NSDictionary* feedData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&theError];
             NSDictionary* bucketData = [feedData objectForKey:@"users"];

             @autoreleasepool {
             
                 for(NSDictionary* userData in bucketData)
                 {
                     SPProfile* profile = [[SPProfile alloc] initWithData:userData];
                     [weakSelf.profiles addObject:profile];
                 }
             }
             
             onCompletion(weakSelf.profiles);
             
             //Inform application that the notifications have changed
             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROFILES_CHANGED object:nil];
         } 
         andErrorHandler:^(NSError* error)
         {
             if(onError)
             {
                 onError();
                 
             }
         }];
    }
}
#pragma mark - Images
-(void)retrieveProfileThumbnail:(SPProfile*)profile withCompletionHandler:(void (^)(UIImage* thumbnail))onCompletion andErrorHandler:(void(^)())onError
{
    UIImage* thumbnail = [_thumbnails objectForKey:profile.identifier];
    
    if(thumbnail)
    {
        onCompletion(thumbnail);
    }
    else
    {
        [[SPRequestManager sharedInstance] getImageFromURL:[profile thumbnailURL] withCompletionHandler:^(UIImage* responseObject)
         {
            if(responseObject && profile.identifier)
            {
                [_thumbnails setObject:responseObject forKey:profile.identifier];
            }

             onCompletion(responseObject);
         }
         andErrorHandler:^(NSError* error)
         {
             if(onError)
             {
                onError();
             }
         }];
    }
}
-(void)retrieveProfileImage:(SPProfile*)profile withCompletionHandler:(void (^)(UIImage* image))onCompletion andErrorHandler:(void(^)())onError
{
    //Note: We do not cache full-size images
    [[SPRequestManager sharedInstance] getImageFromURL:[profile pictureURL] withCompletionHandler:^(UIImage* responseObject)
     {
         onCompletion(responseObject);
     }
     andErrorHandler:^(NSError* error)
     {
         if(onError)
         {
             onError();
         }
     }];
}
#pragma mark - Blocking Users
-(void)blockProfile:(SPProfile*)profile withCompletionHandler:(void (^)())onCompletion andErrorHandler:(void(^)())onError
{
        //Note: We do not cache full-size images
    NSString* parameter = [NSString stringWithFormat:@"me/blocks/%@",[profile identifier]];
    
    [[SPRequestManager sharedInstance] postToNamespace:REQUEST_NAMESPACE_USERS withParameter:parameter andPayload:nil requiringToken:YES withCompletionHandler:^(id responseObject) {
        
        //Creating a copy of the identifier to ensure it is not removed underneath us during onComplete()
        NSString* blockedProfileID = [[profile identifier] copy];
        
        onCompletion();
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BLOCKED_PROFILE object:blockedProfileID];
        
    } andErrorHandler:^(SPWebServiceError *error) {
        
        if(onError)
        {
            onError();
        }
    }];
}
#pragma mark - Likes
-(BOOL)checkIsLiked:(SPProfile*)profile
{
    for(SPProfile* likedProfile in _likes)
    {
        if ([[likedProfile identifier] isEqualToString:[profile identifier]]) 
        {
            //We've already 'Liked' this user
            return YES;
        }
    }
    
    return NO;
}
-(void)retrieveLikesWithCompletionHandler:(void (^)(NSArray* likes))onCompletion andErrorHandler:(void(^)())onError
{
    NSString* parameter = [NSString stringWithFormat:@"%@/likes",USER_ID_ME];
    
    __unsafe_unretained SPProfileManager* weakSelf = self;
    [[SPRequestManager sharedInstance] getFromNamespace:REQUEST_NAMESPACE_USERS withParameter:parameter requiringToken:YES withCompletionHandler:^(id responseObject) 
     {
         NSError* error = nil;
         
         NSData* responseData = (NSData*)responseObject;
         NSArray* likeData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
  
         if([likeData count] > 0)
         {
             [weakSelf retrieveProfilesWithIDs:likeData withCompletionHandler:^(NSArray *profiles_) 
              {
                  _likes = [[NSMutableArray alloc] initWithArray:profiles_];
                  
                  onCompletion(_likes);
                  
                  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LIKES_RECIEVED object:nil];
              } 
              andErrorHandler:^
              {
                  if(onError)
                  {
                      onError();
                  }
              }];
         }
         else 
         {
             //If there are no likes recorded, return an empty array
             onCompletion([NSArray array]);
         }
     }
     andErrorHandler:^(SPWebServiceError* error)
     {
         if(onError)
         {
             onError();
         }
     }];
}
-(void)retrieveLikedByWithCompletionHandler:(void (^)(NSArray* likes))onCompletion andErrorHandler:(void(^)())onError
{
    NSString* parameter = [NSString stringWithFormat:@"%@/likedby",USER_ID_ME];
    
    __unsafe_unretained SPProfileManager* weakSelf = self;
    [[SPRequestManager sharedInstance] getFromNamespace:REQUEST_NAMESPACE_USERS withParameter:parameter requiringToken:YES withCompletionHandler:^(id responseObject)
     {
         NSError* error = nil;
         NSData* responseData = (NSData*)responseObject;
         NSArray* likeData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
         
         if([likeData count] > 0)
         {
             [weakSelf retrieveProfilesWithIDs:likeData withCompletionHandler:^(NSArray *profiles_) 
              {
                  _likedBy = profiles_;
                  
                  onCompletion(_likedBy);
                  
                  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LIKED_BY_RECIEVED object:nil];
              } 
              andErrorHandler:^
              {
                  if(onError)
                  {
                      onError();
                  }
              }];
         }
         else 
         {
             //If there are no liked by recorded, return an empty array
             onCompletion([NSArray array]);
         }
         
     } 
     andErrorHandler:^(SPWebServiceError* error)
     {
         if(onError)
         {
             onError();
         }
     }];
}

-(void)addProfile:(SPProfile*)profile toToLikesWithCompletionHandler:(void(^)())onCompletion andErrorHandler:(void(^)())onError
{    
    if([self checkIsLiked:profile])
    {
        //We've already 'Liked' this user
        if(onError)
        {
            onError();
            
        }
        return;
    }
    
    NSString* parameter = [NSString stringWithFormat:@"%@/likes/%@",USER_ID_ME,[profile identifier]];
    [[SPRequestManager sharedInstance] postToNamespace:REQUEST_NAMESPACE_USERS withParameter:parameter andPayload:nil requiringToken:YES withCompletionHandler:^(id responseObject)
     {
        #if defined (BETA)
        [TestFlight passCheckpoint:@"Liked a User"];
        #endif
        
        [_likes addObject:profile];
         
        onCompletion();
         
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LIKE_ADDED object:profile];
     } 
     andErrorHandler:^(SPWebServiceError* error)
     {
         if(onError)
         {
             onError();
             
         }
     }];
}
-(void)removeProfile:(SPProfile*)profile fromLikesWithCompletionHandler:(void(^)())onCompletion andErrorHandler:(void(^)())onError
{
    SPProfile* profileToRemove = nil;
    //Find profile in LIKES array
    for(SPProfile* likedProfile in _likes)
    {
        if ([[likedProfile identifier] isEqualToString:[profile identifier]]) 
        {
            //Store pointer to profile which needs to be removed
            profileToRemove = likedProfile;
            break;
        }
    }
    
    //If profile is found in LIKES array
    if(profileToRemove)
    {
        NSString* parameter = [NSString stringWithFormat:@"%@/likes/%@",USER_ID_ME,[profile identifier]];
        [[SPRequestManager sharedInstance] deleteFromNamespace:REQUEST_NAMESPACE_USERS withParameter:parameter requiringToken:YES withCompletionHandler:^(id responseObject) 
         {
            #if defined (BETA)
            [TestFlight passCheckpoint:@"Unliked a User"];
            #endif

            [_likes removeObject:profileToRemove];
             
            onCompletion();
             
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LIKE_REMOVED object:profileToRemove];
         } 
         andErrorHandler:^(SPWebServiceError* error)
         {
             if(onError)
             {
                 onError();
                 
             }
         }];
    }
}
#pragma mark - Private methods
-(NSMutableDictionary*)generateProfileDataWithIcebreaker:(NSString*)icebreaker_ andGender:(GENDER)gender_ andPreference:(GENDER)preference_
{
    NSMutableDictionary* profileData = [NSMutableDictionary dictionary];
                                        
    if(icebreaker_)
    {
        [profileData setObject:icebreaker_ forKey:@"icebreaker"];
    }
    if(gender_)
    {
        [profileData setObject:GENDER_NAMES[gender_] forKey:@"gender"];
    }
    if(preference_)
    {
        [profileData setObject:GENDER_NAMES[preference_] forKey:@"lookingForGender"];
    }

    return profileData;
}
//Wipes app of current profile information (excluding stored messages)
-(void)clearProfile
{
    [[SPRequestManager sharedInstance] removeUserToken];
    //Cancel any queued local notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //Clear properties
    self.profiles = [NSMutableArray array];
    self.bucket = nil;
    self.icebreaker = nil;
    self.email = nil;
    self.expiry = nil;
    self.gender = GENDER_UNSPECIFIED;
    self.preference = GENDER_UNSPECIFIED;
    self.userID = nil;
    self.userName = nil;
    self.image = nil;
    self.lastImage = nil;

    //Reset variables
    _likes = [NSMutableArray new];
    _hasProfileImage = NO;
    RETRIEVED_GENDER_FROM_DEFAULTS = NO;
    RETRIEVED_PREFERENCE_FROM_DEFAULTS = NO;

    //Clear out various NSUserDefault cached values
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UNIX_TIME_OF_LAST_MESSAGE_RETRIEVED_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_KEY_EXPIRY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_KEY_USER_TYPE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_KEY_USER_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_KEY_USER_NAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_KEY_USER_BUCKET];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_KEY_USER_ICEBREAKER];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_KEY_USER_EMAIL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_KEY_USER_GENDER];  
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_KEY_USER_PREFERENCE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_KEY_DEVICE_PUSH_TOKEN_SYNCED];
    //Cannot remove USER_DEFAULT_KEY_USER_IMAGE_ORIENTATION as it's stored as an integer
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//Wipes app of all profile information (including stored messages of all accounts)
-(void)wipeProfiles
{
    [self clearProfile];
    //Clear Database of all cached messages & profiles
    [[SPMessageManager sharedInstance] clearDatabase];
}
@end
