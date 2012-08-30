//
//  PMAProfileViewController.m
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-06.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SPMessageManager.h"
#import "SPErrorManager.h"
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
    [profileContentView setStyle:STYLE_WHITE];
    [profileContentView setDepth:DEPTH_OUTSET];
    
    [communicateButton setStyle:STYLE_CONFIRM_BUTTON];
    [likeButton setStyle:STYLE_ALTERNATIVE_ACTION_1_BUTTON];
    [bottomBarView setStyle:STYLE_PAGE];
    [bottomBarView setDepth:DEPTH_OUTSET];
        
    [imageBackgroundStyledView setBorderWidth:5.0 shadowDepth:5.0 controlPointXOffset:0.0 controlPointYOffset:0.0];

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
        #if defined (TESTING)
        [TestFlight passCheckpoint:@"Liked a User"];
        #endif
        
        [[SPProfileManager sharedInstance] addProfile:profile toToLikesWithCompletionHandler:^() 
         {
         } 
         andErrorHandler:^
         {
             //If the 'like' command didn't complete - re-enable the 'like' button
             likeButton.enabled = YES;
         }];
    }
}
-(IBAction)expandChat:(id)sender
{
    #define SCROLLVIEW_MAX_INSET 215
    #define SCROLLVIEW_MIN_INSET 0
    static CGRect cardMaximizedRect = {54,6,245,260};
    static CGRect cardMinimizedRect = {53,5,244,84};
    static CGRect imageMaximizedRect = {59, 39, 235, 222};
    static CGRect imageMinimizedRect = {62, 14, 68, 68};
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationBeginsFromCurrentState:YES];

    UIEdgeInsets inset = historyTable.scrollIndicatorInsets;
    CGPoint offfset = historyTable.contentOffset;
    
 
    inset.top = SCROLLVIEW_MIN_INSET;
    
    imageView.frame = imageMinimizedRect;
    imageBackgroundStyledView.hidden = YES;
    profileContentView.frame = cardMinimizedRect;
    
    historyTable.contentInset = inset;
    historyTable.scrollIndicatorInsets = inset;
    historyTable.alpha = 1.0;
    icebreakerLabel.alpha = 0.0;
    bubbleImage.alpha = 0.0;
    messageTipLabel.alpha = 1.0;
    profileContentView.alpha = 1.0;
    
    [modeButton setTitle:@"Profile" forState:UIControlStateNormal];
 
    [UIView commitAnimations];
}
#pragma mark - Private methods
//Do not enable any interaction with this user until it's profile has been loaded
-(void)profileLoaded
{
    //Disable the like button if already liked
    likeButton.enabled = ![[SPProfileManager sharedInstance] checkIsLiked:profile];
    //Enable communication
    communicateButton.enabled = YES;
    
    //Fill in profile details
    icebreakerLabel.text = [profile icebreaker];
    
    //Set image age
    ageLabel.text = [NSString stringWithFormat:@"%@ old",[TimeHelper ageOfDate:[profile timestamp]]];
            
    NSURL* url = [profile pictureURL];
    [profile retrieveThumbnailWithCompletionHandler:^(UIImage *thumbnail) 
     {
         //The Profile object should have a cached UIImage thumbnail at this point, but if not, it'll request it. If the request takes longer than the request for the fullsize image, the thumbnail could override the fullsize image permanently. For this reason we check that the imageView has not already had it's image set.
         if(!imageView.image)
         {
             imageView.image = thumbnail;
         }
     } 
     andErrorHandler:^
     {
         
     }];
    
    [[SPRequestManager sharedInstance] getImageFromURL:url withCompletionHandler:^(UIImage* responseObject) 
     {
         imageView.image = responseObject;
     } 
     andErrorHandler:^(NSError* error)
     {
         
     }];
}
@end
