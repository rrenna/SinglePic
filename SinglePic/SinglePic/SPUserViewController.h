//
//  SPUserViewController.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPStyledProgressView.h"
#import "SPStyledView.h"
#import "SPStyledButton.h"
#import "SPStackPanel.h"

@interface SPUserViewController : UIViewController <UIImagePickerControllerDelegate>
{
    IBOutlet __weak SPLabel *titleLabel;
    IBOutlet __weak SPStyledView* insetView;
    IBOutlet __weak SPStyledProgressView* progressView;
    IBOutlet __weak SPStackPanel* userStackPanel;
    //User Profile
    IBOutlet __weak UIView* userProfileView;
    IBOutlet __weak UIImageView* avatarImageView;
    IBOutlet __weak UILabel *usernameLabel;
    IBOutlet __weak UILabel* icebreakerLabel;
    IBOutlet __weak SPStyledButton* retakePhotoButton;
    IBOutlet __weak SPStyledButton* editIcebreakerButton;
    //User Email
    IBOutlet __weak UIView* userEmailView;
    IBOutlet __weak UILabel *userEmailLabel;
    //User Subscription
    IBOutlet __weak UIView* userSubscriptionView;
}
-(IBAction)retakePic:(id)sender;
-(IBAction)editPic:(id)sender;
-(IBAction)revertPic:(id)sender;
-(IBAction)editIcebreaker:(id)sender;
-(IBAction)viewImageExpiryHelp:(id)sender;
@end
