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

@end

@implementation SPLoginController
@synthesize headerStyledView;
@synthesize loginButton;
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
    [super viewDidLoad];
    [loginButton setStyle:STYLE_CONFIRM_BUTTON];
    [headerStyledView setStyle:STYLE_TAB];
    
    emailTextField.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:emailTextField.font.pointSize];
    passwordTextField.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:emailTextField.font.pointSize];
    
    NSString* emailFieldLastUsedValue = [[NSUserDefaults standardUserDefaults] stringForKey:EMAIL_FIELD_LAST_USED_VALUE_KEY];
    if(emailFieldLastUsedValue)
    {
        emailTextField.text = emailFieldLastUsedValue;
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
    [super dealloc];
}
- (IBAction)back:(id)sender
{
    [SPSoundHelper playTap];
    
    [self close];
}
- (IBAction)login:(id)sender
{
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
@end
