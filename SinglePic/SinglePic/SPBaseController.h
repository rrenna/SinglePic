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

@protocol SPReachabilityPopupDelegate;
@class SPStyledButton;

typedef enum
{
    BLANK_BASE_MODE,
    REGISTRATION_BASE_MODE,
    NAVIGATION_BASE_MODE
} BASE_MODE;

@interface SPBaseController : UIViewController <SPTabContainerDelegate,SPReachabilityPopupDelegate,UITextFieldDelegate,SPHelpOverlayViewControllerDelegate>
{
    IBOutlet UIActivityIndicatorView* activityView;
    IBOutlet UIView* contentView;
    IBOutlet UIView* navigationView;
    IBOutlet UIImageView* backgroundImageView;
    IBOutlet UINavigationBar *navigationBar;
    __weak IBOutlet UIImageView *newConnectionAlertImage;
    __weak IBOutlet UIImageView *newMessageAlertImage;
    __weak IBOutlet UILabel *newMessageCountLabel;
    IBOutlet UIImageView *miniAvatarImage;
    IBOutlet SPStyledProgressView *miniProgressView;
    //Navigation
    IBOutlet UIButton* connectionButton;
    IBOutlet UIButton* profileButton;
    IBOutlet UIButton* mailButton;
    //Profile
    SPUserViewController* userController;
    SPMessagesViewController* messagesController;
    SPConnectionsViewController* connectionsController;
    //Register
    IBOutlet UIView* registrationNavigationView;
    SPRegistrationViewController* registrationController;
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
