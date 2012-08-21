//
//  PMAGlobal.h
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

//Media
static NSString* DEFAULT_PORTRAIT_IMAGE = @"noImage";

//Profiles
static NSString* GENDER_NAMES[3] = {@"undefined",@"male",@"female"};
#define DEFAULT_GENDER GENDER_FEMALE
#define DEFAULT_PREFERENCE GENDER_MALE
#define ICEBREAKER_LENGTH_LIMIT 120
#define MINIMUM_USERNAME_LENGTH 5
#define MINIMUM_PASSWORD_LENGTH 4
#define MINIMUM_EMAIL_LENGTH 4


//General
#define SECONDS_PER_DAY  (60 * 60 * 24)
#define SECONDS_PER_HOUR (60 * 60)
#define SECONDS_PER_MINUTE 60

//Beta Testing
//Beta expiry
#define BETA_EXPIRY_YEAR 2012
#define BETA_EXPIRY_MONTH 10
#define BETA_EXPIRY_DAY 28

//Help
typedef enum
{
    HELP_OVERLAY_LOGIN_OR_REGISTER,
    HELP_OVERLAY_BROWSE,
    HELP_OVERLAY_IMAGE_EXPIRY
    
} HELP_OVERLAY_TYPE;

//Information
#define CONTACT_SUPPORT_EMAIL @"support@singlepicdating.com"