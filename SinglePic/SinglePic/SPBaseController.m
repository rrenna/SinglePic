//
//  SPBaseController.m
//  SinglePic
//
//  Created by Ryan Renna on 11-12-08.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPBaseController.h"
#import "SPLocationManager.h"
#import "SPMessageManager.h"
#import "SPTabController.h"
#import "SPBrowseViewController.h"
#import "SPSubscriptionsManager.h"
#import "SPProfileViewController.h"
#import "SPComposeViewController.h"
#import "SPSettingsViewController.h"
#import "SPStyledButton.h"

// We used to validate location services on start-up, this has been eliminated to reduce the amount of system
// permission pop-ups a user has to accept before reaching the application
#define VALIDATE_LOCATION_SERVICES_ON_STARTUP NO

@interface SPBaseController()
{
    NSMutableArray* tabs;
    BASE_MODE baseMode_;
}
@property (retain) SPHelpOverlayViewController* helpOverlayController;
-(SPTabController*)createTab;
-(SPTabController*)createTabIsMoveable:(BOOL)moveable;
-(void)browseScreenProfileSelected;
-(void)updateExpiry;
-(void)updateAvatar;
-(void)updateNewMailAlert;
-(void)flashNewConnectionAlert;
-(void)validateReachability;
-(void)reachabilityValidated;
-(void)validateLocationServices;
-(void)locationServicesValidated;
-(void)validateUser;
-(void)navigationMode;
-(void)registrationMode;
-(void)displayLikesView;
-(void)displayProfileView;
-(void)displayMessagesView;
-(void)addContent:(UIView*)content;
@end

@implementation SPBaseController
@synthesize baseMode;
@synthesize helpOverlayController;//Private

#pragma mark - Dynamic properties
-(void)setBaseMode:(BASE_MODE)baseMode
{
    baseMode_ = baseMode;
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if(baseMode == BLANK_BASE_MODE)
    {
        backgroundImageView.image = [UIImage imageNamed:@"default-568h.png"];
        navigationView.hidden = YES;
        registrationNavigationView.hidden = YES;
    }
    else if(baseMode == REGISTRATION_BASE_MODE)
    {
        if(!registrationController)
        {
            registrationController = [[SPRegistrationViewController alloc] init];
        }
        if(userController)
        {
            userController = nil;
        }
        if(messagesController)
        {
            messagesController = nil;
        }

        [self addContent:registrationController.view];
        
        backgroundImageView.image = [UIImage imageNamed:@"BG-Linen-Red-Blend-568h.png"];
        navigationView.hidden = YES;
        registrationNavigationView.hidden = NO;
    }
    else
    {
        if(registrationController)
        {
            [registrationController.view removeFromSuperview];
            registrationController = nil;
        }
        if(!userController)
        {
            userController = [SPUserViewController new];
        }
        if(!messagesController)
        {
            messagesController = [SPMessagesViewController new];
        }
        if(!connectionsController)
        {
            connectionsController = [SPConnectionsViewController new];
        }
        
        [self displayProfileView]; //Default content
        
        backgroundImageView.image = [UIImage imageNamed:@"BG-Linen-Red-Blend-568h.png"];
        navigationView.hidden = NO;
        registrationNavigationView.hidden = YES;
        
        //Set the image expiry "mini" progress view in the navigation bar
        [self updateExpiry];
        [self updateAvatar];
        [self updateNewMailAlert];
        
        #define HELP_OVERLAY_BROWSE_DISPLAYED_KEY @"HELP_OVERLAY_BROWSE_DISPLAYED_KEY"
        if(![[NSUserDefaults standardUserDefaults] boolForKey:HELP_OVERLAY_BROWSE_DISPLAYED_KEY])
        {
            //Display First-Login Help
            [self displayHelpOverlay:HELP_OVERLAY_BROWSE];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HELP_OVERLAY_BROWSE_DISPLAYED_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}
-(BASE_MODE)baseMode
{
    return baseMode_;
}
#pragma mark - View lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        tabs = [NSMutableArray new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userTypeChangedWithNotification:) name:NOTIFICATION_MY_USER_TYPE_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(browseScreenProfileSelected) name:NOTIFICATION_BROWSE_SCREEN_PROFILE_SELECTED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateExpiry) name:NOTIFICATION_MY_EXPIRY_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAvatar) name:NOTIFICATION_MY_IMAGE_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateExpiry) name:UIApplicationDidBecomeActiveNotification object:nil];      
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAvatar) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flashNewConnectionAlert) name:NOTIFICATION_LIKE_ADDED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNewMailAlert) name:NOTIFICATION_NEW_MESSAGES_RECIEVED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNewMailAlert) name:NOTIFICATION_NEW_MESSAGES_READ object:nil];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [miniProgressView setStyle:STYLE_BASE];
    
    self.baseMode = BLANK_BASE_MODE;
    [self validateReachability];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - IBActions
