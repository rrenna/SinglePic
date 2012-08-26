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
    IBOutlet SPStyledButton *backButton;
    IBOutlet SPStyledButton *nextButton;
    IBOutlet SPStyledView* signupHeaderView;
    
    //Step 1
    IBOutlet UIView* stepOneView;
    IBOutlet UITableView* bucketTable;
    //Step 2
    IBOutlet UIView* stepTwoView;
    //Step 3
    IBOutlet UIView* stepThreeView;
    IBOutlet UITextField* userNameField;
    IBOutlet UITextField* emailField;
    IBOutlet UITextField* passwordField;
    IBOutlet UITextField* confirmPasswordField;
    IBOutlet UILabel* userNameHintLabel;
    IBOutlet UILabel* emailHintLabel;
    IBOutlet UILabel* passwordHintLabel;
    IBOutlet UITableView *signupFormTable;
    IBOutlet UITableViewCell *firstNameTableViewCell;
    IBOutlet UITableViewCell *emailTableViewCell;
    IBOutlet UITableViewCell *passwordTableViewCell;
@private
    SPOrientationChooser* orientationChooser;
    int step;
    //Step 3
    BOOL userNameFieldValid;
    BOOL emailFieldValid;
    BOOL passwordsValid;
}
//IBActions
-(IBAction)start:(id)sender;
-(IBAction)back:(id)sender;
-(IBAction)next:(id)sender;
@end
