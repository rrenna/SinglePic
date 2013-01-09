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
@end
