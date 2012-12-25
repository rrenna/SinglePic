//
//  PMAProfile.m
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPProfile.h"

#define PROFILE_IDENTIFIER_KEY @"id"
#define PROFILE_USERNAME_KEY @"userName"
#define PROFILE_ERROR_KEY @"error"

@interface SPProfile()
{
    NSDictionary* _data;
}
@property (retain) UIImage* _thumbnail;
-(BOOL)_checkIsValid:(NSDictionary*) data;
@end

@implementation SPProfile
@synthesize _thumbnail;

-(id)initWithData:(NSDictionary*)data
{
    self = [super init];
    if(self)
    {
        _data = data;
    }
    return self;
}

-(BOOL)isValid
{
    return [self _checkIsValid:_data];
}
-(NSString*)identifier
{
    NSString* idObject = [_data objectForKey:PROFILE_IDENTIFIER_KEY];
    return idObject;
}
-(NSString*)username
{
    NSString* usernameObject = [_data objectForKey:PROFILE_USERNAME_KEY];
    if([usernameObject isMemberOfClass:[NSNull class]])
    {
        //Prevents a crash when no username is set
        usernameObject = @"";
    }
    return usernameObject;
}
-(GENDER)gender
{
    //TODO: 
    return GENDER_UNSPECIFIED;
}
-(NSDate*)timestamp
{
    NSString* timestampString = [_data objectForKey:@"lastUpdated"];
    return [TimeHelper dateWithServerTime:timestampString];
}
-(NSURL*)thumbnailURL
{
    NSString* thumbnailURLString = [_data objectForKey:@"thumbURL"];
    return [NSURL URLWithString:thumbnailURLString];
}
-(NSURL*)pictureURL
{
    NSString* pictureURLString = [_data objectForKey:@"imageURL"];
    return [NSURL URLWithString:pictureURLString];
}
-(NSString*)icebreaker
{
    NSString* icebreaker = [_data objectForKey:@"icebreaker"];
    if([icebreaker isMemberOfClass:[NSNull class]])
    {
        //Prevents a crash when no icebreaker is set
        icebreaker = @"";
    }
    
    return icebreaker;
}
#pragma mark - Private methods
-(BOOL)_checkIsValid:(NSDictionary*) data
{
    //If no data is provided this is an invalid profile
    if(!data)
    {
        return NO;
    }
    //Invalid (most likely deleted) profiles may simply be stored with a single "error" key
    id error = [data objectForKey:PROFILE_ERROR_KEY];
    if(error)
    {
        return NO;
    }
    //Invalid (most likely deleted) profiles will be parsed as having a NSNull "id" value
    id identifier = [data objectForKey:PROFILE_IDENTIFIER_KEY];
    if([identifier isMemberOfClass:[NSNull class]])
    {
        return NO; 
    }
    
    return YES;
}
@end
