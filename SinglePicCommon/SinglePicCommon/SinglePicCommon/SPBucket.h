//
//  PMABucket.h
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface SPBucket : NSObject <NSCoding>
{
@private
    NSDictionary* _data;
}
-(id)initWithData:(NSDictionary*)data;

-(CLLocationCoordinate2D)coordinate;
-(NSString*)name;
-(NSString*)title;
-(NSString*)subtitle;
-(NSString*)identifier;
@end
