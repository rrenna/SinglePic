//
//  PMAProfile.h
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPProfiles.h"

@interface SPProfile : NSObject
-(id)initWithData:(NSDictionary*)data;
-(BOOL)isValid;
-(NSString*)identifier;
-(NSString*)username;
-(NSString*)bucketIdentifier;
-(NSString*)icebreaker;
-(GENDER)gender;
-(GENDER)preference;
-(NSDate*)timestamp;
-(NSURL*)thumbnailURL;
-(NSURL*)pictureURL;
@end
