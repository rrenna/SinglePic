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
@property (retain) SPMessageThread* thread;
@property (retain) UIImage* avatar;
-(void)profileLoaded;
-(void)reload;
@end

@implementation SPProfileViewController
@synthesize delegate;
@synthesize profile,thread,avatar;//Private

#pragma mark - View lifecycle
-(id)initWithProfile:(SPProfile*)profile_
{
     self = [self init];
    if(self)
    {
        self.profile = profile_;
        
        if([[SPProfileManager sharedInstance] myUserType] == USER_TYPE_PROFILE)
        {
            self.thread = [[SPMessageManager sharedInstance] getMessageThreadByUserID:profile_.identifier];
        }
    }
    return self;
}
-(id)initWithIdentifier:(NSString*)identifier
{
    self = [self init];
    if(self)
    {
        if([[SPProfileManager sharedInstance] myUserType] == USER_TYPE_PROFILE)
        {
            self.thread = [[SPMessageManager sharedInstance] getMessageThreadByUserID:identifier];
        }
        
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
        profileMode = YES;
        //Signup for notification on message sent/recieved
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:NOTIFICATION_MESSAGE_SENT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:NOTIFICATION_NEW_MESSAGES_RECIEVED object:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MESSAGE_SENT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NEW_MESSAGES_RECIEVED object:nil];
    [profile release];
    [thread release];
    [avatar release];
    [super dealloc];
}
#pragma mark - IBActions
-(IBAction)message:(id)sender
{
    SPComposeViewController* composeController = [[[SPComposeViewController alloc] initWithDelegate:self] autorelease];
    
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
    
    if(profileMode)
    {
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
    }
    else
    {
        inset.top = SCROLLVIEW_MAX_INSET;

        imageView.frame = imageMaximizedRect;
        imageBackgroundStyledView.hidden = NO;
        profileContentView.frame = cardMaximizedRect;
        
        //historyTable.contentInset = inset;
        //historyTable.scrollIndicatorInsets = inset;
        
        offfset.y -= SCROLLVIEW_MAX_INSET;
        //historyTable.contentOffset = offfset;
        historyTable.alpha = 0.0;
        icebreakerLabel.alpha = 1.0;
        bubbleImage.alpha = 1.0;
        messageTipLabel.alpha = 0.0;
        profileContentView.alpha = 0.0;
        
        [modeButton setTitle:@"Messages" forState:UIControlStateNormal];
    }
    
    profileMode = !profileMode;
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
-(void)reload
{
    //If there was no open thread with this user, and we've messaged them for the first time, we need to retrieve the thread object created fist
    if(!self.thread)
    {
        self.thread = [[SPMessageManager sharedInstance] getMessageThreadByUserID:self.profile.identifier];
    }
    
    [historyTable reloadData];
}
#pragma mark - ComposeViewDelegate methods
-(NSString*)targetUserIDForComposeView:(SPComposeViewController*)composeView
{
    return [self.profile identifier];
}
-(UIImage*)targetUserImageForComposeView:(SPComposeViewController*)composeView
{
    return imageView.image;
}
-(BOOL)composeView:(SPComposeViewController*)composeView shouldSendMessage:(NSString*)message toUserID:(NSString*)userID
{
    return YES;
}
#pragma mark - UITableViewDatasource and UITableViewDelegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count;
    if(self.thread)
    {
        count = [thread.messages count];
    }
    else 
    {
        count = 0;
    }

    messageTipLabel.hidden = (count != 0);
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* sortedMessagesForThread = [thread sortedMessages];
    SPMessage* message = [sortedMessagesForThread objectAtIndex:indexPath.row];
    
    CGSize size = [SPMessageView heightForMessageBody:message.content withWidth:tableView.frame.size.width - 28 - 20];
    return size.height + 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSArray* sortedMessagesForThread = [thread sortedMessages];
    SPMessage* message = [sortedMessagesForThread objectAtIndex:indexPath.row];
    
    UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell.width = tableView.width;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //The lates message is used to represent the object
    if(message)
    {
        UILabel* timestampLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 25)] autorelease];
        timestampLabel.text = [NSString  stringWithFormat:@"%@ ago", [TimeHelper ageOfDate:message.date] ];
        timestampLabel.font = [UIFont systemFontOfSize:8];
        timestampLabel.backgroundColor = [UIColor clearColor];
        timestampLabel.textColor = [UIColor lightGrayColor];
        timestampLabel.shadowColor = [UIColor whiteColor];
        timestampLabel.textAlignment = UITextAlignmentCenter;
        timestampLabel.shadowOffset = CGSizeMake(1, 1);
        
        CGRect messageFrame;
        if([message.incoming boolValue])
        {
            //If incoming message
            messageFrame = CGRectMake(15, 20, cell.contentView.frame.size.width - 28, cell.contentView.frame.size.height - 25);
        }
        else 
        {
            //If outgoing message
            messageFrame = CGRectMake(0, 20, cell.contentView.frame.size.width - 43, cell.contentView.frame.size.height - 25);

        }
        
        
        SPMessageView* messageView = [[[SPMessageView alloc] initWithFrame:messageFrame] autorelease];
        [messageView setContent:message.content];
        
        [cell.contentView addSubview:timestampLabel];
        [cell.contentView addSubview:messageView];
    }
    
    return cell;
}
@end
