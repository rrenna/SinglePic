//
//  ProfileManagerTest.m
//  SinglePic
//
//  Created by Ryan Renna on 2013-01-09.
//
//

#import "ProfileManagerTest.h"

@implementation ProfileManagerTest

- (void)setUp
{
    authenticationRequired = YES;
    [super setUp];
        // Set-up code here.
}

-(void)testRetrieveProfiles
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [[SPProfileManager sharedInstance] retrieveProfilesWithCompletionHandler:^(NSArray *profiles) {
        
        // Signal that block has completed
        dispatch_semaphore_signal(semaphore);
        
    } andErrorHandler:^
    {
        STFail(@"Couldn't successfully retrieve profiles");
            // Signal that block has completed
        dispatch_semaphore_signal(semaphore);
        
    }];
    
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}
-(void)testProfileManagerSingletonExists
{
    STAssertNotNil([SPProfileManager sharedInstance], @"SPProfileManager cannot be created");
}
@end
