//
//  PMAProfileViewController.m
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-06.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SPComposeViewController.h"
#import "SPProfile.h"
#import "SPMessage.h"
#import "SPStyledView.h"
#import "SPStyledButton.h"
#import "SPCardView.h"
#import "SPMessageView.h"

@interface SPProfileViewController()
@property (retain) SPProfile* profile;
@property (retain) UIImage* avatar;
@property (retain) UIAlertView* unlikeUserAlertView;
@property (retain) UIAlertView* blockUserAlertView;
-(void)profileLoaded;
@end

@implementation SPProfileViewController
@synthesize delegate;
@synthesize profile,avatar,unlikeUserAlertView,blockUserAlertView;//Private

#pragma mark - View lifecycle
-(id)initWithProfile:(SPProfile*)profile_
{
     self = [self init];
    if(self)
    {
        self.profile = profile_;
    }
    return self;
}
-(id)initWithIdentifier:(NSString*)identifier
{
    self = [self init];
    if(self)
    {
        
        [[SPProfileManager sharedInstance] retrieveProfile:identifier withCompletionHandler:^
        (SPProfile *profile) 
        {
            self.profile = profile;
            [self profileLoaded];
            
        } andErrorHandler:^
        {
            
        }];
    }
    return self;
}
-(id)init
{
    self = [self initWithNibName:@"SPProfileViewController" bundle:nil];
    if(self)
    {
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //Set Look and Feel
    [communicateButton setStyle:STYLE_CONFIRM_BUTTON];
    [likeButton setStyle:STYLE_ALTERNATIVE_ACTION_1_BUTTON];

    if([[SPProfileManager sharedInstance] myUserType] == USER_TYPE_ANNONYMOUS)
    {
        communicateButton.hidden = YES;
    }
    
    if(profile) { [self profileLoaded]; }
}
-(void)dealloc
{
    [profile release];
    [avatar release];
    [usernameLabel release];
    self.unlikeUserAlertView = nil;
    self.blockUserAlertView = nil;
    [super dealloc];
}
#pragma mark - IBActions
-(IBAction)message:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on 'message' button in a Profile screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    SPComposeViewController* composeController = [[[SPComposeViewController alloc] initWithProfile:self.profile] autorelease];
    
    [self setFullscreen:YES];
    [self pushModalController:composeController];
}
-(IBAction)like:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on 'like' button in a Profile screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];

    //Disable button until action is completed
    likeButton.enabled = NO;
    
    if([[SPProfileManager sharedInstance] myUserType] == USER_TYPE_ANNONYMOUS)
    {
        [[SPErrorManager sharedInstance] alertWithTitle:@"Not yet..." Description:@"You'll have to register to like a profile."];
    }
    else
    {
        if([[SPProfileManager sharedInstance] checkIsLiked:profile])
        {
            NSString* title = [NSString stringWithFormat:@"Unlike %@?",profile.username];
            self.unlikeUserAlertView = [[[UIAlertView alloc] initWithTitle:title message:@"Are you sure you would like to unlike this person?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] autorelease];
            [self.unlikeUserAlertView show];
        }
        else
        {
            [[SPProfileManager sharedInstance] addProfile:profile toToLikesWithCompletionHandler:^()
             {
                 likeButton.enabled = YES;
             }
                                          andErrorHandler:^
             {
                 likeButton.enabled = YES;
             }];
        }
    }
}
-(IBAction)more:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on 'more' button in a Profile screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    UIActionSheet* profileMoreActionsSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Block User" otherButtonTitles: nil];
    [profileMoreActionsSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [profileMoreActionsSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [profileMoreActionsSheet release];
}
#pragma mark - Private methods
//Do not enable any interaction with this user until it's profile has been loaded
-(void)profileLoaded
{
    //Enable communication
    communicateButton.enabled = YES;
    
    //Fill in profile details
    usernameLabel.text = [profile username];
    icebreakerLabel.text = [profile icebreaker];
    
    //Set image age
    ageLabel.text = [NSString stringWithFormat:@"%@ old",[TimeHelper ageOfDate:[profile timestamp]]];
            
    [[SPProfileManager sharedInstance] retrieveProfileThumbnail:profile withCompletionHandler:^(UIImage *thumbnail)
    {
         //The Profile object should have a cached UIImage thumbnail at this point, but if not, it'll request it. If the request takes longer than the request for the fullsize image, the thumbnail could override the fullsize image permanently. For this reason we check that the imageView has not already had it's image set.
         if(!imageView.image)
         {
             imageView.image = thumbnail;
         }
    }
    andErrorHandler:nil];
    
    [[SPProfileManager sharedInstance] retrieveProfileImage:profile withCompletionHandler:^(UIImage *image)
     {
         imageView.image = image;
     }
     andErrorHandler:nil];
}
#pragma mark - UIAlertViewDelegate methods
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == self.unlikeUserAlertView)
    {
        if(buttonIndex == 0)
        {
            [Crashlytics setObjectValue:@"Clicked on the 'No' button in the 'Unlike <username>' alert." forKey:@"last_UI_action"];
            
            likeButton.enabled = YES;
        }
        else
        {
            [Crashlytics setObjectValue:@"Clicked on the 'Yes' button in the 'Unlike <username>' alert." forKey:@"last_UI_action"];
            
            [[SPProfileManager sharedInstance] removeProfile:profile fromLikesWithCompletionHandler:^()
             {
                 likeButton.enabled = YES;
             }
             andErrorHandler:^
             {
                 likeButton.enabled = YES;
             }];
        }
    }
    else if(alertView == self.blockUserAlertView)
    {
        if(buttonIndex > 0)
        {
            [Crashlytics setObjectValue:@"Clicked on the 'Yes' button in the 'Block <username>' alert." forKey:@"last_UI_action"];
            
            //Block User
            [[SPProfileManager sharedInstance] blockProfile:self.profile withCompletionHandler:^{
                
                [self close];
                
            } andErrorHandler:^{ 
            }];
        }
    }
}
#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [actionSheet cancelButtonIndex])
    {
        [Crashlytics setObjectValue:@"Clicked on the 'cancel' button in the 'more' action sheet." forKey:@"last_UI_action"];
        
        // Do nothing
    }
    else if(buttonIndex == [actionSheet destructiveButtonIndex])
    {
        [Crashlytics setObjectValue:@"Clicked on the 'block' button in the 'more' action sheet." forKey:@"last_UI_action"];
        
        NSString* title = [NSString stringWithFormat:@"Block %@?",profile.username];
        self.blockUserAlertView = [[[UIAlertView alloc] initWithTitle:title message:@"Are you sure you would like to block this person?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] autorelease];
        [self.blockUserAlertView show];
    }
    else
    {
        //
    }
}
@end
