//
//  SPReachabilityView.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPReachabilityPopupController.h"

@interface SPReachabilityPopupController()
{
    UIAlertView* alertView;
    BOOL initialReachabilityRetrieved;
    BOOL reachable;
}
-(BOOL)reachable;
-(void)delayedReshow;
@property (retain) id<SPReachabilityPopupDelegate> delegate;
@end

@implementation SPReachabilityPopupController
@synthesize delegate;

-(SPReachabilityPopupController*)initWithDelegate:(id<SPReachabilityPopupDelegate>)delegate_
{
    self = [super init];
    
    if(self)
    {
        self.delegate = delegate_;
        reachable = NO;
        initialReachabilityRetrieved = NO;
        
        alertView = [[UIAlertView alloc] initWithTitle:@"Connectivity Issue" message:@"Couldn't connect to SinglePic. Please ensure you have an active internet connection." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Try Again", nil];
        
        [[SPRequestManager sharedInstance] checkInitialReachabilityWithCompletionHandler:^(AFNetworkReachabilityStatus status)
        {
            initialReachabilityRetrieved = YES;
            
            if(status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN)
            {
                reachable = YES;
            }
            
        }];
    }
    return self;
}
-(void)dealloc
{
    [delegate release];
    [alertView release];
    [super dealloc];
}
#pragma mark - Overriden methods
-(void)show
{
    if(!initialReachabilityRetrieved)
    {
        [self delayedReshow];
    }
    else
    {
        if([self reachable])
        {
                //If reachable, alert the delegate
            [self.delegate reachabilityConfirmedForHostName:[[SPSettingsManager sharedInstance] serverAddress]];
        }
        else
        {
            [alertView show];
        }
    }
}
#pragma mark - Private methods
-(BOOL)reachable
{
    return reachable;
}
#pragma mark - Self Delegate methods
#define DELAY_BETWEEN_REACHABILITY_RETRIES 0.5
-(void)delayedReshow
{
    [self performSelector:@selector(show) withObject:nil afterDelay:DELAY_BETWEEN_REACHABILITY_RETRIES];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([self reachable])
    {
        //If reachable, alert the delegate
        [delegate reachabilityConfirmedForHostName:[[SPSettingsManager sharedInstance] serverAddress]];
    }
    else
    {
        [self delayedReshow];
    }
}
@end
