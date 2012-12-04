//
//  SPSettingsViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-07.
//
//

#import "SPSettingsViewController.h"
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
    [Crashlytics setObjectValue:@"Clicked on the 'Logout' button in the Info screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    [[SPProfileManager sharedInstance] logout];
    [self dismissModalViewControllerAnimated:YES];
}
-(void)switchEnvironment
{
    [Crashlytics setObjectValue:@"Clicked on the 'Switch Environment' button in the Info screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
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
-(BOOL)soundEffectsEnabledValue
{
    return [[SPSettingsManager sharedInstance] soundEffectsEnabled];
}
-(void)setSoundEffectsEnabledWithControl:(id)control
{
    [Crashlytics setObjectValue:@"Switched on the 'Sound Effects' switch in the Info screen." forKey:@"last_UI_action"];
    
    BOOL enabled;
    
    if([control respondsToSelector:@selector(isOn)])
    {
        enabled = (BOOL)[control performSelector:@selector(isOn)];
        [[SPSettingsManager sharedInstance] setSoundEffectsEnabled:enabled];
    }
}
-(BOOL)saveToCameraRollEnabledValue
{
    return [[SPSettingsManager sharedInstance] saveToCameraRollEnabled];
}
-(void)setSaveToCameraRollEnabledWithControl:(id)control
{
    [Crashlytics setObjectValue:@"Switched on the 'Save Pics to Camera Roll' switch in the Info screen." forKey:@"last_UI_action"];
    
    BOOL enabled;
    
    if([control respondsToSelector:@selector(isOn)])
    {
        enabled = (BOOL)[control performSelector:@selector(isOn)];
        [[SPSettingsManager sharedInstance] setSaveToCameraRollEnabled:enabled];
    }
}
#pragma mark - Private methods
-(void)addLogoutButton
{
    MDACListCredit* appOptionsListCredit = [MDACListCredit listCreditWithTitle:@""];
    MDACCreditItem* logoutCreditItem = [MDACCreditItem itemWithName:NSLocalizedString(@"Logout",nil) role:@"" linkString:@"selector:logout"];
    [appOptionsListCredit addItem:logoutCreditItem];
    [self insertCredit:appOptionsListCredit  atIndex:2];
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
    [self insertCredit:switchEnvironmentListCredit  atIndex:1];
}
@end
