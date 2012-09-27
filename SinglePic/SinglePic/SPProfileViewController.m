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
-(void)profileLoaded;
@end

@implementation SPProfileViewController
@synthesize delegate;
@synthesize profile,avatar;//Private

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
    [bottomBarView setStyle:STYLE_PAGE];
    [bottomBarView setDepth:DEPTH_OUTSET];

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
    [super dealloc];
}
#pragma mark - IBActions
-(IBAction)message:(id)sender
{
    SPComposeViewController* composeController = [[[SPComposeViewController alloc] initWithProfile:self.profile] autorelease];
    
    [self setFullscreen:YES];
    [self pushModalController:composeController];
}
-(IBAction)like:(id)sender
{
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
            [[SPProfileManager sharedInstance] removeProfile:profile fromLikesWithCompletionHandler:^()
             {
                 likeButton.enabled = YES;
             }
             andErrorHandler:^
             {
                 likeButton.enabled = YES;
             }];
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
#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [actionSheet cancelButtonIndex])
    {
        // Do nothing
    }
    else if(buttonIndex == [actionSheet destructiveButtonIndex])
    {
        //Block User
        [[SPProfileManager sharedInstance] blockProfile:self.profile withCompletionHandler:^{
           
            [self close];
            
        } andErrorHandler:^{
            
            
        }];
    }
    else
    {
        //
    }
}
@end
