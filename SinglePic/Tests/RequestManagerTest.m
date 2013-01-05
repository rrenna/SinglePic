//
//  RequestManagerTest.m
//  SinglePic
//
//  Created by Ryan Renna on 2013-01-05.
//
//

#import "RequestManagerTest.h"
#import "SPRequestManager.h"

@implementation RequestManagerTest

- (void)setUp
{
    [super setUp];
    // Set-up code here.

    [[SPRequestManager sharedInstance] EnableRealtimeReachabilityMonitoring];
}
- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

-(void)testRequestManagerSingletonExists
{
    STAssertNotNil([SPRequestManager sharedInstance], @"SPRequestManager cannot be created");
}
-(void)testMakeRequestAppInfo
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    //Sends app version, and that this is the iOS app to the server to be validated
    NSString *version = @"1.0.4";
    NSDictionary* payload = [NSDictionary dictionaryWithObjectsAndKeys:version,@"version",@"iOS/iPhone",@"platform",nil];
    
    [[SPRequestManager sharedInstance] postToNamespace:REQUEST_NAMESPACE_APP withParameter:nil andPayload:payload requiringToken:NO withCompletionHandler:^(id responseObject) {
        
        
        // Signal that block has completed
        dispatch_semaphore_signal(semaphore);
        
        
    } andErrorHandler:^(SPWebServiceError *error) {
        
        STFail(@"Couldn't successfully retrieve App info from server");
        // Signal that block has completed
        dispatch_semaphore_signal(semaphore);
        
    }];
    
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}


@end
