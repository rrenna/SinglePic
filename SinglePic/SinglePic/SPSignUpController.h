//
//  SPOutOfBoxController.h
//  SinglePic
//
//  Created by Ryan Renna on 11-12-30.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPTabContentViewController.h"

@class SPStyledButton,SSCheckBoxView,SPOrientationChooser;

@interface SPSignUpController : SPTabContentViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    IBOutlet UIView *contentView;
    IBOutlet SPStyledButton *nextButton;
    IBOutlet SPStyledView* signupHeaderView;
    
    //Step 1
    IBOutlet UIView* stepOneView;
    IBOutlet UITableView* bucketTable;
    //Step 2
    IBOutlet UIView* stepTwoView;
    //Step 3
    IBOutlet UIView* stepThreeView;
    IBOutlet UITextField* firstNameField;
    IBOutlet UITextField* emailField;
    IBOutlet UITextField* passwordField;
    IBOutlet UITextField* confirmPasswordField;
    IBOutlet UITableViewCell *firstNameTableViewCell;
    
    IBOutlet UITableViewCell *emailTableViewCell;
    IBOutlet UITableViewCell *passwordTableViewCell;
@private
    SPOrientationChooser* orientationChooser;
    int step;
}
//IBActions
-(IBAction)start:(id)sender;
- (IBAction)next:(id)sender;
@end
