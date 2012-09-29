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

@protocol SPProfileViewDelegate <NSObject>
@end

@interface SPProfileViewController : SPPageContentViewController <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    IBOutlet UILabel* ageLabel;
    IBOutlet UIImageView* imageView;
    IBOutlet UILabel *usernameLabel;
    IBOutlet UILabel* icebreakerLabel;
    IBOutlet SPStyledButton* likeButton;
    IBOutlet SPStyledButton* communicateButton;
    IBOutlet SPStyledButton* modeButton;
}
@property (assign) id<SPProfileViewDelegate> delegate;

-(id)initWithProfile:(SPProfile*)profile;
-(id)initWithIdentifier:(NSString*)identifier;

-(IBAction)message:(id)sender;
-(IBAction)like:(id)sender;
-(IBAction)more:(id)sender;
@end

