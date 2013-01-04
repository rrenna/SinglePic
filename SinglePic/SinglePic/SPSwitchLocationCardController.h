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
    IBOutlet __weak UIImageView* locationIcon;
    IBOutlet __weak UILabel* locationLabel;
}

-(IBAction)open:(id)sender;
@end
