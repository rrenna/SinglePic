//
//  SPRegistrationViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 11-12-09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPRegistrationViewController.h"
#import "SPSignUpController.h"
#import "SPLoginController.h"

@interface SPRegistrationViewController()
-(void)spawnRegistrationPrompt;
@end

@implementation SPRegistrationViewController
#pragma mark - View lifecycle
- (id)init
{
    self = [self initWithNibName:@"SPRegistrationViewController" bundle:nil];
    if(self)
    {
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [insetView setStyle:STYLE_BASE];
    [registrationButton setStyle:STYLE_CONFIRM_BUTTON];
    
    [stackPanel addStackedView:registrationCard];
    [stackPanel addStackedView:loginCard];
}
-(void)dealloc
{
    [super dealloc];
}
#pragma mark - IBActions
-(IBAction)spawnRegistrationScreen:(id)sender
{
    SPBaseController* baseController = [SPAppDelegate baseController];
    
    SPSignUpController* signupController = [[SPSignUpController new] autorelease];
    
    [baseController pushModalController:signupController isFullscreen:YES];
}
-(IBAction)spawnLoginScreen:(id)sender
{
    SPBaseController* baseController = [SPAppDelegate baseController];
    
    SPLoginController* loginController = [[SPLoginController new] autorelease];
    [baseController pushModalController:loginController isFullscreen:YES];
}
@end
