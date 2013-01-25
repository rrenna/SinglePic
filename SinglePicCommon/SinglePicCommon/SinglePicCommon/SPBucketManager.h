//
//  SPBucketManager.h
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-20.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPBuckets.h"

@interface SPBucketManager : NSObject
@property (retain) NSMutableArray* buckets;

+(SPBucketManager *)sharedInstance;

-(void)retrieveBucketsWithCompletionHandler:(void (^)(NSArray* buckets))onCompletion andErrorHandler:(void(^)())onError;
@end
