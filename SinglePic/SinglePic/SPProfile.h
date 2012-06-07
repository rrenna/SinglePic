//
//  PMAProfile.h
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPProfile : NSObject
{
    @private
    NSDictionary* _data;
    BOOL invalid;
}
-(id)initWithData:(NSDictionary*)data;
-(NSString*)identifier;
-(NSString*)icebreaker;
-(NSDate*)timestamp;

-(void)retrieveThumbnailWithCompletionHandler:(void (^)(UIImage* thumbnail))onCompletion andErrorHandler:(void(^)())onError;

-(NSURL*)thumbnailURL;
-(NSURL*)pictureURL;
@end
