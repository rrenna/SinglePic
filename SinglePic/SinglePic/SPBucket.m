//
//  PMABucket.m
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPBucket.h"
#import <MapKit/MapKit.h>

@implementation SPBucket

-(id)initWithData:(NSDictionary*)data
{
    self = [super init];
    if(self)
    {
        _data = [data retain];
    }
    return self;
}
-(void)dealloc
{
    [_data release];
    [super dealloc];
}
#pragma mark
-(NSString*)name
{
    NSString* name = [_data objectForKey:@"name"];
    return name;
}
-(NSString*)identifier
{
    NSString* identifier = [[_data objectForKey:@"id"] description];
    return identifier;
}
#pragma mark - MKAnnotation methods
-(NSString*)title
{
    return [self name];
}
-(NSString*)subtitle
{
    return @"";
}
-(CLLocationCoordinate2D)coordinate
{
    NSString* latString = [_data objectForKey:@"lat"];
    NSString* lonString = [_data objectForKey:@"lon"];
    
    double lat = [latString doubleValue];
    double lon = [lonString doubleValue];
    
    return CLLocationCoordinate2DMake(lat, lon);
}
#pragma mark - NSCoder methods
- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties, other class variables, etc
    [encoder encodeObject:_data forKey:@"data"];
}
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        _data = [[decoder decodeObjectForKey:@"data"] retain];
    }
    return self;
}
@end
