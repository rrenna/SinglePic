//
//  SPMessagesViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPMessagesViewController.h"
#import "SPMessageThread.h"
#import "SPMessage.h"
#import "SPCardView.h"
#import "SPMessageView.h"
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
    [super dealloc];
}
#pragma mark - IBActions
-(IBAction)refresh:(id)sender
{
    #if defined (TESTING)
    [TestFlight passCheckpoint:@"Manually refreshed Messages"];
    #endif
    
    refreshButton.hidden = YES;
    [activityView startAnimating];
    [[SPMessageManager sharedInstance] forceRefresh];
    [[SPMessageManager sharedInstance] forceRefresh];
}
-(IBAction)edit:(id)sender
{
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* messageThreadsSorted = [[SPMessageManager sharedInstance] activeMessageThreadsSorted];
    SPMessageThread* messageThread = [messageThreadsSorted objectAtIndex:indexPath.row];
    
    NSArray* sortedMessagesForThread = [messageThread sortedMessages];
    SPMessage* latestMessage = ([sortedMessagesForThread count] > 0) ? [sortedMessagesForThread objectAtIndex:[sortedMessagesForThread count] - 1] : nil;
    
    UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell.width = tableView.width;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundView = [[[SPCardView alloc] initWithFrame:cell.bounds] autorelease];
    cell.tag = [[messageThread userID] integerValue];
    
    //The lates message is used to represent the object
    if(latestMessage)
    {
        /*
        SPMessageView* messageView = [[[SPMessageView alloc] initWithFrame:CGRectMake(5, 20, cell.contentView.frame.size.width - 10, cell.contentView.frame.size.height - 25)] autorelease];
        [messageView setContent:latestMessage.content];
        [cell.contentView addSubview:messageView];
        */
        
        SPChatBubbleView* bubble = [[[SPChatBubbleView alloc] initWithFrame:CGRectMake(50, 5, cell.contentView.frame.size.width - 45, cell.contentView.frame.size.height - 8)] autorelease];
        [bubble setContent:latestMessage.content];
        [cell.contentView addSubview:bubble];
        
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString* userID = [NSString stringWithFormat:@"%i",cell.tag];
    SPBaseController* baseController = [[[UIApplication sharedApplication] delegate] baseController];
    [baseController pushChatWithID:userID];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSArray* messageThreads = [[SPMessageManager sharedInstance] activeMessageThreads];
        SPMessageThread* messageThread = [messageThreads objectAtIndex:indexPath.row];
        [[SPMessageManager sharedInstance] deleteMessageThread:messageThread];

        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];           
    }
}
@end
