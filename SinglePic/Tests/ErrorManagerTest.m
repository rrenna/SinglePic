//
//  ErrorManagerTest.m
//  SinglePic
//
//  Created by Ryan Renna on 2013-01-09.
//
//

#import "ErrorManagerTest.h"

@implementation ErrorManagerTest
- (void)setUp
{
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
    STAssertNotNil([SPErrorManager sharedInstance], @"SPErrorManager cannot be created");
}
@end
