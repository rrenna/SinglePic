//
//  TimeHelper.h
//  SinglePic
//
//  Created by Ryan Renna on 12-03-14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeHelper : NSObject

//Will provide a human readable age of a date. Used for displaying strings like "2 days, 3 hours old", or "2 weeks, 1 day ago". Should be used for dates in the past
+ (NSString*) ageOfDate:(NSDate*)date;
+ (NSString*) countdownUntilDate:(NSDate*)date;
//Returns a fraction of progress to the given time interval after the provided date (capped at 1.0). ie. If we are 1 day after date, and the interval is 2 days, 0.5 will be returned
+ (float) progressOfDate:(NSDate*)date toTimeInterval:(NSTimeInterval)interval;
//Converts a SinglePic server time to an NSDate
+ (NSDate*) dateWithServerTime:(NSString*)serverTime;
+ (NSString*) serverTimeWithDate:(NSDate*)date;
@end
