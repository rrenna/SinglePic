//
//  SPLocationManager.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPSingleton.h"
#import "SPLocations.h"
#import <CoreLocation/CoreLocation.h>

@interface SPLocationManager : SPSingleton <CLLocationManagerDelegate>
{
@private
    CLLocationManager* locationManager;
}
-(BOOL)locationAvaliable;
-(void)getLocation;//Attempts to get a user location (if possible)
-(void)waitOnLocationWithCompletion:(void(^)(CLLocation*))onComplete andError:(void(^)(void))onError;
-(CLLocation*)location;
-(CLAuthorizationStatus)locationAuthorizationStatus;
-(void)requestLocationPermission;
@end
