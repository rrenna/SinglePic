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
#import "GCPagedScrollView.h"
#import "SPCardView.h"
#import "SPLabel.h"
#import "SPStyledButton.h"

@interface SPRegistrationViewController : UIViewController
{
    IBOutlet SPStyledView* insetView;
    IBOutlet SPStackPanel* stackPanel;
    //Cards
    IBOutlet SPCardView* browseCard;
    IBOutlet SPCardView* chatCard;
    IBOutlet SPCardView* realPeopleRealPicsCard;
    IBOutlet SPCardView* singlePicCard;
    //Labels
    IBOutlet SPLabel *titleLabel;
    IBOutlet SPLabel *browseCardTitleLabel;
    IBOutlet SPLabel *browseCardBodyLabel;
    IBOutlet SPLabel *chatCardTitleLabel;
    IBOutlet SPLabel *chatCardBodyLabel;
    IBOutlet SPLabel *realPeopleRealPicsCardTitleLabel;
    IBOutlet SPLabel *realPeopleRealPicsCardBodyLabel;
    IBOutlet SPLabel *singlePicCardTitleLabel;
    IBOutlet SPLabel *singlePicCardBodyLabel;
    
    //Buttons
    IBOutlet SPStyledButton *registerButton;
    IBOutlet SPStyledButton *loginButton;
}

-(IBAction)spawnRegistrationScreen:(id)sender;
-(IBAction)spawnLoginScreen:(id)sender;
@end
