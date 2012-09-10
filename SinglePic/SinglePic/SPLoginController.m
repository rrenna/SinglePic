//
//  SPLoginController.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-05-27.
//
//

#import "SPLoginController.h"
#import "SPProfileManager.h"

@interface SPLoginController ()

@end

@implementation SPLoginController
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
    
    [emailTextField becomeFirstResponder]; //Launch keyboard, edit user name field
}
- (void)dealloc {
    [passwordTextField release];
    [emailTextField release];
    [passwordTableViewCell release];
    [emailTableViewCell release];
    [loginButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setPasswordTextField:nil];
    [self setEmailTextField:nil];
    [self setPasswordTableViewCell:nil];
    [self setEmailTableViewCell:nil];
    [self setLoginButton:nil];
    [super viewDidUnload];
}
- (IBAction)back:(id)sender
{
    [self close];
}
- (IBAction)login:(id)sender
{
    loginButton.enabled = NO;
    
    [[SPProfileManager sharedInstance] loginWithEmail:emailTextField.text andPassword:passwordTextField.text andCompletionHandler:^(id responseObject)
     {
         //Login successful
         NSLog(@"Login successful");
         
     } andErrorHandler:^
     {
         //Re-enable the login button if the login fails for any reason
         loginButton.enabled = YES;
         
         //Login failed
         NSLog(@"Login failed");
         
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
