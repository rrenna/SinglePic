//
//  SPRegistrationViewController.h
//  SinglePic
//
//  Created by Ryan Renna on 11-12-09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "SPStyledButton.h"
#import "SPStyledView.h"
#import "SPStackPanel.h"
#import "SPCardView.h"

@interface SPRegistrationViewController : UIViewController
{
    IBOutlet SPStyledView* insetView;
    IBOutlet SPStyledButton* registerButton;
    IBOutlet SPStackPanel* stackPanel;
    //Register Card
    IBOutlet SPCardView* registrationCard;
    IBOutlet SPStyledButton* registrationButton;
    //Login Card
    IBOutlet SPCardView* loginCard;
    IBOutlet UITextField* usernameField;
    IBOutlet UITextField* passwordField;
    IBOutlet SPStyledButton* loginButton;
}

-(IBAction)spawnRegistrationScreen:(id)sender;
-(IBAction)spawnLoginScreen:(id)sender;
@end
