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
    //Localize Controls
    titleLabel.text = NSLocalizedString(@"Sign Up",nil);
    browseCardTitleLabel.text = NSLocalizedString(@"Browse",nil);
    browseCardBodyLabel.text = NSLocalizedString(@"Look for singles in your area.",nil);
    chatCardTitleLabel.text = NSLocalizedString(@"Chat",nil);
    chatCardBodyLabel.text = NSLocalizedString(@"Say hello. Start a conversation and see where it leads.",nil);
    realPeopleRealPicsCardTitleLabel.text = NSLocalizedString(@"Real People. Real Pics.",nil);
    realPeopleRealPicsCardBodyLabel.text = NSLocalizedString(@"New profile pics are taken every seven days - no more fake or outdated photos.",nil);
    singlePicCardTitleLabel.text = NSLocalizedString(@"A Fun Way To Meet Singles",nil);
    singlePicCardBodyLabel.text = NSLocalizedString(@"Sign up or log in.",nil);
    [registerButton setTitle:NSLocalizedString(@"Register",nil)
                    forState:UIControlStateNormal];
    [loginButton setTitle:NSLocalizedString(@"Login",nil)
                    forState:UIControlStateNormal];
    
    
    [super viewDidLoad];
    [insetView setStyle:STYLE_BASE];

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
- (void)viewDidUnload {
    registerButton = nil;
    loginButton = nil;
    browseCardTitleLabel = nil;
    browseCardBodyLabel = nil;
    chatCardTitleLabel = nil;
    chatCardBodyLabel = nil;
    realPeopleRealPicsCardTitleLabel = nil;
    realPeopleRealPicsCardBodyLabel = nil;
    singlePicCardTitleLabel = nil;
    singlePicCardBodyLabel = nil;
    titleLabel = nil;
    [super viewDidUnload];
}
@end
