//
//  TimeHelper.m
//  SinglePic
//
//  Created by Ryan Renna on 12-03-14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimeHelper.h"

@interface TimeHelper()
+(NSString*)_descriptionForTimeInterval:(NSTimeInterval)interval;
@end

@implementation TimeHelper

+ (NSString *) ageOfDate:(NSDate*)date
{
    NSTimeInterval interval = -1 * [date timeIntervalSinceNow];
    return [self _descriptionForTimeInterval:interval];
}
+ (NSString*) countdownUntilDate:(NSString*)date
{
    NSTimeInterval interval = [date timeIntervalSinceNow];
    return [self _descriptionForTimeInterval:interval];
}
+ (float) progressOfDate:(NSDate*)date toTimeInterval:(NSTimeInterval)interval
{
    float progress = 0.0;
    
    NSTimeInterval expiryInterval = [date timeIntervalSinceNow];
    progress = (float) (expiryInterval/interval);
    
    return MIN( progress , 1.0f);
}
+ (NSDate*) dateWithServerTime:(NSString*)serverTime
{
    if([serverTime length] > 3)
    {
        serverTime = [serverTime substringToIndex:[serverTime length] - 3];
    }
    
    NSTimeInterval serverTimeInterval = [serverTime doubleValue];
    return [NSDate dateWithTimeIntervalSince1970:serverTimeInterval];
}
+ (NSString*) serverTimeWithDate:(NSDate*)date
{
        //TODO:
}
#pragma mark - Private methods
+(NSString*)_descriptionForTimeInterval:(NSTimeInterval)interval
{
    NSString* ageString = @"";
    int numberOfDays, numberOfHours, numberOfMinutes;
    
    numberOfDays = interval / SECONDS_PER_DAY;
    double hourSeconds = interval - (numberOfDays * SECONDS_PER_DAY);
    numberOfHours = hourSeconds / SECONDS_PER_HOUR;
    double minuteSeconds = hourSeconds - (numberOfHours * SECONDS_PER_HOUR);
    numberOfMinutes = minuteSeconds / SECONDS_PER_MINUTE;
    
    NSString* dayPlurality = (numberOfDays < 1) ? @"day" : @"days";
    NSString* hourPlurality = (numberOfHours < 1) ? @"hour" : @"hours";
    NSString* minutePlurality = (numberOfMinutes > 1 || numberOfMinutes == 0) ? @"minutes" : @"minute";
    
    //If there are any days left, show days and hours
    if(numberOfDays > 0)
    {
        ageString = [NSString stringWithFormat:@"%d %@, %d %@",numberOfDays,dayPlurality,numberOfHours,hourPlurality];
    }
    //If no days, show hours and minutes
    else if(numberOfHours > 0)
    {
        ageString = [NSString stringWithFormat:@"%d %@, %d %@",numberOfHours,hourPlurality,numberOfMinutes,minutePlurality];
    }
    //If no hours, show minutes
    else
    {
        ageString = [NSString stringWithFormat:@"%d %@",numberOfMinutes,minutePlurality];
    }
    
    return ageString;
}
@end
