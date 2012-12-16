//
//  PMABucket.h
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol MKAnnotation;

@interface SPBucket : NSObject <MKAnnotation,NSCoding>
{
@private
    NSDictionary* _data;
}
-(id)initWithData:(NSDictionary*)data;
-(NSString*)name;
-(NSString*)identifier;
@end
