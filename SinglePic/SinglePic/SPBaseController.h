//
//  SPBaseController.h
//  SinglePic
//
//  Created by Ryan Renna on 11-12-08.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPTabContainerDelegate.h"
#import "SPRegistrationViewController.h"
#import "SPUserViewController.h"
#import "SPMessagesViewController.h"
#import "SPConnectionsViewController.h"
#import "SPReachabilityPopupController.h"
#import "SPHelpOverlayViewController.h"

@class SPStyledButton;

typedef enum
{
    BLANK_BASE_MODE,
    REGISTRATION_BASE_MODE,
    NAVIGATION_BASE_MODE
} BASE_MODE;

@interface SPBaseController : UIViewController <SPTabContainerDelegate,UITextFieldDelegate,SPHelpOverlayViewControllerDelegate>
{
    IBOutlet __weak UIActivityIndicatorView* activityView;
    IBOutlet __weak UIView* contentView;
    IBOutlet __weak UIView* navigationView;
    IBOutlet __weak UIImageView* backgroundImageView;
    IBOutlet __weak UINavigationBar *navigationBar;
    IBOutlet __weak UIImageView *newConnectionAlertImage;
    IBOutlet __weak UIImageView *newMessageAlertImage;
    IBOutlet __weak UILabel *newMessageCountLabel;
    IBOutlet __weak UIImageView *miniAvatarImage;
    IBOutlet __weak SPStyledProgressView *miniProgressView;
    IBOutlet __weak UIView* registrationNavigationView;
    //Navigation
    IBOutlet __weak UIButton* connectionButton;
    IBOutlet __weak UIButton* profileButton;
    IBOutlet __weak UIButton* mailButton;
}

@property (assign) BASE_MODE baseMode;

//IBActions
-(IBAction)connections:(id)sender;
-(IBAction)profile:(id)sender;
-(IBAction)inbox:(id)sender;
-(IBAction)registration:(id)sender;
-(IBAction)info:(id)sender;
// Content
-(void)pushModalController:(UIViewController*)viewController isFullscreen:(BOOL)fullscreen;
-(void)pushModalContent:(UIView*)view;
// Profiles
-(void)pushProfile:(SPProfile*)profile;
-(void)pushProfileWithID:(NSString*)profileID;
-(void)pushChatWithProfile:(SPProfile*)profile;
-(void)pushChatWithID:(NSString*)profileID;
-(void)pushChatWithProfile:(SPProfile*)profile isFromBase:(BOOL)fromBase;
-(void)pushChatWithID:(NSString*)profileID isFromBase:(BOOL)fromBase;
// Help
-(void)displayHelpOverlay:(HELP_OVERLAY_TYPE)type;
-(void)displayReachabilityOverlay;
//Status bar customization
-(void)setStatusBarStyle:(STYLE)style;
@end
