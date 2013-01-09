//
//  MessageManagerTest.m
//  SinglePic
//
//  Created by Ryan Renna on 2013-01-09.
//
//

#import "MessageManagerTest.h"

@implementation MessageManagerTest
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
    STAssertNotNil([SPMessageManager sharedInstance], @"SPMessageManager cannot be created");
}
@end
