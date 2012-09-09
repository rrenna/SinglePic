//
//  SPSettingsViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-07.
//
//

#import "SPSettingsViewController.h"
#import "SPProfileManager.h"
#import "SPErrorManager.h"
#import "MDACListCredit.h"
#import "MDACCreditItem.h"
#import "SPAboutStyle.h"

@interface SPSettingsViewController ()
-(void)addLogoutButton;
-(void)addSwitchEnvironmentButton;
@end

@implementation SPSettingsViewController

-(id)init
{
    self = [super initWithStyle:[SPAboutStyle style]];
    if(self)
    {
        [self removeLastCredit];
        
        //Add App setting specific credits (interactive)
        //If logged-in - display a logout button
        if([[SPProfileManager sharedInstance] myUserType] != USER_TYPE_ANNONYMOUS)
        {
            [self addLogoutButton];
        }
        
        //Add the ability to switch environments if Testing on TestFlight or Debugging locally        
        if([[SPSettingsManager sharedInstance] canSwitchEnvironments])
        {
            [self addSwitchEnvironmentButton];
        }
    }
    return self;
}
#pragma mark - Actions
//Callbacks for selectors called by the MDAboutController (parent class)
-(void)logout
{
    [[SPProfileManager sharedInstance] logout];
    [self dismissModalViewControllerAnimated:YES];
}
-(void)switchEnvironment
{
    if([[SPSettingsManager sharedInstance] environment] == ENVIRONMENT_TESTING)
    {
        [[SPSettingsManager sharedInstance] setEnvironment:ENVIRONMENT_PRODUCTION];
    }
    else
    {
        [[SPSettingsManager sharedInstance] setEnvironment:ENVIRONMENT_TESTING];
    }
    
    [[SPErrorManager sharedInstance] alertWithTitle:@"You may need to restart the application" Description:@"To fully test SinglePic in your new environment you may want to terminate and restart the app."];
    
    [self logout];

}
#pragma mark - Private methods
-(void)addLogoutButton
{
    MDACListCredit* appOptionsListCredit = [MDACListCredit listCreditWithTitle:@""];
    MDACCreditItem* logoutCreditItem = [MDACCreditItem itemWithName:@"Logout" role:@"" linkString:@"selector:logout"];
    [appOptionsListCredit addItem:logoutCreditItem];
    [self insertCredit:appOptionsListCredit  atIndex:1];
}
-(void)addSwitchEnvironmentButton
{
    MDACListCredit* switchEnvironmentListCredit = [MDACListCredit listCreditWithTitle:@""];
    MDACCreditItem* switchEnvironmentCreditItem;
    
    if([[SPSettingsManager sharedInstance] environment] == ENVIRONMENT_TESTING)
    {
             switchEnvironmentCreditItem = [MDACCreditItem itemWithName:@"Switch to Production" role:@"" linkString:@"selector:switchEnvironment"];
    }
    else
    {
            switchEnvironmentCreditItem = [MDACCreditItem itemWithName:@"Switch to Testing" role:@"" linkString:@"selector:switchEnvironment"];
    }

    [switchEnvironmentListCredit addItem:switchEnvironmentCreditItem];
    [self insertCredit:switchEnvironmentListCredit  atIndex:2];
}
@end
