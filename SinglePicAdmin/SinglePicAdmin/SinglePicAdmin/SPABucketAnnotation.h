//
//  SPABucketAnnotation.h
//  SinglePicAdmin
//
//  Created by Ryan Renna on 2013-02-01.
//  Copyright (c) 2013 Ryan Renna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapKit.h"

@class SPBucket;

@interface SPABucketAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id)initWithBucket:(SPBucket*)bucket;
- (NSString *)title;
- (NSString *)subtitle;
@end
