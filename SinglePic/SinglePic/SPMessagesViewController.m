//
//  SPMessagesViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPMessagesViewController.h"
#import "SPChatBubbleView.h"

@interface SPMessagesViewController()
-(void)reload;
-(void)finishedReloading;
@end

@implementation SPMessagesViewController
#pragma mark - View lifecycle
-(id) init
{
    return [self initWithNibName:@"SPMessagesViewController" bundle:nil];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:NOTIFICATION_MESSAGE_SENT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:NOTIFICATION_NEW_MESSAGES_RECIEVED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedReloading) name:NOTIFICATION_NO_MESSAGES_RECIEVED object:nil];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Localized Controls
    titleLabel.text = NSLocalizedString(@"Messages", nil);
    [editButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
    
    [insetView setStyle:STYLE_BASE];
        //[refreshButton setStyle:STYLE_BASE];
    [editButton setStyle:STYLE_BASE];
    [activityBackgroundView setStyle:STYLE_BASE];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MESSAGE_SENT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NEW_MESSAGES_RECIEVED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NO_MESSAGES_RECIEVED object:nil];
}
#pragma mark - IBActions
-(IBAction)refresh:(id)sender
{
    #if defined (BETA)
    [TestFlight passCheckpoint:@"Clicked on the refresh button in the Messages screen."];
    #endif
    
    [Crashlytics setObjectValue:@"Clicked on the refresh button in the Messages screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    refreshButton.hidden = YES;
    [activityView startAnimating];
    [[SPMessageManager sharedInstance] forceRefresh];
}
-(IBAction)edit:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on the 'Edit' button in the Messages screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    [tableView setEditing:(!tableView.editing) animated:YES];
}
#pragma mark - Private
-(void)reload
{
    [tableView reloadData];
    [self finishedReloading];
}
-(void)finishedReloading
{
    refreshButton.hidden = NO;
    [activityView stopAnimating];
}
#pragma mark - UITableView Delegate and Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[SPMessageManager sharedInstance] activeMessageThreadsCount];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

#define AVATAR_WIDTH 32
#define HEIGHT_OF_TIME_LABEL 23

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* messageThreadsSorted = [[SPMessageManager sharedInstance] activeMessageThreadsSorted];
    SPMessageThread* messageThread = [messageThreadsSorted objectAtIndex:indexPath.row];
    
    NSArray* sortedMessagesForThread = [messageThread sortedMessages];
    SPMessage* latestMessage = ([sortedMessagesForThread count] > 0) ? [sortedMessagesForThread objectAtIndex:[sortedMessagesForThread count] - 1] : nil;
    
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.width = tableView.width;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundView = [[SPCardView alloc] initWithFrame:cell.bounds];
    cell.tag = [[messageThread userID] integerValue];
    
    /*SPLabel* timestampLabel = [[[SPLabel alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, HEIGHT_OF_TIME_LABEL)] autorelease];
    [timestampLabel setStyle:LABEL_STYLE_EXTRA_SMALL];
    timestampLabel.text = [NSString  stringWithFormat:@"%@ ago", [TimeHelper ageOfDate:latestMessage.date] ];
    timestampLabel.backgroundColor = [UIColor clearColor];
    timestampLabel.textColor = [UIColor lightGrayColor];
    timestampLabel.shadowColor = [UIColor whiteColor];
    timestampLabel.textAlignment = UITextAlignmentCenter;
    timestampLabel.shadowOffset = CGSizeMake(1, 1);
    timestampLabel.textAlignment = UITextAlignmentCenter;
    
    [cell.contentView addSubview:timestampLabel];*/
    
    UIImageView* correspondantThumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 20, AVATAR_WIDTH, 30)];
    [cell.contentView addSubview:correspondantThumbnailView];
    
    //If no image is set, download user image
    if(!correspondantThumbnailView.image)
    {
        [[SPProfileManager sharedInstance] retrieveProfile:messageThread.userID withCompletionHandler:^(SPProfile *profile) {
            
            [[SPProfileManager sharedInstance] retrieveProfileThumbnail:profile withCompletionHandler:^(UIImage *thumbnail) {
                
                correspondantThumbnailView.image = thumbnail;
                
            } andErrorHandler:^{
                
            }];
            
        } andErrorHandler:^{}];
    }
    
    //The lates message is used to represent the object
    if(latestMessage)
    {
        SPChatBubbleView* bubble = [[SPChatBubbleView alloc] initWithFrame:CGRectMake(16 + AVATAR_WIDTH, 6, cell.contentView.frame.size.width - 55, cell.contentView.frame.size.height - 11)];
        if([latestMessage.incoming boolValue])
        {
           bubble.chatStyle = CHAT_STYLE_INCOMING;
        }
        else
        {
            bubble.chatStyle = CHAT_STYLE_OUTGOING;
        }

        [bubble setContent:latestMessage.content];
        [cell.contentView addSubview:bubble];
    }

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [Crashlytics setObjectValue:@"Clicked on an individual profile row in the Messages screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString* userID = [NSString stringWithFormat:@"%i",cell.tag];
    SPBaseController* baseController = [SPAppDelegate baseController];
    [baseController pushChatWithID:userID isFromBase:YES];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [Crashlytics setObjectValue:@"Clicked 'Delete' on an individual profile row (revealed by a horizontal swipe) in the Messages screen." forKey:@"last_UI_action"];
    
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSArray* messageThreadsSorted = [[SPMessageManager sharedInstance] activeMessageThreadsSorted];
        SPMessageThread* messageThread = [messageThreadsSorted objectAtIndex:indexPath.row];
        [[SPMessageManager sharedInstance] deleteMessageThread:messageThread];

        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];           
    }
}
@end
