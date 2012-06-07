//
//  SPSwitchOrientationController.h
//  SinglePic
//
//  Created by Ryan Renna on 12-02-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPStyledButton.h"

@class SPOrientationChooser;

@protocol SPOrientationChooserDelegate;

@interface SPSwitchOrientationCardController : UIViewController <SPOrientationChooserDelegate>
{
    IBOutlet SPStyledButton* changeButton;
    IBOutlet UIImageView* orientationIcon;
    IBOutlet UILabel* orientationLabel;
@private
    SPOrientationChooser* orientationChooser;
}

-(IBAction)open:(id)sender;
-(IBAction)change:(id)sender;
@end
