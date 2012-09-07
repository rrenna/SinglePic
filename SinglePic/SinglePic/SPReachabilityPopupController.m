//
//  SPReachabilityView.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPReachabilityPopupController.h"

@interface SPReachabilityPopupController()
-(BOOL)reachable;
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
        alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Couldn't connect to SinglePic" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Try Again", nil];
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
#pragma mark - Private methods
-(BOOL)reachable
{
     Reachability* reachability = [Reachability reachabilityWithHostName:[[SPSettingsManager sharedInstance] serverAddress]];
    return [reachability isReachable];
}
#pragma mark - Self Delegate methods
#define DELAY_BETWEEN_REACHABILITY_RETRIES 0.5
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([self reachable])
    {
        //If reachable, alert the delegate
        [delegate reachabilityConfirmedForHostName:[[SPSettingsManager sharedInstance] serverAddress]];
    }
    else
    {
        [self performSelector:@selector(show) withObject:nil afterDelay:DELAY_BETWEEN_REACHABILITY_RETRIES];
    }
}
@end
