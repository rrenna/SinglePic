//
//  SPBucketManager.h
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-20.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPBuckets.h"

@interface SPBucketManager : NSObject

+(SPBucketManager *)sharedInstance;

-(void)retrieveBucketsWithCompletionHandler:(void (^)(NSArray* buckets))onCompletion andErrorHandler:(void(^)())onError;
//Used to identify the name of a bucket based on a bucket identifier (will retrieve the entire list of buckets if missing entries)
-(void)retrieveBucketNameForIdentifier:(NSString*)identifier withCompletionHandler:(void (^)(NSString* bucketName))onCompletion andErrorHandler:(void(^)())onError;
@end
