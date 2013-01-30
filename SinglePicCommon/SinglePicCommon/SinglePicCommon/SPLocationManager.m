//
//  SPLocationManager.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPLocationManager.h"

@interface SPLocationManager()
{
    CLLocationManager* locationManager;
}
@property (copy) void(^waitOnLocationCompleteBlock)(CLLocation*);
@property (copy) void(^waitOnLocationErrorBlock)();

-(void)createLocationManager;
@end

@implementation SPLocationManager

+ (SPLocationManager *)sharedInstance
{
    static dispatch_once_t once;
    static SPLocationManager *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[SPLocationManager alloc] init]; });
    return sharedInstance;
}

#pragma mark
-(id)init
{
    self = [super init];
    if(self)
    { }
    return self;
}
-(BOOL)locationAvaliable
{
    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    BOOL authorizationNotDenied = ( [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied );
    return locationServicesEnabled && authorizationNotDenied;
}
-(void)getLocation
{
    if(!locationManager)
    {
        [self createLocationManager];
    }
    
    [locationManager startUpdatingLocation];
}
-(void)waitOnLocationWithCompletion:(void(^)(CLLocation*))onComplete andError:(void(^)(void))onError
{
    if(!locationManager)
    {
        [self createLocationManager];
    }
    
    CLLocation* location = [self location];
    if(location)
    {
        onComplete(location);
    }
    else
    {
        self.waitOnLocationCompleteBlock = onComplete;
        self.waitOnLocationErrorBlock = onError;
        [locationManager startUpdatingLocation];
    }
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
        [self createLocationManager];
    }
       
    [locationManager startUpdatingLocation];
}
#pragma mark - Private methods
-(void)createLocationManager
{
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers]; //3 km accuracy
    locationManager.delegate = self;
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
    if(self.waitOnLocationCompleteBlock)
    {
        self.waitOnLocationCompleteBlock(newLocation);
        self.waitOnLocationCompleteBlock = nil;
        self.waitOnLocationErrorBlock = nil;
    }
    
    //We only need an estimated location, we can now turn the GPS off
    [manager stopUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if(self.waitOnLocationErrorBlock)
    {
        self.waitOnLocationErrorBlock();
        self.waitOnLocationCompleteBlock = nil;
        self.waitOnLocationErrorBlock = nil;
    }
}
@end
