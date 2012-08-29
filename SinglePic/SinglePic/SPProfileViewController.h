//
//  PMAProfileViewController.h
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-06.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPPageContentViewController.h"
#import "SPStyledView.h"

@class SPProfileViewController,SPCardView,SPStyledButton,SPProfile;
@protocol ComposeViewDelegate;

@protocol SPProfileViewDelegate <NSObject>
@end

@interface SPProfileViewController : SPPageContentViewController <ComposeViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    //Display
    IBOutlet SPStyledView* profileContentView;
    IBOutlet UILabel* ageLabel;
    IBOutlet UIView* imageBackgroundStyledView;
    IBOutlet UIImageView* imageView; 
    IBOutlet UILabel* messageTipLabel;
    IBOutlet UITableView* historyTable;
    IBOutlet UIImageView* bubbleImage;
    IBOutlet UILabel* icebreakerLabel;
    IBOutlet SPStyledView* bottomBarView;
    IBOutlet SPStyledButton* likeButton;
    IBOutlet SPStyledButton* communicateButton;
    IBOutlet SPStyledButton* modeButton;
}
@property (assign) id<SPProfileViewDelegate> delegate;

-(id)initWithProfile:(SPProfile*)profile;
-(id)initWithIdentifier:(NSString*)identifier;

-(IBAction)message:(id)sender;
-(IBAction)like:(id)sender;
-(IBAction)expandChat:(id)sender;
@end

