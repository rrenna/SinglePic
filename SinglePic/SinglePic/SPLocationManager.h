//
//  SPLocationManager.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPSingleton.h"
#import <CoreLocation/CoreLocation.h>

#define NOTIFICATION_LOCATION_PERMISSION_UPDATED @"NOTIFICATION_LOCATION_PERMISSION_UPDATED"

@interface SPLocationManager : SPSingleton <CLLocationManagerDelegate>
{
@private
    CLLocationManager* locationManager;
}
-(BOOL)locationAvaliable;
-(void)getLocation;//Attempts to get a user location (if possible)
-(CLLocation*)location;
-(CLAuthorizationStatus)locationAuthorizationStatus;
-(void)requestLocationPermission;
@end
