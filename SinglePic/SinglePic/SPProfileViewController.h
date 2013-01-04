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
    IBOutlet __weak UILabel* ageLabel;
    IBOutlet __weak UIImageView* imageView;
    IBOutlet __weak UILabel *usernameLabel;
    IBOutlet __weak UILabel* icebreakerLabel;
    IBOutlet __weak SPStyledButton* likeButton;
    IBOutlet __weak SPStyledButton* communicateButton;
    IBOutlet __weak SPStyledButton* modeButton;
}
@property (assign) id<SPProfileViewDelegate> delegate;

-(id)initWithProfile:(SPProfile*)profile;
-(id)initWithIdentifier:(NSString*)identifier;

-(IBAction)message:(id)sender;
-(IBAction)like:(id)sender;
-(IBAction)more:(id)sender;
@end

