//
//  SPABucketAnnotation.m
//  SinglePicAdmin
//
//  Created by Ryan Renna on 2013-02-01.
//  Copyright (c) 2013 Ryan Renna. All rights reserved.
//

#import "SPABucketAnnotation.h"
#import <SinglePicCommon/SPBucket.h>

@interface SPABucketAnnotation()
@property (strong) SPBucket* bucket;
@end

@implementation SPABucketAnnotation
-(id)initWithBucket:(SPBucket*)bucket
{
    self = [super init];
    if(self)
    {
        _coordinate = bucket.coordinate;
        self.bucket = bucket;
    }
    return self;
}
- (NSString *)title
{
    return [self.bucket title];
}
- (NSString *)subtitle
{
    return [self.bucket subtitle];
}
@end
