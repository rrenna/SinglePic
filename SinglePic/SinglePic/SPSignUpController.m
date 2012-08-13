//
//  SPOutOfBoxController.m
//  SinglePic
//
//  Created by Ryan Renna on 11-12-30.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPSignUpController.h"
#import "SPErrorManager.h"
#import "SPBrowseViewController.h"
#import "SPStyledButton.h"
#import "SPOrientationChooser.h"
#import "SPCardView.h"

@interface SPSignUpController()
-(void)transitionToStep:(int)step;
-(void)stepOneInitialization;
-(void)stepTwoInitialization;
@end

@implementation SPSignUpController

#pragma mark - View lifecycle
-(id)init
{
    self = [self initWithNibName:@"SPSignupController" bundle:nil];
    if(self)
    {
        step = 1;
    }
    return self;
}
-(void)dealloc
{
    [orientationChooser release];
    [firstNameTableViewCell release];
    [emailTableViewCell release];
    [passwordTableViewCell release];
    [contentView release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [nextButton setStyle:STYLE_TAB];
    [signupHeaderView setStyle:STYLE_TAB];
    
    [self transitionToStep:step];
    [self stepOneInitialization];
    [self stepTwoInitialization];
    [self stepThreeInitialization];

}
- (void)viewDidUnload {
    [firstNameTableViewCell release];
    firstNameTableViewCell = nil;
    [emailTableViewCell release];
    emailTableViewCell = nil;
    [passwordTableViewCell release];
    passwordTableViewCell = nil;
    [contentView release];
    contentView = nil;
    [super viewDidUnload];
}
#pragma mark - IBActions
-(IBAction)back:(id)sender
{
    if(step == 3)
    {
        step = 2;
        [self transitionToStep:2];
    }
    else if(step == 2)
    {
        [self close]; //TEMP: Removed step 1
        
        //step = 1;
        //[self transitionToStep:1];
    }
    else
    {
        [self close];
    }
}
- (IBAction)next:(id)sender
{
    if(step == 1)
    {
        step = 2;
        [self transitionToStep:step];
    }
    //Transition to step 2
    else if(step == 2)
    {
        //Save chosen values
        [[SPProfileManager sharedInstance] setMyAnnonymousGender:orientationChooser.chosenGender];
        [[SPProfileManager sharedInstance] setMyAnnonymousPreference:orientationChooser.chosenPreference];
        
        step = 3;
        [self transitionToStep:step];
    }
    else
    {
        [self start:nil];
    }
}
//Leave Out of Box experience
-(IBAction)start:(id)sender
{
    if([passwordField.text isEqualToString:confirmPasswordField.text])
    {
        NSString* chosenEmail = emailField.text;
        NSString* chosenPassword = passwordField.text;
        
        //transition your annonymous
        GENDER annonymousGender = [[SPProfileManager sharedInstance] myAnnonymousGender];
        GENDER annonymousPreference = [[SPProfileManager sharedInstance] myAnnonymousPreference];
        SPBucket* annonymousBucket = [[SPProfileManager sharedInstance] myAnnonymousBucket];
        
        //Disable to prevent multiple clicks
        nextButton.enabled = NO;
        
        [[SPProfileManager sharedInstance] registerWithEmail:chosenEmail andPassword:chosenPassword andGender:annonymousGender andPreference:annonymousPreference andBucket:annonymousBucket andCompletionHandler:^(id responseObject) 
         {              
             //When registration is completed - restart the profile stream
             [[SPProfileManager sharedInstance] restartProfiles];
         } 
                                             andErrorHandler:^
         {
             //This was an invalid email/password combination
             //The Error Manager will print out a human readable explanation depending on the error code returned
             nextButton.enabled = YES;
         }];
    }
    else
    {
        //This was an invalid email/password combination
        [[SPErrorManager sharedInstance]  alertWithTitle:@"Invalid" Description:@"Passwords did not match."];
    }
    
    /*
    //Replace the Out of Box Experience tab with a new tab, containing the Browse controller
    SPBrowseViewController* browseController = [[SPBrowseViewController new] autorelease];
    [self replaceWith:browseController];
     */
}
#pragma mark - Private methods
//Transition to the next step
-(void)transitionToStep:(int)_step
{
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if(_step == 1)
    {
        //TEMP: Removed step 1
        
        /*
        nextButton.enabled = NO;
        [nextButton setStyle:STYLE_ALTERNATIVE_ACTION_1_BUTTON];
        [contentView addSubview:stepOneView];
         */
        
        step = 2;
        [self transitionToStep:2];
    }
    else if(_step == 2)
    {
        [nextButton setStyle:STYLE_ALTERNATIVE_ACTION_1_BUTTON];
        [contentView addSubview:stepTwoView];
        
    }
    else if(_step == 3)
    {
        [nextButton setStyle:STYLE_CONFIRM_BUTTON];
        [contentView addSubview:stepThreeView];
        
        [firstNameField becomeFirstResponder]; //Launch keyboard, edit first name field
    }
}
-(void)stepOneInitialization
{
        //
}
-(void)stepTwoInitialization
{
    //Step 2 initialization steps
    if(!orientationChooser)
    {
        orientationChooser = [[SPOrientationChooser alloc] initWithFrame:CGRectMake(stepTwoView.width * 0.05, stepTwoView.height * 0.25, stepTwoView.width * 0.9, stepTwoView.height * 0.6)];
    }

    [stepTwoView addSubview:orientationChooser];
}
-(void)stepThreeInitialization
{
    //Step 3 initialization steps
}
#pragma mark - UITableView datasource and delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Registration Form Table
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell;

        if(indexPath.row == 0)
        {
            cell = firstNameTableViewCell;
        }
        else if(indexPath.row == 1)
        {
            cell = emailTableViewCell;
        }
        else
        {
            cell = passwordTableViewCell;
        }

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 2)
    {
        //Return 80 point height for the password row in the registration form
        return 80;
    }
    //return the default 40 point height
    return 40;
}
#pragma mark - UITextField delegate methods
/*- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if(textField.frame.origin.y < 100)
    {
        [scrollView setContentOffset: CGPointMake(0,0) animated:YES];
    }
    else
    {
        [scrollView setContentOffset: CGPointMake(0, 75) animated:YES];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    //Tapping the return key on the password or email field will bring you to the next field, on the confirm password field it dismisses the keyboard
    if(textField == firstNameField)
    {
        [emailField becomeFirstResponder];
    }
    else if(textField == emailField)
    {
        [passwordField becomeFirstResponder];
    }
    else if(textField == passwordField)
    {
        [confirmPasswordField becomeFirstResponder];
    }
    else 
    {
        [confirmPasswordField resignFirstResponder];
        [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    }
    
    return NO;
}*/
#pragma mark - SPLocationChooserDelegate methods
-(void)locationChooserSelectionChanged:(SPLocationChooser*)chooser
{
    SPBucket* bucket = chooser.selected;
    
    [[SPProfileManager sharedInstance] setMyAnnonymousBucket:bucket synchronize:YES];
    
    //Cannot proceed until a bucket is selected
    nextButton.enabled = YES;
}
@end
