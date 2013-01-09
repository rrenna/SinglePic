//
//  LocationManagerTest.m
//  SinglePic
//
//  Created by Ryan Renna on 2013-01-09.
//
//

#import "LocationManagerTest.h"

@implementation LocationManagerTest
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
    STAssertNotNil([SPLocationManager sharedInstance], @"SPLocationManager cannot be created");
}
@end
