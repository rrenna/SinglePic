//
//  SPBucketManager.m
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-20.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPBucketManager.h"
#import "SPBucket.h"

@implementation SPBucketManager
@synthesize buckets;

+ (SPBucketManager *)sharedInstance
{
    static dispatch_once_t once;
    static SPBucketManager *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[SPBucketManager alloc] init]; });
    return sharedInstance;
}

-(void)retrieveBucketsWithCompletionHandler:(void (^)(NSArray* buckets))onCompletion andErrorHandler:(void(^)())onError
{
    __unsafe_unretained SPBucketManager* weakSelf = self;
    [[SPRequestManager sharedInstance] getFromNamespace:REQUEST_NAMESPACE_BUCKETS withParameter:nil requiringToken:NO withCompletionHandler:^(id responseObject)                            
     {
         NSError *theError = nil;
         NSData* responseData = (NSData*)responseObject;
         NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&theError];

         NSMutableArray* _buckets = [NSMutableArray arrayWithCapacity:[responseArray count]];
         for(NSDictionary* bucketData in responseArray)
         {
             SPBucket* bucket = [[SPBucket alloc] initWithData:bucketData];
             [_buckets addObject:bucket];
         }
         weakSelf.buckets = _buckets;
         onCompletion(weakSelf.buckets);
     }
     andErrorHandler:^(NSError* error)
     {
         if(onError)
         {
             onError();
         }
     }];
}

@end
