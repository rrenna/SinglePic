//
//  PMAProfile.m
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPProfile.h"

#define PROFILE_IDENTIFIER_KEY @"id"

@interface SPProfile() 
@property (retain) UIImage* _thumbnail;
-(BOOL)_checkIsValid;
@end

@implementation SPProfile
@synthesize _thumbnail;

-(id)initWithData:(NSDictionary*)data
{
    self = [super init];
    if(self)
    {
        invalid = [self _checkIsValid:data];
        _data = [data retain];
    }
    return self;
}
-(void)dealloc
{
    [_data release];
    [_thumbnail release];
    [super dealloc];
}
-(NSString*)identifier
{
    NSString* idObject = [_data objectForKey:PROFILE_IDENTIFIER_KEY];
    if([idObject isMemberOfClass:[NSNull class]])
    {
        //Prevents a crash when no icebreaker is set
        idObject = @"";
    }
    return idObject;
}
-(GENDER)gender
{
    //TODO: 
    return GENDER_UNSPECIFIED;
}
-(NSDate*)timestamp
{
    NSString* timestampString = [_data objectForKey:@"lastUpdated"];
    
    if([timestampString length] > 3)
    {
        timestampString = [timestampString substringToIndex:[timestampString length] - 3];
    }
    
    return [NSDate dateWithTimeIntervalSince1970:[timestampString doubleValue]];
}

-(void)retrieveThumbnailWithCompletionHandler:(void (^)(UIImage* thumbnail))onCompletion andErrorHandler:(void(^)())onError
{
    if(self._thumbnail)
    {
        onCompletion(_thumbnail);
    }
    else
    {
        [[SPRequestManager sharedInstance] getImageFromURL:[self thumbnailURL] withCompletionHandler:^(UIImage* responseObject) 
         {
             self._thumbnail = responseObject;
             onCompletion(responseObject);
         } 
         andErrorHandler:^(NSError* error)
         {
             onError();
         }];
    }
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
    if(!data) {return NO;}
    //Invalid (most likely deleted) profiles will be parsed as having a NSNull "id" value
    id identifier = [data objectForKey:PROFILE_IDENTIFIER_KEY];
    if([identifier isMemberOfClass:[NSNull class]])
    {
        return NO; 
    }
    
    return YES;
}
@end
