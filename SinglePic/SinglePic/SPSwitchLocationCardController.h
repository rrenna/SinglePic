//
//  SPSwitchLocationCardController.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-08-11.
//
//

#import <UIKit/UIKit.h>
#import "SPLocationChooser.h"

@interface SPSwitchLocationCardController : UIViewController <SPLocationChooserDelegate>
{
    IBOutlet SPStyledButton* changeButton;
    IBOutlet UIImageView* locationIcon;
    IBOutlet UILabel* locationLabel;
    IBOutlet SPLocationChooser* locationChooser;
}

-(IBAction)open:(id)sender;
-(IBAction)change:(id)sender;
@end
