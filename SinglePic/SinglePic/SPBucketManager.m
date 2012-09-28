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

-(void)retrieveBucketsWithCompletionHandler:(void (^)(NSArray* buckets))onCompletion andErrorHandler:(void(^)())onError
{
    __unsafe_unretained SPBucketManager* weakSelf = self;
    [[SPRequestManager sharedInstance] getFromNamespace:REQUEST_NAMESPACE_BUCKETS withParameter:nil requiringToken:NO withCompletionHandler:^(id responseObject)                            
     {
         NSError *theError = nil;
         NSArray* responseArray = [[CJSONDeserializer deserializer] deserialize:responseObject error:&theError];
         
         NSMutableArray* _buckets = [NSMutableArray arrayWithCapacity:[responseArray count]];
         for(NSDictionary* bucketData in responseArray)
         {
             SPBucket* bucket = [[SPBucket alloc] initWithData:bucketData];
             [_buckets addObject:bucket];
             [bucket release];
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
