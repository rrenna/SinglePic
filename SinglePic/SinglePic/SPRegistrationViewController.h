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
    IBOutlet __weak SPStyledView* insetView;
    IBOutlet __weak SPStackPanel* stackPanel;
    //Cards
    IBOutlet __weak SPCardView* browseCard;
    IBOutlet __weak SPCardView* chatCard;
    IBOutlet __weak SPCardView* realPeopleRealPicsCard;
    IBOutlet __weak SPCardView* singlePicCard;
    //Labels
    IBOutlet __weak SPLabel *titleLabel;
    IBOutlet __weak SPLabel *browseCardTitleLabel;
    IBOutlet __weak SPLabel *browseCardBodyLabel;
    IBOutlet __weak SPLabel *chatCardTitleLabel;
    IBOutlet __weak SPLabel *chatCardBodyLabel;
    IBOutlet __weak SPLabel *realPeopleRealPicsCardTitleLabel;
    IBOutlet __weak SPLabel *realPeopleRealPicsCardBodyLabel;
    IBOutlet __weak SPLabel *singlePicCardTitleLabel;
    IBOutlet __weak SPLabel *singlePicCardBodyLabel;
    
    //Buttons
    IBOutlet __weak SPStyledButton *registerButton;
    IBOutlet __weak SPStyledButton *loginButton;
}

-(IBAction)spawnRegistrationScreen:(id)sender;
-(IBAction)spawnLoginScreen:(id)sender;
@end