-(IBAction)connections:(id)sender
{
    #if defined (BETA)
    [TestFlight passCheckpoint:@"Switched to LIKES screen"]; 
    #endif
    
    [Crashlytics setObjectValue:@"Switched to LIKES screen" forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    [self displayLikesView];
}
-(IBAction)profile:(id)sender
{
    #if defined (BETA)
    [TestFlight passCheckpoint:@"Switched to MY PROFILE screen"]; 
    #endif
    
    [Crashlytics setObjectValue:@"Switched to MY PROFILE screen" forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    [self displayProfileView];
}
-(IBAction)inbox:(id)sender
{
    #if defined (BETA)
    [TestFlight passCheckpoint:@"Switched to MESSAGES screen"]; 
    #endif
    
    [Crashlytics setObjectValue:@"Switched to MESSAGES screen" forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    [self displayMessagesView];
}
-(IBAction)registration:(id)sender
{
    [SPSoundHelper playTap];
    
    [self minimizeAllTabs];
}
-(IBAction)info:(id)sender
{
    #if defined (BETA)
    [TestFlight passCheckpoint:@"Opened INFO screen"];
    #endif
    
    [Crashlytics setObjectValue:@"Opened INFO screen" forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    SPSettingsViewController* settingsController = [SPSettingsViewController new];
    [self presentModalViewController:settingsController animated:YES];
}
#pragma mark - Content
-(void)pushModalController:(UIViewController*)viewController isFullscreen:(BOOL)fullscreen
{
    SPTabController* tab = [self createTabIsFullscreen:fullscreen];
    [tab setController:viewController];
}
-(void)pushModalContent:(UIView*)view
{
    SPTabController* tab = [self createTab];
    [tab setContent:view];
}
#pragma mark - Profile
-(void)pushProfile:(SPProfile*)profile
{
    SPTabController* tab = [tabs objectAtIndex:0];
    //Ensure the tab is maximized
    [tab maximize];
    //Close all existing page
    [tab closeAllPages];
    //Present a page containing the profile controller
    SPProfileViewController* profileController = [[SPProfileViewController alloc] initWithProfile:profile];
    [tab pushModalController:profileController];
}
-(void)pushProfileWithID:(NSString*)profileID
{
    SPTabController* tab = [tabs objectAtIndex:0];
    //Ensure the tab is maximized
    [tab maximize];
    //Close all existing page
    [tab closeAllPages];
    //Present a page containing the profile controller
    SPProfileViewController* profileController = [[SPProfileViewController alloc] initWithIdentifier:profileID];
    [tab pushModalController:profileController];
}
-(void)pushChatWithProfile:(SPProfile*)profile
{
    [self pushChatWithProfile:profile isFromBase:NO];
}
-(void)pushChatWithID:(NSString*)profileID
{
    [self pushChatWithID:profileID isFromBase:NO];
}
-(void)pushChatWithProfile:(SPProfile*)profile isFromBase:(BOOL)fromBase
{
    SPTabController* tab = [tabs objectAtIndex:0];
        //Ensure the tab is maximized
    [tab maximizeIsFullscreen:YES];
        //Close all existing page
    [tab closeAllPages];
        //Present a page containing the chat controller
    SPComposeViewController* chatScreenController = [[SPComposeViewController alloc] initWithProfile:profile];
    chatScreenController.minimizeContainerOnClose = fromBase;
    [tab pushModalController:chatScreenController];
}
-(void)pushChatWithID:(NSString*)profileID isFromBase:(BOOL)fromBase
{
    SPTabController* tab = [tabs objectAtIndex:0];
        //Ensure the tab is maximized
    [tab maximizeIsFullscreen:YES];
        //Close all existing page
    [tab closeAllPages];
        //Present a page containing the chat controller
    SPComposeViewController* chatScreenController = [[SPComposeViewController alloc] initWithIdentifier:profileID];
    chatScreenController.minimizeContainerOnClose = fromBase;
    [tab pushModalController:chatScreenController];
}
#pragma mark - Help
-(void)displayHelpOverlay:(HELP_OVERLAY_TYPE)type
{
    self.helpOverlayController = [[SPHelpOverlayViewController alloc] initWithType:type];
    helpOverlayController.delegate = self;
    [self.view.superview addSubview:helpOverlayController.view];
}
-(void)displayReachabilityOverlay
{
    
}
#pragma mark - Status bar customization
-(void)setStatusBarStyle:(STYLE)style
{
    //Animates changes to the status bar
    [UIView animateWithDuration:0.4 animations:^{
            navigationBar.tintColor = primaryColorForStyle(style);
    }];
}
#pragma mark - Private methods
-(void)addContent:(UIView*)content
{
    content.frame = contentView.bounds;
    [contentView addSubview:content];
}
-(SPTabController*)createTab
{
    return [self createTabIsFullscreen:NO];
}
-(void)navigationMode
{
    [activityView stopAnimating];
    self.baseMode = NAVIGATION_BASE_MODE;
    [self pushModalController: [SPBrowseViewController new] isFullscreen:NO];
}
-(void)registrationMode
{
    [activityView stopAnimating];
    self.baseMode = REGISTRATION_BASE_MODE;
    [self pushModalController: [SPBrowseViewController new] isFullscreen:NO];
}
-(void)displayLikesView
{
    [self minimizeAllTabs];
    
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addContent:connectionsController.view];
    
    profileButton.selected = NO;
    mailButton.selected = NO;
    connectionButton.selected = YES;
}
-(void)displayProfileView
{
    [self updateExpiry];
    
    [self minimizeAllTabs];
    
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addContent:userController.view];
    
    profileButton.selected = YES;
    mailButton.selected = NO;
    connectionButton.selected = NO;
}
-(void)displayMessagesView
{
    [self minimizeAllTabs];
    
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addContent:messagesController.view];
    
    profileButton.selected = NO;
    mailButton.selected = YES;
    connectionButton.selected = NO;
}
-(void)browseScreenProfileSelected
{
    if([[SPProfileManager sharedInstance] myUserType] == USER_TYPE_ANNONYMOUS)
    {
        //Selecting any profile while annonymous should:
        // 1) minimize the tab (and reveal the register/login screen)
        // 2) display the help overlay explaining that you must login/register
        [self minimizeAllTabs];
        [self displayHelpOverlay:HELP_OVERLAY_LOGIN_OR_REGISTER];
    }
}
-(void)updateExpiry
{
    //SECONDS_PER_DAY
    NSDate* expiryDate = [[SPProfileManager sharedInstance] myExpiry];
    float progress = MAX([TimeHelper progressOfDate:expiryDate toTimeInterval:(SECONDS_PER_DAY * [[SPSettingsManager sharedInstance] daysPicValid])], 0);
    
    if(!expiryDate)
    {
        miniProgressView.progress = 0.0;
    }
    else
    {
        miniProgressView.progress = progress;
    }
    
    [self updateAvatar];
}
-(void)updateAvatar
{
    if( ![[SPProfileManager sharedInstance] isImageExpired] )
    {
        miniAvatarImage.image = [[SPProfileManager sharedInstance] myImage];
        miniAvatarImage.layer.cornerRadius = 6.0f;
        miniAvatarImage.layer.borderColor = [UIColor colorWithWhite:0.1 alpha:0.55].CGColor;
        miniAvatarImage.layer.borderWidth = 1.0f;
        miniAvatarImage.layer.masksToBounds = YES;
    }
    else
    {
        UIImage* image = [UIImage imageNamed:@"Nav-Profile-OFF"];
        miniAvatarImage.image = image;
        miniAvatarImage.layer.borderWidth = 0.0f;
    }
}
-(void)updateNewMailAlert
{
    SPMessageManager* manager = [SPMessageManager sharedInstance];
    int unreadMessageCount = [manager unreadMessagesCount];
    
    if(unreadMessageCount > 0)
    {
        newMessageAlertImage.alpha = 1.0;
        newMessageCountLabel.alpha = 1.0;
    }
    else
    {
        [UIView animateWithDuration:1.0 animations:^{
            newMessageAlertImage.alpha = 0.0;
            newMessageCountLabel.alpha = 0.0;
        }];
    }
    
    newMessageCountLabel.text = [NSString stringWithFormat:@"%d",unreadMessageCount];
}
-(void)flashNewConnectionAlert
{
    newConnectionAlertImage.alpha = 1.0;
    [UIView animateWithDuration:1.0 animations:^{
        newConnectionAlertImage.alpha = 0.0;
    }];
}
-(void)userTypeChangedWithNotification:(NSNotification*)notification
{
    //Close all tabs - if going from a annonymous 'browse' to a registered 'browse' the content will be different
    [self closeAllTabs];
    
    if([[SPProfileManager sharedInstance] myUserType] == USER_TYPE_PROFILE)
    {
        [self navigationMode];
    }
    else
    {
        [self registrationMode];
    }
}
-(void)validateReachability
{
    //Validates the device can reach the internet
    [[SPRequestManager sharedInstance] EnableRealtimeReachabilityMonitoring];
    
    //Retrieve and validate settings from Server
    [[SPSettingsManager sharedInstance] validateAppWithCompletionHandler:^(BOOL needsUpdate, NSString *title, NSString *description) {
        
        if(needsUpdate)
        {
            UIAlertView* expiredAlert = [[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
            [expiredAlert show];
        }
    }];
    
    //We will ask to check network reachability and wait for a response.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityValidated) name:NOTIFICATION_REACHABILITY_REACHABLE object:nil];
}
-(void)reachabilityValidated
{
    //Remove observation of reachability permission notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_REACHABILITY_REACHABLE object:nil];
    
    if(VALIDATE_LOCATION_SERVICES_ON_STARTUP)
    {
        //Initiate the Location Manager, we want the popup for location services permission to appear with just a splash screen behind it.
        if([[SPLocationManager sharedInstance] locationAvaliable] && [[SPLocationManager sharedInstance] locationAuthorizationStatus] == kCLAuthorizationStatusNotDetermined)
        {
            [self validateLocationServices];
        }
        else
        {
            //If location services have been requested previously, proceed to the next step
            [self locationServicesValidated];
        }
    }
    else
    {
        [self validateUser];
    }
}
-(void)validateLocationServices
{
    //If location services are not avaliable, and we've yet to ask the user for permission, we will ask permission and wait for a response.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationServicesValidated) name:NOTIFICATION_LOCATION_PERMISSION_UPDATED object:nil];
        //Request permission to use iOS location services from the user, this will spawn a popup
    [[SPLocationManager sharedInstance] requestLocationPermission];
}
//Proceed to this step after location services have been validatd, this is to prevent the UI from loading before the Location Services popup
-(void)locationServicesValidated
{
    //Remove observation of location services permission notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LOCATION_PERMISSION_UPDATED object:nil];
    
    //After location services have been validated (the user has explicitly chosen yes/no), ask the locationManager to retrieve the location of the user (if possible)
    [[SPLocationManager sharedInstance] getLocation];
    
    [self validateUser];
}
-(void)validateUser
{
    if([[SPProfileManager sharedInstance] myUserType] == USER_TYPE_PROFILE)
    {
        [activityView startAnimating];
        [[SPProfileManager sharedInstance] validateUserWithCompletionHandler:^(id responseObject)
         {
                 //TODO: Re-Implement transaction retrieval. Removed to reduce (useless) load on server
             /*
              //Recieves iTunes store products
              [[SPSubscriptionsManager sharedInstance] retrieveITunesProducts];
              
              //Retrieve Valid Transactions
              [[SPSubscriptionsManager sharedInstance] getTransactionsWithCompletionHandler: nil andErrorHandler:nil];
              */
             
             //Retrieve messages from the user
             [[SPMessageManager sharedInstance] forceRefresh];
             
             [self navigationMode];
             
         } andErrorHandler:^
         {
             [self registrationMode];
         }];
    }
    else
    {
        [self registrationMode];
    }
}
#pragma mark - SPTabContainerDelegate methods
-(void)removeTab:(SPTabController*)tab
{
    [tab.view removeFromSuperview];
    [tabs removeObject:tab];
}
-(void)minimizeAllTabs
{
    for(SPTabController* tab in tabs)
    {
        [tab minimize];
    }
}
-(void)closeAllTabs
{
    for(SPTabController* tab in tabs)
    {
        [tab close];
    }
}
-(SPTabController*)createTabIsFullscreen:(BOOL)fullscreen
{
    SHEET_STATE state = (fullscreen) ? SHEET_STATE_FULLSCREEN : SHEET_STATE_MAXIMIZED;
    SPTabController* tab = [[SPTabController alloc] initWithState:state];
    tab.containerDelegate = self;
    
    //Resize the tab to be the height of the baseController (should be full screen)
    tab.view.height = self.view.height;
    [self.view addSubview:tab.view];
    [tabs addObject:tab];
    
    return tab;
}
-(void) replaceTab:(SPTabController*)tab withNewTabContaining:(id)replacement
{
    if([replacement isKindOfClass:[UIViewController class]])
    {
        [self pushModalController:replacement isFullscreen:NO];
    }
    else
    {
        [self pushModalContent:replacement];
    }
    
    [tab close];
}
#pragma mark - SPHelpOverlayViewControllerDelegate methods
-(void)helpOverlayDidDismiss:(SPHelpOverlayViewController*)overlayController
{
    [overlayController.view removeFromSuperview];
    self.helpOverlayController = nil;
}
@end

