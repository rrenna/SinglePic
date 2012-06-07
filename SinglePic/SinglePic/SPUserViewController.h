//
//  SPUserViewController.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPStyledProgressView.h"
#import "SPSwitchOrientationCardController.h"
#import "SPStyledView.h"
#import "SPStyledButton.h"
#import "SPStackPanel.h"

@interface SPUserViewController : UIViewController <UIImagePickerControllerDelegate>
{
    IBOutlet SPStyledView* insetView;
    IBOutlet SPStyledProgressView* progressView;
    IBOutlet SPStackPanel* userStackPanel;
    //User Profile
    IBOutlet UIView* userProfileView;
    IBOutlet UIImageView* avatarImageView;
    IBOutlet UILabel* icebreakerLabel;
    IBOutlet SPStyledButton* retakePhotoButton;
    IBOutlet SPStyledButton* editIcebreakerButton;
    //User Orientation
    SPSwitchOrientationCardController* orientationController;
    //User Location
    IBOutlet UIView* userLocationView;
    //User Subscription
    IBOutlet UIView* userSubscriptionView;
}
-(IBAction)retakePic:(id)sender;
-(IBAction)editPic:(id)sender;
-(IBAction)revertPic:(id)sender;
-(IBAction)editIcebreaker:(id)sender;
@end
