//
//  HelpOverlayViewController.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-08-14.
//
//

#import <UIKit/UIKit.h>

@class SPHelpOverlayViewController;

@protocol SPHelpOverlayViewControllerDelegate <NSObject>
-(void)helpOverlayDidDismiss:(SPHelpOverlayViewController*)overlayController;
@end

@interface SPHelpOverlayViewController : UIViewController
{
    @private
    HELP_OVERLAY_TYPE _type;
    IBOutlet UIImageView *overlayImageView;
}
@property (assign) id<SPHelpOverlayViewControllerDelegate> delegate;

-(id)initWithType:(HELP_OVERLAY_TYPE)type;
-(IBAction)dismiss:(id)sender;
@end
