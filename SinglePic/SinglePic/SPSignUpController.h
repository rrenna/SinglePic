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
    IBOutlet __weak UIView *contentView;
    IBOutlet __weak SPLabel *titleLabel;
    IBOutlet __weak SPStyledButton *backButton;
    IBOutlet __weak SPStyledButton *nextButton;
    IBOutlet __weak SPStyledView* signupHeaderView;
    
    //Step 1
    IBOutlet __weak UIView* stepOneView;
    IBOutlet __weak UILabel *tagline1Label;
    //Step 2
    IBOutlet __weak UIView* stepTwoView;
    IBOutlet __weak SPLabel *tagline2Label;
    //Step 3
    IBOutlet __weak UIView* stepThreeView;
    IBOutlet __weak SPLabel *usernameLabel;
    IBOutlet __weak UITextField* userNameField;
    IBOutlet __weak SPLabel *emailLabel;
    IBOutlet __weak UITextField* emailField;
    IBOutlet __weak SPLabel *passwordLabel;
    IBOutlet __weak UITextField* passwordField;
    IBOutlet __weak SPLabel *confirmPasswordLabel;
    IBOutlet __weak UITextField* confirmPasswordField;
    IBOutlet __weak UILabel* userNameHintLabel;
    IBOutlet __weak UILabel* emailHintLabel;
    IBOutlet __weak UILabel* passwordHintLabel;
    IBOutlet __weak UITableView *signupFormTable;
    IBOutlet __weak UITableViewCell *firstNameTableViewCell;
    IBOutlet __weak UITableViewCell *emailTableViewCell;
    IBOutlet __weak UITableViewCell *passwordTableViewCell;
}
//IBActions
-(IBAction)start:(id)sender;
-(IBAction)back:(id)sender;
-(IBAction)next:(id)sender;
@end
