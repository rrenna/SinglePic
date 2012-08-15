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
@property (assign) id<SPHelpOverlayViewControllerDelegate> delegate;

-(IBAction)dismiss:(id)sender;
@end
