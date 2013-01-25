//
//  SinglePicCommon.h
//  SinglePicCommon
//
//  Created by Ryan Renna on 2013-01-22.
//  Copyright (c) 2013 Ryan Renna. All rights reserved.
//

#import <Foundation/Foundation.h>

//General
#define SECONDS_PER_DAY  (60 * 60 * 24)
#define SECONDS_PER_HOUR (60 * 60)
#define SECONDS_PER_MINUTE 60

//Beta
#define BETA_EXPIRY_YEAR 2013
#define BETA_EXPIRY_MONTH 01
#define BETA_EXPIRY_DAY 30

//Servers
#define PRODUCTION_ADDRESS @"https://singlepicdating.herokuapp.com/"
#define TESTING_ADDRESS @"https://singlepicdating-staging.herokuapp.com/"

//Information
#define CONTACT_SUPPORT_EMAIL @"support@singlepicdating.com"
#define MINIMUM_USERNAME_LENGTH 6
#define MINIMUM_PASSWORD_LENGTH 6
#define MINIMUM_EMAIL_LENGTH 4

@interface SinglePicCommon : NSObject
@end
