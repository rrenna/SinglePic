//
//  ManagerTest.m
//  SinglePic
//
//  Created by Ryan Renna on 2013-01-09.
//
//

#import "ManagerTest.h"

@implementation ManagerTest

-(id)init
{
    self = [super init];
    if(self)
    {
        authenticationRequired = NO;
    }
    return self;
}

-(void)setUp
{
    [super setUp];
    // Set-up code here.
    
    //Sets up network connectivity
    [[SPRequestManager sharedInstance] EnableRealtimeReachabilityMonitoring];
    
    if(authenticationRequired)
    {
        //Uses a semaphore to block this method from leaving until a successful login (attempt) has been completed
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [[SPProfileManager sharedInstance] loginWithEmail:@"test@appple.com" andPassword:@"applepassword" andCompletionHandler:^(id responseObject) {
            
            // Signal that block has completed
            dispatch_semaphore_signal(semaphore);
            
        } andErrorHandler:^{
            
            // Signal that block has completed
            dispatch_semaphore_signal(semaphore);
            
        }];
        
        // Run loop
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
}

- (void)tearDown
{
    // Tear-down code here.
    if(authenticationRequired)
    {
        [[SPProfileManager sharedInstance] logout];
    }
    
    [super tearDown];
}
@end
