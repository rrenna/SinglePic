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
    __weak IBOutlet SPLabel *titleLabel;
    __weak IBOutlet SPLabel *browseCardTitleLabel;
    __weak IBOutlet SPLabel *browseCardBodyLabel;
    __weak IBOutlet SPLabel *chatCardTitleLabel;
    __weak IBOutlet SPLabel *chatCardBodyLabel;
    __weak IBOutlet SPLabel *realPeopleRealPicsCardTitleLabel;
    __weak IBOutlet SPLabel *realPeopleRealPicsCardBodyLabel;
    __weak IBOutlet SPLabel *singlePicCardTitleLabel;
    __weak IBOutlet SPLabel *singlePicCardBodyLabel;
    
    //Buttons
    __weak IBOutlet SPStyledButton *registerButton;
    __weak IBOutlet SPStyledButton *loginButton;
}

-(IBAction)spawnRegistrationScreen:(id)sender;
-(IBAction)spawnLoginScreen:(id)sender;
@end
