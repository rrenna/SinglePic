//
//  SPUserViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPUserViewController.h"
#import "AFFeatherController.h"
#import "SPIcebreakerComposeViewController.h"
#import "SPCameraController.h"
#import "SVProgressHUD.h"

@interface SPUserViewController()
@property (retain) SPCameraController* cameraController;
-(void)updateImage;
-(void)updateUsername;
-(void)updateIcebreaker;
-(void)updateExpiry;
@end

@implementation SPUserViewController
@synthesize cameraController;
#pragma mark - View lifecycle
-(id)init
{
    return [self initWithNibName:@"SPUserViewController" bundle:nil];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        orientationController = [SPSwitchOrientationCardController new];
        locationController = [SPSwitchLocationCardController new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImage) name:NOTIFICATION_MY_IMAGE_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUsername) name:NOTIFICATION_MY_USER_NAME_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateIcebreaker) name:NOTIFICATION_MY_ICEBREAKER_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateExpiry) name:NOTIFICATION_MY_EXPIRY_CHANGED object:nil];

    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateImage];
    [self updateUsername];
    [self updateIcebreaker];
    [self updateExpiry];
    
    [progressView setStyle:STYLE_BASE];
    [insetView setStyle:STYLE_BASE];
    [retakePhotoButton setStyle:STYLE_WHITE];
    
    [userStackPanel addStackedView:userProfileView];
    [userStackPanel addStackedView:orientationController.view];
    //TEMP: Removed bucket selection
    //[userStackPanel addStackedView:locationController.view];
    [userStackPanel addStackedView:userSubscriptionView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self updateExpiry];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MY_IMAGE_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MY_USER_NAME_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MY_ICEBREAKER_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MY_EXPIRY_CHANGED object:nil];
    [orientationController release];
    [locationController release];
    [cameraController release];
    [usernameLabel release];
    [super dealloc];
}
-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.cameraController = nil;
}
#pragma mark - IBActions
-(IBAction)retakePic:(id)sender
{
    /*
     if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
     {
     if(!self.cameraController)
     {
     self.cameraController = [[SPCameraController new] autorelease];
     
     }
     SPBaseController* baseController = [[UIApplication sharedApplication].delegate baseController];
     [baseController pushModalController:self.cameraController isFullscreen:YES];
     }
     else
     {
     //This is an iPad 1, an iPod, or the iOS simulator
     [[SPProfileManager sharedInstance] saveMyPicture:[UIImage imageNamed:DEFAULT_PORTRAIT_IMAGE] withCompletionHandler:^(id responseObject) 
     {
     
     } 
     andErrorHandler:^
     {
     }]; 
     }
    */
    if(!self.cameraController)
    {
        self.cameraController = [[SPCameraController new] autorelease];
    }
    
    SPBaseController* baseController = [[UIApplication sharedApplication].delegate baseController];
    [baseController pushModalController:self.cameraController isFullscreen:YES];
}
-(IBAction)editPic:(id)sender
{
    UIImage* imageToEdit = avatarImageView.image;
    
    AFFeatherController *featherController = [[[AFFeatherController alloc] initWithImage:imageToEdit] autorelease];
    featherController.topBar.tintColor = [UIColor colorWithWhite:0.75 alpha:1.0];
    featherController.bottomBar.tintColor = [UIColor darkGrayColor];
    [featherController setDelegate:self];
    [self presentModalViewController:featherController animated:YES];
}
-(IBAction)revertPic:(id)sender
{
    /*
    [SVProgressHUD showWithStatus:@"Undoing" maskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    
    BOOL valid = [[SPProfileManager sharedInstance] undoMyImageWithCompletionHandler:^(id responseObject) 
                  {
                      [SVProgressHUD dismissWithSuccess:@"Undone"];
                  } 
                                                                     andErrorHandler:^
                  {
                      [SVProgressHUD dismissWithError:@"Woops! Couldn't undo. Try again."];
                  }];
    
    if(!valid)
    {
        [SVProgressHUD dismissWithError:@"Nothing to undo."];
    }
     */
}
-(IBAction)editIcebreaker:(id)sender
{
    SPIcebreakerComposeViewController* icebreakerComposeController = [SPIcebreakerComposeViewController new];
    
    SPBaseController* baseController = [[UIApplication sharedApplication].delegate baseController];
    [baseController pushModalController:icebreakerComposeController isFullscreen:YES];
    [icebreakerComposeController release];
}

-(IBAction)viewImageExpiryHelp:(id)sender
{
    SPBaseController* baseController = [[UIApplication sharedApplication].delegate baseController];
    [baseController displayHelpOverlay:HELP_OVERLAY_IMAGE_EXPIRY];
}
#pragma mark - Private methods
-(void)updateImage
{
    UIImage* avatar = [[SPProfileManager sharedInstance] myImage];
    avatarImageView.image = avatar;
}
-(void)updateUsername
{
    usernameLabel.text = [[SPProfileManager sharedInstance] myUserName];
}
-(void)updateIcebreaker
{
    icebreakerLabel.text = [[SPProfileManager sharedInstance] myIcebreaker];
}
-(void)updateExpiry
{
    //SECONDS_PER_DAY
    NSDate* expiryDate = [[SPProfileManager sharedInstance] myExpiry];
    float progress = MAX([TimeHelper progressOfDate:expiryDate toTimeInterval:(SECONDS_PER_DAY * [[SPSettingsManager sharedInstance] daysPicValid])], 0);
    
    if(!expiryDate)
    {
        progressView.progress = 0.0;
        progressView.progressStatus = @"Upload your first image! :)";
    }
    else
    {
        progressView.progress = progress;
        //Generate status
        //If the picture is expired
        if(progress <= 0.0)
        {
            progressView.progressStatus = @"Upload a new Pic! :)";
        }
        //If the picture is not expired
        else 
        {
            NSString* progressString = [TimeHelper countdownUntilDate:expiryDate];
            progressView.progressStatus = [NSString stringWithFormat:@"%@ left",progressString];
        }
    }
}
@end
