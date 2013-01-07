//
//  SPSwitchOrientationController.h
//  SinglePic
//
//  Created by Ryan Renna on 12-02-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPStyledButton.h"
#import "SPOrientationChooser.h"

@interface SPSwitchOrientationCardController : UIViewController <SPOrientationChooserDelegate>
{
    IBOutlet UIImageView* orientationIcon;
    IBOutlet UILabel* orientationLabel;
}

-(IBAction)open:(id)sender;
-(IBAction)change:(id)sender;
@end
