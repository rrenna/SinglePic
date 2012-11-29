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
    self = [self initWithNibName:@"SPOOBEViewController" bundle:nil];
    if(self)
    {
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [insetView setStyle:STYLE_BASE];
    /*
    [scrollView addContentSubview:browseCard];
    [scrollView addContentSubview:chatCard];
    [scrollView addContentSubview:realPeopleRealPicsCard];
    [scrollView addContentSubview:singlePicCard];
     */
   [stackPanel addStackedView:browseCard];
    [stackPanel addStackedView:chatCard];
    [stackPanel addStackedView:realPeopleRealPicsCard];
    [stackPanel addStackedView:singlePicCard];
}
-(void)dealloc
{
    [super dealloc];
}
#pragma mark - IBActions
-(IBAction)spawnRegistrationScreen:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on the 'Register' button in the OOBE screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    SPBaseController* baseController = [SPAppDelegate baseController];
    
    SPSignUpController* signupController = [[SPSignUpController new] autorelease];
    
    [baseController pushModalController:signupController isFullscreen:YES];
}
-(IBAction)spawnLoginScreen:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on the 'Login' button in the OOBE screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    SPBaseController* baseController = [SPAppDelegate baseController];
    
    SPLoginController* loginController = [[SPLoginController new] autorelease];
    [baseController pushModalController:loginController isFullscreen:YES];
}
@end
