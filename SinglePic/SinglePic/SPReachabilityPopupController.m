//
//  SPReachabilityView.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPReachabilityPopupController.h"
#import <SinglePicCommon/SPRequestManager.h>

@interface SPReachabilityPopupController()
{
    UIAlertView* alertView;
}
@end

@implementation SPReachabilityPopupController

-(id)init
{
    self = [super init];
    
    if(self)
    {
        alertView = [[UIAlertView alloc] initWithTitle:@"Connectivity Issue" message:@"Couldn't connect to SinglePic. Please ensure you have an active internet connection." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Try Again", nil];
    }
    return self;
}
#pragma mark - Overriden methods
-(void)show
{
    [alertView show];
}
-(void)hide
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}
#pragma mark - Self Delegate methods
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [SPSoundHelper playTap];
    
    [[SPRequestManager sharedInstance] ManuallyRefreshReachability];
}
@end
