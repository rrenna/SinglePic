//
//  SPOutOfBoxController.h
//  SinglePic
//
//  Created by Ryan Renna on 11-12-30.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPTabContentViewController.h"
#import "SPLocationChooser.h"
#import "SPOrientationChooser.h"

@class SPStyledButton,SSCheckBoxView,SPOrientationChooser;

@interface SPSignUpController : SPTabContentViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,SPLocationChooserDelegate>
{
    IBOutlet UIView *contentView;
    __weak IBOutlet SPLabel *titleLabel;
    IBOutlet SPStyledButton *backButton;
    IBOutlet SPStyledButton *nextButton;
    IBOutlet SPStyledView* signupHeaderView;
    
    //Step 1
    IBOutlet UIView* stepOneView;
    __weak IBOutlet UILabel *tagline1Label;
    //Step 2
    IBOutlet UIView* stepTwoView;
    __weak IBOutlet SPLabel *tagline2Label;
    //Step 3
    IBOutlet UIView* stepThreeView;
    __weak IBOutlet SPLabel *usernameLabel;
    IBOutlet UITextField* userNameField;
    __weak IBOutlet SPLabel *emailLabel;
    IBOutlet UITextField* emailField;
    __weak IBOutlet SPLabel *passwordLabel;
    IBOutlet UITextField* passwordField;
    __weak IBOutlet SPLabel *confirmPasswordLabel;
    IBOutlet UITextField* confirmPasswordField;
    IBOutlet UILabel* userNameHintLabel;
    IBOutlet UILabel* emailHintLabel;
    IBOutlet UILabel* passwordHintLabel;
    IBOutlet UITableView *signupFormTable;
    IBOutlet UITableViewCell *firstNameTableViewCell;
    IBOutlet UITableViewCell *emailTableViewCell;
    IBOutlet UITableViewCell *passwordTableViewCell;
}
//IBActions
-(IBAction)start:(id)sender;
-(IBAction)back:(id)sender;
-(IBAction)next:(id)sender;
@end
