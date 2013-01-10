//
//  BucketManagerTest.m
//  SinglePic
//
//  Created by Ryan Renna on 2013-01-09.
//
//

#import "BucketManagerTest.h"

@implementation BucketManagerTest
- (void)setUp
{
    authenticationRequired = YES;
    [super setUp];
    // Set-up code here.
}
- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

-(void)testRequestManagerSingletonExists
{
    STAssertNotNil([SPBucketManager sharedInstance], @"SPBucketManager cannot be created");
}
-(void)testRetrieveProfiles
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[SPBucketManager sharedInstance] retrieveBucketsWithCompletionHandler:^(NSArray *buckets) {
        
        STAssertTrue([buckets count] > 0,@"No buckets were returned");
        // Signal that block has completed
        dispatch_semaphore_signal(semaphore);
        
    } andErrorHandler:^{
        
        STFail(@"Couldn't successfully retrieve buckets");
        // Signal that block has completed
        dispatch_semaphore_signal(semaphore);
    }];
    
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}
@end
