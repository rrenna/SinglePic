//
//  SPOutOfBoxController.m
//  SinglePic
//
//  Created by Ryan Renna on 11-12-30.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPSignUpController.h"
#import "SPBrowseViewController.h"
#import "SPStyledButton.h"
#import "SPOrientationChooser.h"
#import "SPCardView.h"

static const NSString* EMAIL_FIELD_LAST_USED_VALUE_KEY = @"EMAIL_FIELD_LAST_USED_VALUE_KEY";

@interface SPSignUpController()
{
    SPOrientationChooser* orientationChooser;
    int step;
    //Step 3
    BOOL userNameFieldValid;
    BOOL emailFieldValid;
    BOOL passwordsValid;
}
-(void)transitionToStep:(int)step;
-(void)stepOneInitialization;
-(void)stepTwoInitialization;
-(void)stepThreeInitialization;
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Initially the 'next' button will be disabled
    nextButton.enabled = NO;
    
    //Localize Controls
    titleLabel.text = NSLocalizedString(@"Registration",nil);
    tagline1Label.text = NSLocalizedString(@"A Fun Way To Meet Singles", nil);
    tagline2Label.text = NSLocalizedString(@"A Fun Way To Meet Singles", nil);
    [nextButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    [backButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    usernameLabel.text = NSLocalizedString(@"Username", nil);
    emailLabel.text = NSLocalizedString(@"Email", nil);
    passwordLabel.text = NSLocalizedString(@"Password", nil);
    confirmPasswordLabel.text = NSLocalizedString(@"Repeat Password", nil);
    userNameField.placeholder = NSLocalizedString(@"Required", nil);
    emailField.placeholder = NSLocalizedString(@"Required", nil);
    passwordField.placeholder = NSLocalizedString(@"Required", nil);
    confirmPasswordField.placeholder = NSLocalizedString(@"Required", nil);
    
    [[SPAppDelegate baseController] setStatusBarStyle:STYLE_TAB];
    
    [nextButton setStyle:STYLE_TAB];
    [signupHeaderView setStyle:STYLE_TAB];
    
    userNameField.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:userNameField.font.pointSize];
    emailField.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:emailField.font.pointSize];
    passwordField.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:passwordField.font.pointSize];
    confirmPasswordField.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:confirmPasswordField.font.pointSize];
    userNameHintLabel.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:userNameHintLabel.font.pointSize];
    emailHintLabel.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:emailHintLabel.font.pointSize];
    passwordHintLabel.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:passwordHintLabel.font.pointSize];
    
    [self transitionToStep:step];
    [self stepOneInitialization];
    [self stepTwoInitialization];
    [self stepThreeInitialization];

}
-(void) close
{
    [super close];
    
    //Set device status bar colour back to base
    [[SPAppDelegate baseController] setStatusBarStyle:STYLE_BASE];
}
#pragma mark - IBActions
-(IBAction)back:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on the 'Back' button in the Register screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    if(step == 3)
    {
        [self transitionToStep:2];
        step = 2;
    }
    else if(step == 2)
    {
        [self transitionToStep:1];
        step = 1;
    }
    else
    {
        [self close];
    }
}
- (IBAction)next:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on the 'Next' button in the Register screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    if(step == 1)
    {
        [self transitionToStep:2];
        step = 2;
    }
    //Transition to step 2
    else if(step == 2)
    {
        //Save chosen values
        [[SPProfileManager sharedInstance] setMyAnnonymousGender:orientationChooser.chosenGender];
        [[SPProfileManager sharedInstance] setMyAnnonymousPreference:orientationChooser.chosenPreference];
        
        [self transitionToStep:3];
        step = 3;
    }
    else
    {
        [self start:nil];
    }
}
//Leave Out of Box experience
-(IBAction)start:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on the final 'Next' button in the Register screen to create an account." forKey:@"last_UI_action"];
    
    if([passwordField.text isEqualToString:confirmPasswordField.text])
    {
        NSString* chosenUsername = userNameField.text;
        NSString* chosenEmail = emailField.text;
        NSString* chosenPassword = passwordField.text;
        
        //transition your annonymous
        GENDER annonymousGender = [[SPProfileManager sharedInstance] myAnnonymousGender];
        GENDER annonymousPreference = [[SPProfileManager sharedInstance] myAnnonymousPreference];
        SPBucket* annonymousBucket = [[SPProfileManager sharedInstance] myAnnonymousBucket];
        
        //Disable to prevent multiple clicks
        backButton.enabled = NO;
        nextButton.enabled = NO;
        
        [[SPProfileManager sharedInstance] registerWithEmail:chosenEmail andUserName:chosenUsername andPassword:chosenPassword andGender:annonymousGender andPreference:annonymousPreference andBucket:annonymousBucket andCompletionHandler:^(id responseObject)
         {
             [self close];
             
             //Registration successful
             [[NSUserDefaults standardUserDefaults] setObject:chosenEmail forKey:EMAIL_FIELD_LAST_USED_VALUE_KEY];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             //When registration is completed - restart the profile stream
             [[SPProfileManager sharedInstance] restartProfiles];
         } 
         andErrorHandler:^
         {
             //This was an invalid email/password combination
             //The Error Manager will print out a human readable explanation depending on the error code returned
             backButton.enabled = YES;
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
    //Going backwards, move content left to right
    CGFloat offset = (_step > step) ? -400 : 400;
    UIView* newView = nil;
    
    for(UIView* subview in contentView.subviews)
    {
        [UIView animateWithDuration:0.5 animations:^{
            
            subview.left += offset;
            
        } completion:^(BOOL finished) {
            
            [subview removeFromSuperview];
            subview.left -= offset;
        }];
    }
    
    if(_step == 1)
    {
        [nextButton setStyle:STYLE_ALTERNATIVE_ACTION_1_BUTTON];
        newView = stepOneView;
    }
    else if(_step == 2)
    {
        [nextButton setStyle:STYLE_ALTERNATIVE_ACTION_1_BUTTON];
        [nextButton setEnabled:YES];
        newView = stepTwoView;
        
    }
    else if(_step == 3)
    {
        [nextButton setStyle:STYLE_CONFIRM_BUTTON];
        [nextButton setEnabled:NO];
        newView = stepThreeView;
        
        [userNameField becomeFirstResponder]; //Launch keyboard, edit user name field
    }
    
    //Slide out old content
    if(newView)
    {
        [contentView addSubview:newView];
        
        newView.left -= offset;
        [UIView animateWithDuration:0.5 animations:^{
            
            newView.left += offset;
            
        }];
    }

}
-(void)stepOneInitialization
{
        //Step 1 initialization steps
}
-(void)stepTwoInitialization
{
    //Step 2 initialization steps
    if(!orientationChooser)
    {
        orientationChooser = [[SPOrientationChooser alloc] initWithFrame:CGRectMake(stepTwoView.width * 0.01, stepTwoView.height * 0.0, stepTwoView.width * 0.98, stepTwoView.height * 0.5)];
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
    if(indexPath.row == 0)
    {
        return 40;
    }
    else if(indexPath.row == 2)
    {
        //Return 80 point height for the password row in the registration form
        return 70;
    }

    return 46;
}
#pragma mark - UITextField delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == userNameField)
    {
        userNameHintLabel.hidden = NO;
        emailHintLabel.hidden = YES;
        passwordHintLabel.hidden = YES;
    }
    else if(textField == emailField)
    {
        userNameHintLabel.hidden = YES;
        emailHintLabel.hidden = NO;
        passwordHintLabel.hidden = YES;
    }
    else if(textField == passwordField || textField == confirmPasswordField)
    {
        userNameHintLabel.hidden = YES;
        emailHintLabel.hidden = YES;
        passwordHintLabel.hidden = NO;
    }
}
BOOL validateUserName(NSString* userName,NSString **hint) {
    
    BOOL length = ([userName length] >= MINIMUM_USERNAME_LENGTH);
    
    //Return a human readable hint
    if(length) { *hint = nil; }
    else { *hint = [NSString stringWithFormat:@"%i characters left",(MINIMUM_USERNAME_LENGTH - [userName length])]; }
    
    return length;
}
BOOL validateEmail(NSString* email, NSString **hint) {
    
    BOOL emailLength = ([email length] > 4); //Shortest email possible
    BOOL containsAmpersand = ( [email rangeOfString:@"@"].location != NSNotFound );
    BOOL endsWithAmpersand = ( [email rangeOfString:@"@"].location != [email length] - 1 );
    BOOL containsPeriod = ( [email rangeOfString:@"."].location != NSNotFound );
    BOOL endsWithPeriod = ( [email rangeOfString:@"."].location != [email length] - 1 );
    
    //Return a human readable hint
    if(emailLength && containsAmpersand && endsWithAmpersand && containsPeriod && endsWithPeriod)
    {
        *hint = nil; return YES;
    }
    else if(!emailLength)
    {
        *hint = [NSString stringWithFormat:@"%i characters left",(MINIMUM_EMAIL_LENGTH - [email length])];
    }
    else if(!containsAmpersand)
    {
        *hint = @"Should contain an ampersand";
    }
    else if(!endsWithAmpersand)
    {
        *hint = @"Should not end with a ampersand";
    }
    else if(!containsPeriod)
    {
        *hint = @"Should contain a period";
    }
    else if(!endsWithPeriod)
    {
        *hint = @"Should not end with a period";
    }
    else
    {
        *hint = @"Does not appear to be a valid email address";
    }

    return NO;
}
BOOL validatePasswords(NSString* password, NSString* confirm, NSString **hint) {
    
    BOOL passwordLength = ([password length] >= MINIMUM_PASSWORD_LENGTH) && ([confirm length] >= MINIMUM_PASSWORD_LENGTH);
    BOOL passwordMatch = [password isEqualToString:confirm];
    
    //Return a human readable hint
    if(passwordLength && passwordMatch)
    {
        *hint = nil; return YES;
    }
    else if(!passwordMatch)
    {
        *hint = @"Passwords should match";
    }
    else if(!passwordLength)
    {
        *hint = [NSString stringWithFormat:@"%i characters left",(MINIMUM_PASSWORD_LENGTH - [password length])];
    }
    
    return NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //Step 1 - Filter out invalid characters
    if(textField == userNameField)
    {
        //Only allow alpha-numeric usernames
        NSCharacterSet* alphaNumericSet = [NSCharacterSet alphanumericCharacterSet];
        NSCharacterSet* invalidCharacterSet = [alphaNumericSet invertedSet];
        
        if([string rangeOfCharacterFromSet:invalidCharacterSet].location != NSNotFound)
        {
             return NO;
        }
    }
    else if(textField == emailField)
    {
        //Shouldn't include a space
        if([string rangeOfString:@" "].location != NSNotFound)
        {
            return NO;
        }
    }
    
    //Step 2 - Re-calculate valid, update hint text
    {
        //New textfield value
        NSString* newValue = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if(textField == userNameField)
        {
            //Hint text
            NSString* userNameHint;
            
            userNameFieldValid = (textField == userNameField) ? validateUserName(newValue,&userNameHint) : validateUserName(userNameField.text,&userNameHint);
            
            //Set hint text
            userNameHintLabel.text = userNameHint;
            
            
            //Set text colours
            userNameField.textColor = (userNameFieldValid) ? [UIColor blackColor] : [UIColor redColor];
        }
        else if(textField == emailField)
        {
            
            //Hint text
            NSString* emailHint;
            
            emailFieldValid = (textField == emailField) ? validateEmail(newValue,&emailHint) : validateEmail(emailField.text,&emailHint);
            
            //Set hint text
            emailHintLabel.text = emailHint;
            
            //Set text colours
            emailField.textColor = (emailFieldValid) ? [UIColor blackColor] : [UIColor redColor];
        }
        else
        {
            //Hint text
            NSString* passwordHint;
            
            passwordsValid = NO;
            
            if(textField == passwordField || textField == confirmPasswordField)
            {
                if(textField == passwordField)
                {
                    passwordsValid = validatePasswords(newValue, confirmPasswordField.text, &passwordHint);
                }
                else
                {
                    passwordsValid = validatePasswords(passwordField.text, newValue, &passwordHint);
                }
            }
            else
            {
                passwordsValid = validatePasswords(passwordField.text, confirmPasswordField.text, &passwordHint);
            }
            
            //Set hint text
            passwordHintLabel.text = passwordHint;
            
            //Set text colours
            passwordField.textColor = (passwordsValid) ? [UIColor blackColor] : [UIColor redColor];
            confirmPasswordField.textColor = passwordField.textColor;
        }
        
        nextButton.enabled = (userNameFieldValid && emailFieldValid && passwordsValid);
    }
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    //Tapping the return key on the password or email field will bring you to the next field, on the confirm password field it dismisses the keyboard
    if(textField == userNameField)
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
    }
    
    return NO;
}
#pragma mark - SPLocationChooserDelegate methods
-(void)locationChooserSelectionChanged:(SPLocationChooser*)chooser
{
    SPBucket* bucket = chooser.chosenBucket;
    
    [[SPProfileManager sharedInstance] setMyAnnonymousBucket:bucket synchronize:YES];
    
    //Cannot proceed until a bucket is selected
    nextButton.enabled = YES;
}
@end
