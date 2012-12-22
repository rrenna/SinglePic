//
//  SPLocationManager.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPLocations.h"
#import <CoreLocation/CoreLocation.h>

@interface SPLocationManager : NSObject <CLLocationManagerDelegate>
{
@private
    CLLocationManager* locationManager;
}

+ (SPLocationManager *)sharedInstance;

-(BOOL)locationAvaliable;
-(void)getLocation;//Attempts to get a user location (if possible)
-(void)waitOnLocationWithCompletion:(void(^)(CLLocation*))onComplete andError:(void(^)(void))onError;
-(CLLocation*)location;
-(CLAuthorizationStatus)locationAuthorizationStatus;
-(void)requestLocationPermission;
@end
