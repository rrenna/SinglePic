//
//  RequestManagerTest.m
//  SinglePic
//
//  Created by Ryan Renna on 2013-01-05.
//
//

#import "RequestManagerTest.h"

@implementation RequestManagerTest

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
-(void)testMakeRequestBuckets
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[SPRequestManager sharedInstance] getFromNamespace:REQUEST_NAMESPACE_BUCKETS withParameter:nil requiringToken:NO withCompletionHandler:^(id responseObject) {
        
        // Signal that block has completed
        dispatch_semaphore_signal(semaphore);
        
        
    } andErrorHandler:^(SPWebServiceError *error) {
        
        STFail(@"Couldn't successfully retrieve Buckets from server");
            // Signal that block has completed
        dispatch_semaphore_signal(semaphore);
        
    }];
    
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}
-(void)testMakeRequestUsersAnonymous
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    double currenTimeInterval = [[NSDate date] timeIntervalSince1970];
    //Start Time (default = 7 days ago)
    int intStartTime = (int)(currenTimeInterval - (SECONDS_PER_DAY * PHOTO_EXPIRY_DAYS));
    //End Time (now)
    int intCurrentTime = (int)currenTimeInterval;

    NSString* parameter = [NSString stringWithFormat:@"undefined/gender/%@/lookingforgender/%@/starttime/%d000/endtime/%d000",GENDER_NAMES[GENDER_UNSPECIFIED],GENDER_NAMES[GENDER_UNSPECIFIED],intStartTime,intCurrentTime];
    
    [[SPRequestManager sharedInstance] getFromNamespace:REQUEST_NAMESPACE_BUCKETS withParameter:parameter requiringToken:NO withCompletionHandler:^(id responseObject) {
        
        // Signal that block has completed
        dispatch_semaphore_signal(semaphore);
        
        
    } andErrorHandler:^(SPWebServiceError *error) {
        
        STFail(@"Couldn't successfully retrieve Users from server");
        // Signal that block has completed
        dispatch_semaphore_signal(semaphore);
        
    }];
    
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}
-(void)testMakeRequestUsername
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[SPRequestManager sharedInstance] getFromNamespace:REQUEST_NAMESPACE_USERNAMES withParameter:@"rrenna" requiringToken:NO withCompletionHandler:^(id responseObject)
     {
         // Signal that block has completed
         dispatch_semaphore_signal(semaphore);
     }
     andErrorHandler:^(SPWebServiceError *error)
     {
         STFail(@"Couldn't successfully confirm username has been taken");
         // Signal that block has completed
         dispatch_semaphore_signal(semaphore);
     }];
    
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}
@end
