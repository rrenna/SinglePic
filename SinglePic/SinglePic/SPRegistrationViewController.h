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

@interface SPRegistrationViewController : UIViewController
{
    IBOutlet SPStyledView* insetView;
    IBOutlet SPStackPanel* stackPanel;
    IBOutlet GCPagedScrollView* scrollView;
    //Cards
    IBOutlet SPCardView* browseCard;
    IBOutlet SPCardView* chatCard;
    IBOutlet SPCardView* realPeopleRealPicsCard;
    IBOutlet SPCardView* singlePicCard;
}

-(IBAction)spawnRegistrationScreen:(id)sender;
-(IBAction)spawnLoginScreen:(id)sender;
@end
