//
//  SPLoginController.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-05-27.
//
//

#import "SPLoginController.h"
#import "SPProfileManager.h"

static const NSString* EMAIL_FIELD_LAST_USED_VALUE_KEY = @"EMAIL_FIELD_LAST_USED_VALUE_KEY";

@interface SPLoginController ()
{
    BOOL emailFieldValid;
    BOOL passwordFieldValid;
}
@end

@implementation SPLoginController
@synthesize headerStyledView;
@synthesize loginButton;
@synthesize backButton;
@synthesize emailTextField;
@synthesize passwordTextField;
@synthesize passwordTableViewCell;
@synthesize emailTableViewCell;

- (id)init
{
    self = [self initWithNibName:@"SPLoginController" bundle:nil];
    if(self)
    {
    }
    return self;
}
- (void)viewDidLoad
{
    //Localize Controls
    titleLabel.text = NSLocalizedString(@"Login",nil);
    [loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    [backButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    
    [super viewDidLoad];
    [loginButton setStyle:STYLE_CONFIRM_BUTTON];
    [headerStyledView setStyle:STYLE_TAB];
    
    emailTextField.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:emailTextField.font.pointSize];
    passwordTextField.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:emailTextField.font.pointSize];
    
    NSString* emailFieldLastUsedValue = [[NSUserDefaults standardUserDefaults] stringForKey:EMAIL_FIELD_LAST_USED_VALUE_KEY];
    if(emailFieldLastUsedValue)
    {
        emailTextField.text = emailFieldLastUsedValue;
        emailFieldValid = true; //If we're pre-filling in the username, it passes validation automatically
        [passwordTextField becomeFirstResponder]; //Launch keyboard, edit password field
    }
    else
    {
        [emailTextField becomeFirstResponder]; //Launch keyboard, edit user name field
    }

}
- (void)dealloc {
    [headerStyledView release];
    [passwordTextField release];
    [emailTextField release];
    [passwordTableViewCell release];
    [emailTableViewCell release];
    [loginButton release];
    [backButton release];
    [super dealloc];
}
- (IBAction)back:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on the 'Back' button in the Login screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    [self close];
}
- (IBAction)login:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on the 'Login' button in the Login screen." forKey:@"last_UI_action"];
    
    loginButton.enabled = NO;
    
    [[SPProfileManager sharedInstance] loginWithEmail:emailTextField.text andPassword:passwordTextField.text andCompletionHandler:^(id responseObject)
     {
         //Login successful
         [[NSUserDefaults standardUserDefaults] setObject:emailTextField.text forKey:EMAIL_FIELD_LAST_USED_VALUE_KEY];
         [[NSUserDefaults standardUserDefaults] synchronize];
         
     } andErrorHandler:^
     {
         //Re-enable the login button if the login fails for any reason
         loginButton.enabled = YES;
     }];
}
#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return emailTableViewCell;
    }
    else
    {
        return passwordTableViewCell;
    }
}
#pragma mark - UITextFieldDelegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
     //Step 1 - Filter out invalid characters
    if(textField == emailTextField)
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
        
        if(textField == emailTextField)
        {
            emailFieldValid = ([newValue length] > 0);
        }
        else
        {
            passwordFieldValid = ([newValue length] > 0);
            
        }
    }
    
    loginButton.enabled = (emailFieldValid && passwordFieldValid);
    
    return YES;
}
//Used to enable 'Next' button on email textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //If the Return button is pressed on the password field, attempt a login
    if(textField == passwordTextField)
    {
        [passwordTextField resignFirstResponder];
        [self login:nil];
    }
    //If the Return button is pressed on the email field, switch to the password field
    else
    {
        [passwordTextField becomeFirstResponder];
    }
    return YES;
}
- (void)viewDidUnload {
    [self setLoginButton:nil];
    [self setBackButton:nil];
    [self setTitleLabel:nil];
    titleLabel = nil;
    [super viewDidUnload];
}
@end
