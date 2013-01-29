//
//  SPBucketManager.m
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-20.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPBucketManager.h"
#import "SPBucket.h"

@interface SPBucketManager()
@property (strong)NSMutableDictionary* bucketNames;
@end

@implementation SPBucketManager
@synthesize buckets;

+ (SPBucketManager *)sharedInstance
{
    static dispatch_once_t once;
    static SPBucketManager *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[SPBucketManager alloc] init]; });
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        self.bucketNames = [NSMutableDictionary new];
    }
    return self;
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
             [self.bucketNames setObject:bucket.name forKey:bucket.identifier];
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
-(void)retrieveBucketNameForIdentifier:(NSString*)identifier withCompletionHandler:(void (^)(NSString* bucketName))onCompletion andErrorHandler:(void(^)())onError
{
    NSString* _bucketName = [self.bucketNames objectForKey:identifier];
    
    if(_bucketName) //The name of this bucket has been cached
    {
        onCompletion(_bucketName);
    }
    else //The name of this bucket has not been cached (brand new bucket, or have never retrieved all buckets)
    {
        __unsafe_unretained SPBucketManager* weakSelf = self;
        [self retrieveBucketsWithCompletionHandler:^(NSArray *buckets)
        {
            onCompletion([weakSelf.bucketNames objectForKey:identifier]);
        }
        andErrorHandler:onError];
    }
}
@end
