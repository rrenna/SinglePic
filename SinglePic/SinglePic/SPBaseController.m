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
#import "SPReachabilityPopupController.h"
#import "SPSubscriptionsManager.h"
#import "SPProfileViewController.h"
#import "SPComposeViewController.h"
#import "MDAboutController.h"
#import "MDACListCredit.h"
#import "MDACCreditItem.h"
#import "SPAboutStyle.h"
#import "SPStyledButton.h"

@interface SPBaseController()
-(SPTabController*)createTab;
-(SPTabController*)createTabIsMoveable:(BOOL)moveable;
-(void)browseScreenProfileSelected;
-(void)updateExpiry;
-(void)updateAvatar;
-(void)validateReachability;
-(void)locationServicesValidated;
-(void)navigationMode;
-(void)registrationMode;
@end

@implementation SPBaseController
@synthesize baseMode;
#pragma mark - Dynamic properties
-(void)setBaseMode:(BASE_MODE)baseMode
{
    baseMode_ = baseMode;
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if(baseMode == BLANK_BASE_MODE)
    {
        backgroundImageView.image = [UIImage imageNamed:@"default"];
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
            [userController release];
            userController = nil;
        }
        if(messagesController)
        {
            [messagesController release];
            messagesController = nil;
        }
        
        [contentView addSubview:registrationController.view];
        
        backgroundImageView.image = [UIImage imageNamed:@"BG-Linen-Red-Blend"];
        navigationView.hidden = YES;
        registrationNavigationView.hidden = NO;
        
        [registerButton setStyle:STYLE_BASE];
        [loginButton setStyle:STYLE_BASE];
        //Registration & Login buttons require's a transformation on it's title label, we purform this only when the app has swtiched to the registration mode
        
        UILabel* registrationLabel = [[UILabel alloc] initWithFrame:registerButton.bounds];
        registrationLabel.backgroundColor = [UIColor clearColor];
        registrationLabel.textAlignment = UITextAlignmentCenter;
        registrationLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1];
        registrationLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
        registrationLabel.shadowOffset = CGSizeMake(-1,0);
        
        registrationLabel.text = @"Sign up / Login";
        [registerButton addSubview:registrationLabel];        
        
        registrationLabel.transform = CGAffineTransformMakeRotation(M_PI/ 2);
        registrationLabel.bounds = CGRectMake(0, 0, registrationLabel.bounds.size.height, registrationLabel.bounds.size.width);
        
        [registrationLabel release];
    }
    else
    {
        if(registrationController)
        {
            [registrationController.view removeFromSuperview];
            [registrationController release];
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
        
        [self profile:profileButton];
        
        backgroundImageView.image = [UIImage imageNamed:@"BG-Linen-Red-Blend"];
        navigationView.hidden = NO;
        registrationNavigationView.hidden = YES;
        
        //Set the image expiry "mini" progress view in the navigation bar
        [self updateExpiry];
        [self updateAvatar];
        
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
        reachabilityController = [[SPReachabilityPopupController alloc] initWithDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userTypeChangedWithNotification:) name:NOTIFICATION_MY_USER_TYPE_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(browseScreenProfileSelected) name:NOTIFICATION_BROWSE_SCREEN_PROFILE_SELECTED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateExpiry) name:NOTIFICATION_MY_EXPIRY_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAvatar) name:NOTIFICATION_MY_IMAGE_CHANGED object:nil];
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
    [tabs release];
    [registrationController release];
    [userController release];
    [reachabilityController release]; 
    [navigationBar release];
    [miniProgressView release];
    [miniAvatarImage release];
    [super dealloc];
}
#pragma mark - IBActions
-(IBAction)connections:(id)sender
{
    #if defined (TESTING)
    [TestFlight passCheckpoint:@"Switched to LIKES screen"]; 
    #endif
    
    [self minimizeAllTabs];
    
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [contentView addSubview:connectionsController.view];
    
    profileButton.selected = NO;
    mailButton.selected = NO;
    connectionButton.selected = YES;
}
-(IBAction)profile:(id)sender
{
    #if defined (TESTING)
    [TestFlight passCheckpoint:@"Switched to MY PROFILE screen"]; 
    #endif
    
    [self updateExpiry];
    
    [self minimizeAllTabs];
    
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [contentView addSubview:userController.view];
    
    profileButton.selected = YES;
    mailButton.selected = NO;
    connectionButton.selected = NO;
}
-(IBAction)inbox:(id)sender
{
    #if defined (TESTING)
    [TestFlight passCheckpoint:@"Switched to MESSAGES screen"]; 
    #endif
    
    [self minimizeAllTabs];
    
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [contentView addSubview:messagesController.view];
    
    profileButton.selected = NO;
    mailButton.selected = YES;
    connectionButton.selected = NO;
}
-(IBAction)registration:(id)sender
{
    [self minimizeAllTabs];
}
-(IBAction)info:(id)sender
{
    MDAboutController* aboutController = [[[MDAboutController alloc] initWithStyle: [SPAboutStyle style]] autorelease];
    //Remove MDAboutController credit (We cite them in our own way)
    [aboutController removeLastCredit];
    
    //Add App setting specific credits (interactive)
    //If logged-in - display a logout button
    if([[SPProfileManager sharedInstance] myUserType] != USER_TYPE_ANNONYMOUS)
    {
        MDACListCredit* appOptionsListCredit = [MDACListCredit listCreditWithTitle:@""];
        MDACCreditItem* logoutCreditItem = [MDACCreditItem itemWithName:@"Logout" role:@"" linkString:@"selector:logout"];
        [appOptionsListCredit addItem:logoutCreditItem];
        [aboutController insertCredit:appOptionsListCredit  atIndex:1];
    }
    
    [self presentModalViewController:aboutController animated:YES];
}
#pragma mark - Session
-(void)logout
{
    [[SPProfileManager sharedInstance] logout];
    [self dismissModalViewControllerAnimated:YES];
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
    SPProfileViewController* profileController = [[[SPProfileViewController alloc] initWithProfile:profile] autorelease];
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
    SPProfileViewController* profileController = [[[SPProfileViewController alloc] initWithIdentifier:profileID] autorelease];
    [tab pushModalController:profileController];
}
-(void)pushChatWithProfile:(SPProfile*)profile
{
    SPTabController* tab = [tabs objectAtIndex:0];
        //Ensure the tab is maximized
    [tab maximizeIsFullscreen:YES];
        //Close all existing page
    [tab closeAllPages];
        //Present a page containing the chat controller
    SPComposeViewController* profileController = [[[SPComposeViewController alloc] initWithProfile:profile] autorelease];
    [tab pushModalController:profileController];
}
-(void)pushChatWithID:(NSString*)profileID
{
    SPTabController* tab = [tabs objectAtIndex:0];
    //Ensure the tab is maximized
    [tab maximizeIsFullscreen:YES];
        //Close all existing page
    [tab closeAllPages];
    //Present a page containing the chat controller
    SPComposeViewController* profileController = [[[SPComposeViewController alloc] initWithIdentifier:profileID] autorelease];
    [tab pushModalController:profileController];
    [tab setFullscreen:YES];
}
#pragma mark - Help
-(void)displayHelpOverlay:(HELP_OVERLAY_TYPE)type
{
    SPHelpOverlayViewController* helpOverlayController = [[SPHelpOverlayViewController alloc] initWithType:type];
    helpOverlayController.delegate = self;
    [self.view.superview addSubview:helpOverlayController.view];
}
#pragma mark - Status bar customization
-(void)setStatusBarStyle:(STYLE)style
{
    navigationBar.tintColor = primaryColorForStyle(style);
}
#pragma mark - Private methods
-(SPTabController*)createTab
{
    return [self createTabIsFullscreen:NO];
}
-(void)navigationMode
{
    [activityView stopAnimating];
    self.baseMode = NAVIGATION_BASE_MODE;
    [self pushModalController: [[SPBrowseViewController new] autorelease] isFullscreen:NO];
}
-(void)registrationMode
{
    [activityView stopAnimating];
    self.baseMode = REGISTRATION_BASE_MODE;
    [self pushModalController: [[SPBrowseViewController new] autorelease] isFullscreen:NO];
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
    float progress = MAX([TimeHelper progressOfDate:expiryDate toTimeInterval:(SECONDS_PER_DAY * EXPIRY_DAYS)], 0);
    
    if(!expiryDate)
    {
        miniProgressView.progress = 0.0;
    }
    else
    {
        miniProgressView.progress = progress;
    }
}
-(void)updateAvatar
{
    if( ![[SPProfileManager sharedInstance] isImageExpired] )
    {
        miniAvatarImage.image = [[SPProfileManager sharedInstance] myImage];
        miniAvatarImage.layer.cornerRadius = 6.0f;
        miniAvatarImage.layer.borderColor = [UIColor darkGrayColor].CGColor;
        miniAvatarImage.layer.borderWidth = 1.0f;
        miniAvatarImage.layer.masksToBounds = YES;
    }
    else
    {
        miniAvatarImage.image = nil;
    }
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
    [reachabilityController show];
}
//Proceed to this step after location services have been validatd, this is to prevent the UI from loading before the Location Services popup
-(void)locationServicesValidated
{
    //Remove observation of location services permission notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LOCATION_PERMISSION_UPDATED object:nil];
    
    //After location services have been validated (the user has explicitly chosen yes/no), ask the locationManager to retrieve the location of the user (if possible)
    [[SPLocationManager sharedInstance] getLocation];
    
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
    SPTabController* tab = [[[SPTabController alloc] initIsFullscreen:fullscreen] autorelease];
    tab.containerDelegate = self;
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
#pragma mark - SPReachabilityView delegate methods
-(void)reachabilityConfirmedForHostName:(NSString*)hostName
{
    //Initiate the Location Manager, we want the popup for location services permission to appear with just a splash screen behind it.
    if([[SPLocationManager sharedInstance] locationAvaliable] && [[SPLocationManager sharedInstance] locationAuthorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        //If location services are not avaliable, and we've yet to ask the user for permission, we will ask permission and wait for a response.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationServicesValidated) name:NOTIFICATION_LOCATION_PERMISSION_UPDATED object:nil];
        //Request permission to use iOS location services from the user, this will spawn a popup
        [[SPLocationManager sharedInstance] requestLocationPermission];
    }
    else
    {
        //If location services have been requested previously, proceed to the next step
        [self locationServicesValidated];
    }
}
#pragma mark - SPHelpOverlayViewControllerDelegate methods
-(void)helpOverlayDidDismiss:(SPHelpOverlayViewController*)overlayController
{
    [overlayController.view removeFromSuperview];
    [overlayController release];
}
- (void)viewDidUnload {
    [miniProgressView release];
    miniProgressView = nil;
    [miniAvatarImage release];
    miniAvatarImage = nil;
    [super viewDidUnload];
}
@end
