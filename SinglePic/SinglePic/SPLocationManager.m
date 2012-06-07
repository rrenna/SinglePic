//
//  SPLocationManager.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPLocationManager.h"

@implementation SPLocationManager
#pragma mark
-(id)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}
-(void)dealloc
{
    [locationManager release];
    [super dealloc];
}
-(BOOL)locationAvaliable
{
    return [CLLocationManager locationServicesEnabled];
}
-(void)getLocation
{
    if(!locationManager)
    {
        locationManager = [[CLLocationManager alloc] init]; 
        [locationManager setDesiredAccuracy:2000]; //2 km accuracy
        locationManager.delegate = self;
    }
    
    [locationManager startUpdatingLocation];
}
-(CLLocation*)location
{
    if(!locationManager) return nil;
    
    return [locationManager location];
}
-(CLAuthorizationStatus)locationAuthorizationStatus
{
    return [CLLocationManager authorizationStatus];
}
-(void)requestLocationPermission
{
    if(!locationManager)
    {
        locationManager = [[CLLocationManager alloc] init]; 
        [locationManager setDesiredAccuracy:2000]; //1 km accuracy
        locationManager.delegate = self;
    }
       
    [locationManager startUpdatingLocation];
    [locationManager stopUpdatingHeading];
}
#pragma mark - LocationManager delegate methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //Do not notify objects of the 'not-determined' authorization status
    if(status != kCLAuthorizationStatusNotDetermined)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_PERMISSION_UPDATED object:nil];
    }
}
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    //We only need an estimated location, we can now turn the GPS off
    [manager stopUpdatingLocation];
}
@end
