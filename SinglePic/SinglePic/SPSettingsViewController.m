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
#import "SPOptionCredit.h"
#import "SPOptionCreditItem.h"
#import "SPAboutStyle.h"

@interface SPSettingsViewController ()
-(void)addLogoutButton;
-(void)addSwitchEnvironmentButton;
-(void)addVerboseErrorsToggle;
@end

@implementation SPSettingsViewController

-(id)init
{
    self = [super initWithStyle:[SPAboutStyle style]];
    if(self)
    {
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
        
        //Add the ability to switch errors logging on and off
        if([[SPSettingsManager sharedInstance] canSwitchDisplayVerboseErrors])
        {
            [self addVerboseErrorsToggle];
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
-(BOOL)verboseErrorMessagesEnabled
{
    return [[SPSettingsManager sharedInstance] displayVerboseErrorsEnabled];
}
-(void)setVerboseErrorMessagesEnabledWithControl:(id)control
{
    [Crashlytics setObjectValue:@"Switched on the 'Display Verbose Errors' switch in the Info screen." forKey:@"last_UI_action"];
    
    BOOL enabled;
    
    if([control respondsToSelector:@selector(isOn)])
    {
        enabled = (BOOL)[control performSelector:@selector(isOn)];
        [[SPSettingsManager sharedInstance] setDisplayVerboseErrorsEnabled:enabled];
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
-(void)addVerboseErrorsToggle
{
    SPOptionCredit* optionsListCredit = nil;
    //Find 'Options' List Credit
    for(MDACCredit* credit in self.credits)
    {
        if([credit class] == [SPOptionCredit class]) { optionsListCredit = (SPOptionCredit*)credit; break; } //Find the credit
    }

    SPOptionCreditItem* verboseErrorMessagesEnabledToggleItem = [[SPOptionCreditItem alloc] initWithName:@"Verbose Errors" andOptionGetter:@selector(verboseErrorMessagesEnabled) andOptionSetter:@selector(setVerboseErrorMessagesEnabledWithControl:)];
    [optionsListCredit addItem:verboseErrorMessagesEnabledToggleItem];
}
@end
