//
//  PMAGlobal.h
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

//Media
static const NSString* DEFAULT_PORTRAIT_IMAGE = @"MyProfile-OBE-Pic";

//Profiles
static NSString* GENDER_NAMES[3] = {@"undefined",@"male",@"female"};
#define DEFAULT_GENDER GENDER_FEMALE
#define DEFAULT_PREFERENCE GENDER_MALE

#define ICEBREAKER_LENGTH_LIMIT 140
#define MINIMUM_USERNAME_LENGTH 6
#define MINIMUM_PASSWORD_LENGTH 6
#define MINIMUM_EMAIL_LENGTH 4

//General
#define SECONDS_PER_DAY  (60 * 60 * 24)
#define SECONDS_PER_HOUR (60 * 60)
#define SECONDS_PER_MINUTE 60

//Typography
#define FONT_NAME_PRIMARY @"Avenir LT 65 Medium"
#define FONT_NAME_SECONDARY @"Avenir LT 55 Roman" //Problem with Avenir LT 85 Heavy, mislabelled as 55 Roman

#define FONT_SIZE_MEDIUM 14
#define FONT_SIZE_SMALL 12
#define FONT_SIZE_EXTRA_SMALL 11

//Servers
#define PRODUCTION_ADDRESS @"https://singlepicdating.herokuapp.com/"
#define TESTING_ADDRESS @"https://singlepicdating-staging.herokuapp.com/"

//Beta expiry
#define BETA_EXPIRY_YEAR 2012
#define BETA_EXPIRY_MONTH 11
#define BETA_EXPIRY_DAY 1

//Help
typedef enum
{
    HELP_OVERLAY_LOGIN_OR_REGISTER,
    HELP_OVERLAY_BROWSE,
    HELP_OVERLAY_IMAGE_EXPIRY
    
} HELP_OVERLAY_TYPE;

//Information
#define CONTACT_SUPPORT_EMAIL @"support@singlepicdating.com"