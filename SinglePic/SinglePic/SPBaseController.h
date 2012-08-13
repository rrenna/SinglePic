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

@protocol SPReachabilityPopupDelegate;
@class SPStyledButton;

typedef enum
{
    BLANK_BASE_MODE,
    REGISTRATION_BASE_MODE,
    NAVIGATION_BASE_MODE
} BASE_MODE;

@interface SPBaseController : UIViewController <SPTabContainerDelegate,SPReachabilityPopupDelegate,UITextFieldDelegate>
{
    IBOutlet UIActivityIndicatorView* activityView;
    IBOutlet UIView* contentView;
    IBOutlet UIView* navigationView;
    IBOutlet UIImageView* backgroundImageView;
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
    IBOutlet SPStyledButton* registerButton;
    IBOutlet SPStyledButton* loginButton;
    SPRegistrationViewController* registrationController;
@private
    NSMutableArray* tabs;
    SPReachabilityPopupController* reachabilityController;
    BASE_MODE baseMode_;
}

@property (assign) BASE_MODE baseMode;

//IBActions
-(IBAction)connections:(id)sender;
-(IBAction)profile:(id)sender;
-(IBAction)inbox:(id)sender;
-(IBAction)registration:(id)sender;
-(IBAction)info:(id)sender;
//
-(void)logout;
//
-(void)pushModalController:(UIViewController*)viewController isFullscreen:(BOOL)fullscreen;
-(void)pushModalContent:(UIView*)view;
//
-(void)pushProfile:(SPProfile*)profile;
-(void)pushProfileWithID:(NSString*)profileID;
-(void)pushProfile:(SPProfile*)profile profileMode:(BOOL)isProfileMode;
-(void)pushProfileWithID:(NSString*)profileID profileMode:(BOOL)isProfileMode;
@end
