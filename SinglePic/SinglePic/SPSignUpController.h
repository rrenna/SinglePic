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
    IBOutlet SPLabel *titleLabel;
    IBOutlet SPStyledButton *backButton;
    IBOutlet SPStyledButton *nextButton;
    IBOutlet SPStyledView* signupHeaderView;
    
    //Step 1
    IBOutlet UIView* stepOneView;
    IBOutlet UILabel *tagline1Label;
    //Step 2
    IBOutlet UIView* stepTwoView;
    IBOutlet SPLabel *tagline2Label;
    //Step 3
    IBOutlet UIView* stepThreeView;
    IBOutlet SPLabel *usernameLabel;
    IBOutlet UITextField* userNameField;
    IBOutlet SPLabel *emailLabel;
    IBOutlet UITextField* emailField;
    IBOutlet SPLabel *passwordLabel;
    IBOutlet UITextField* passwordField;
    IBOutlet SPLabel *confirmPasswordLabel;
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
