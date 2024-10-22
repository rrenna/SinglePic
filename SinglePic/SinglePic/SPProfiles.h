//
//  SPProfiles.h
//  SinglePic
//
//  Created by Ryan Renna on 12-02-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//Used to place information about SinglePic profiles that other components may need to reference

//Static Notifications
//--Behaviour Notifications
static __attribute__((unused)) NSString* NOTIFICATION_LIKED_BY_RECIEVED = @"NOTIFICATION_LIKED_BY_RECIEVED";
static __attribute__((unused)) NSString* NOTIFICATION_LIKES_RECIEVED = @"NOTIFICATION_LIKES_RECIEVED";
static __attribute__((unused)) NSString* NOTIFICATION_LIKE_ADDED = @"NOTIFICATION_LIKE_ADDED";
static __attribute__((unused)) NSString* NOTIFICATION_LIKE_REMOVED = @"NOTIFICATION_LIKE_REMOVED";
static __attribute__((unused)) NSString* NOTIFICATION_BLOCKED_PROFILE = @"NOTIFICATION_BLOCKED_PROFILE";
//--Profile Change Notifications
static __attribute__((unused)) NSString* NOTIFICATION_MY_USER_ID_CHANGED = @"NOTIFICATION_MY_USER_ID_CHANGED";
static __attribute__((unused)) NSString* NOTIFICATION_MY_USER_NAME_CHANGED = @"NOTIFICATION_MY_USER_NAME_CHANGED";
static __attribute__((unused)) NSString* NOTIFICATION_MY_USER_TYPE_CHANGED = @"NOTIFICATION_MY_USER_TYPE_CHANGED";
static __attribute__((unused)) NSString* NOTIFICATION_MY_BUCKET_CHANGED = @"NOTIFICATION_MY_BUCKET_CHANGED";
static __attribute__((unused)) NSString* NOTIFICATION_MY_IMAGE_CHANGED = @"NOTIFICATION_MY_IMAGE_CHANGED";
static __attribute__((unused)) NSString* NOTIFICATION_MY_EXPIRY_CHANGED = @"NOTIFICATION_MY_EXPIRY_CHANGED";
static __attribute__((unused)) NSString* NOTIFICATION_MY_ICEBREAKER_CHANGED = @"NOTIFICATION_MY_ICEBREAKER_CHANGED";
static __attribute__((unused)) NSString* NOTIFICATION_MY_EMAIL_CHANGED = @"NOTIFICATION_MY_EMAIL_CHANGED";
static __attribute__((unused)) NSString* NOTIFICATION_MY_GENDER_CHANGED = @"NOTIFICATION_MY_GENDER_CHANGED";
static __attribute__((unused)) NSString* NOTIFICATION_MY_PREFERENCE_CHANGED = @"NOTIFICATION_MY_PREFERENCE_CHANGED";
static __attribute__((unused)) NSString* NOTIFICATION_MY_ANNONYMOUS_BUCKET_CHANGED = @"NOTIFICATION_MY_ANNONYMOUS_BUCKET_CHANGED";
static __attribute__((unused)) NSString* NOTIFICATION_MY_ANNONYMOUS_GENDER_CHANGED = @"NOTIFICATION_MY_ANNONYMOUS_GENDER_CHANGED";
static __attribute__((unused)) NSString* NOTIFICATION_MY_ANNONYMOUS_PREFERENCE_CHANGED = @"NOTIFICATION_MY_ANNONYMOUS_PREFERENCE_CHANGED";
static __attribute__((unused)) NSString* NOTIFICATION_PROFILES_CHANGED = @"NOTIFICATION_PROFILES_CHANGED";

//Static Local Notifications
static const __attribute__((unused)) NSString* NOTIFICATION_BODY_IMAGE_EXPIRY  = @"Your Pic has expired. Upload a new one now.";

typedef enum
{
    GENDER_UNSPECIFIED = 0,
    GENDER_MALE = 1,
    GENDER_FEMALE = 2
} GENDER;

typedef enum
{
    USER_TYPE_ANNONYMOUS = 0,
    USER_TYPE_REGISTERED = 1,
    USER_TYPE_PROFILE = 2
} USER_TYPE;
