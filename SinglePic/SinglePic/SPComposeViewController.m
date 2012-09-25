//
//  SPComposeViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPComposeViewController.h"
#import "SVProgressHUD.h"
#import "SPMessageManager.h"
#import "SPMessage.h"
#import "SPStyledButton.h"
#import "SPMessageView.h"

@interface SPComposeViewController()
{
    UIView* keyboard;
    int originalKeyboardY;
    BOOL sending;
}
@property (retain) SPMessageThread* thread;
@property (retain) SPProfile* profile;
-(void) _init;
-(void) profileLoaded;
-(void) reload;
-(void) messageSent;
-(void) messageRecieved;
-(void) scrollToBottomAnimated:(BOOL)animated;
@end

static float FingerGrabHandleSize = 20.0f;
static float minimizedToolbarY = 410.0f;

@implementation SPComposeViewController
@synthesize thread = _thread, profile = _profile; //private

#pragma mark - View lifecycle
-(id)initWithIdentifier:(NSString*)identifier
{
    self = [self initWithNibName:@"SPComposeViewController" bundle:nil];
    if(self)
    {
        
        [[SPProfileManager sharedInstance] retrieveProfile:identifier withCompletionHandler:^
         (SPProfile *profile)
         {
             [self _init];
             self.profile = profile;
             [self profileLoaded];
             
         } andErrorHandler:^
         {
             
         }];
    }
    return self;
}

-(id)initWithProfile:(SPProfile*)profile_
{
    self = [self init];
    if(self)
    {
        [self _init];
        self.profile = profile_;
    }
    return self;
}
-(void)_init
{
    sending = NO;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self]; //Ensures we are not listening to any more events
    [[NSNotificationCenter defaultCenter] removeObserver:tableView name:NOTIFICATION_NEW_MESSAGES_RECIEVED object:nil];
    
    [_thread release];
    [_profile release];
    [toolbar release];
    [textField release];
    [tableView release];
    [usernameLabel release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.profile)
    {
        [self profileLoaded];
    }
    
    [topBarView setStyle:STYLE_PAGE];
    [topBarView setDepth:DEPTH_OUTSET];
    [sendButton setStyle:STYLE_CONFIRM_BUTTON];
    
    //Signup for notification on message recieved (reload will be called directly by the send button handler)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageSent) name:NOTIFICATION_MESSAGE_SENT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageRecieved) name:NOTIFICATION_NEW_MESSAGES_RECIEVED object:nil];
    
    // always know which keyboard is selected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldWasSelected:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    
    // register for when a keyboard pops up
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:tableView selector:@selector(reloadData) name:NOTIFICATION_NEW_MESSAGES_RECIEVED object:nil];
}
- (void) viewDidDisappear:(BOOL)animated
{
    keyboard.hidden = NO;
    [super viewDidDisappear:animated];
}
#pragma mark - IBActions
-(IBAction)cancel:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self]; //When closing, we don't need to consume any of the keyboard specific events
    
    [self setFullscreen:NO];
    
    [self close];
}
-(IBAction)send:(id)sender
{
    sendButton.enabled = NO;
    sending = YES;
    
    [[SPMessageManager sharedInstance] sendMessage:textField.text toUserWithID:self.profile.identifier withCompletionHandler:^(id responseObject)
    {
        #if defined (TESTING)
        [TestFlight passCheckpoint:@"Sent Message to User"];
        #endif
        [textField setText:@""];
        sendButton.enabled = NO;
        sending = NO;
    } 
    andErrorHandler:^
    {
        //Error
        //TODO: Display error
        sendButton.enabled = YES;
        sending = NO;
    }];
}
#pragma mark - Private methods
//Do not enable any interaction with this user until it's profile has been loaded
-(void)profileLoaded
{
    if(![_profile isValid])
    {
        //Profile is invalid
        [[SPErrorManager sharedInstance] alertWithTitle:@"Invalid Profile" Description:@"This user no longer exists. The account may have been deleted."];
    }
    [[SPProfileManager sharedInstance] retrieveProfileThumbnail:self.profile withCompletionHandler:^(UIImage *thumbnail)
    {
        imageView.image = thumbnail;
    }
    andErrorHandler:nil];
    
    self.thread = [[SPMessageManager sharedInstance] getMessageThreadByUserID:self.profile.identifier];
    usernameLabel.text = self.profile.username;
    
    [self reload];
    [self scrollToBottomAnimated:NO];
}
-(void)reload
{
    [tableView reloadData];
}
-(void)messageSent
{
    [self reload];
    [self scrollToBottomAnimated:YES];
}
-(void) messageRecieved
{
    [self reload];
    //TODO: Check if the message is from this thread
    [self scrollToBottomAnimated:YES];
}
-(void) scrollToBottomAnimated:(BOOL)animated
{
    if(self.thread.messages.count > 0)
    {
        NSIndexPath* lastRow = [NSIndexPath indexPathForRow:self.thread.messages.count - 1 inSection:0];
        [tableView scrollToRowAtIndexPath:lastRow atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}
- (void)textfieldWasSelected:(NSNotification *)notification
{
    textField = notification.object;
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    keyboard.hidden = YES;
}
- (void)keyboardWillShow:(NSNotification *)notification {
    
    // To remove the animation for the keyboard dropping showing
    // we have to hide the keyboard, and on will show we set it back.
    keyboard.hidden = NO;

    CGRect keyboardEndFrameWindow;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardEndFrameWindow];
    
    double keyboardTransitionDuration;
    [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardTransitionDuration];
    
    UIViewAnimationCurve keyboardTransitionAnimationCurve;
    [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];

    CGRect keyboardEndFrameView = [self.view convertRect:keyboardEndFrameWindow fromView:nil];
    
    [UIView animateWithDuration:keyboardTransitionDuration
        delay:0.0f
        options:keyboardTransitionAnimationCurve
        animations:^{
            
             CGRect toolBarFrame = toolbar.frame;
             toolBarFrame.origin.y = keyboardEndFrameView.origin.y - toolBarFrame.size.height;
             toolbar.frame = toolBarFrame;
             
             CGRect tableViewFrame = tableView.frame;
             tableViewFrame.size.height = toolBarFrame.origin.y - tableView.top;
             tableView.frame = tableViewFrame;  
        }
        completion:^(BOOL finished){
        
            [self scrollToBottomAnimated:YES];
        
        }
     ];
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    if(keyboard) return;
    
    //Because we cant get access to the UIKeyboard throught the SDK we will just use UIView.
    //UIKeyboard is a subclass of UIView anyways
    //see discussion http://www.iphonedevsdk.com/forum/iphone-sdk-development/6573-howto-customize-uikeyboard.html
    
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    for(int i = 0; i < [tempWindow.subviews count]; i++) {
        UIView *possibleKeyboard = [tempWindow.subviews objectAtIndex:i];
        if([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"] == YES){
            keyboard = possibleKeyboard;
            return;
        }
    }
}

-(void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    
    if(keyboard && !keyboard.hidden)
    {
        CGPoint location = [gestureRecognizer locationInView:[self view]];
        CGPoint velocity = [gestureRecognizer velocityInView:self.view];
        
        if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            originalKeyboardY = keyboard.frame.origin.y;
        }
        
        if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
            
            if (velocity.y > 0)
            {
                NSLog(@"y > 0");
                [self animateKeyboardOffscreen];
            }
            else
            {
                NSLog(@"y <= 0");
                [self animateKeyboardReturnToOriginalPosition];
            }
            return;
        }
        
       CGFloat spaceAboveKeyboard = self.view.bounds.size.height - (keyboard.frame.size.height + toolbar.frame.size.height) + FingerGrabHandleSize;
 
         if (location.y < spaceAboveKeyboard) {
            return;
        }
        
        CGRect newFrame = keyboard.frame;
        CGFloat newY = originalKeyboardY + (location.y - spaceAboveKeyboard);
        newY = MAX(newY, originalKeyboardY);
        newFrame.origin.y = newY;
        
        [keyboard setFrame: newFrame];
        
        CGRect toolBarFrame = toolbar.frame;
        CGFloat keyboardY = (keyboard)? keyboard.frame.origin.y : self.view.bottom;
        keyboardY = MIN(minimizedToolbarY,keyboardY - 68);
        toolBarFrame.origin.y = keyboardY;
        [toolbar setFrame: toolBarFrame];
        
        CGFloat tableHeight = toolbar.origin.y - tableView.frame.origin.y;
        tableView.height = tableHeight;
    }
}

- (void)animateKeyboardOffscreen
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect newFrame = keyboard.frame;
                         newFrame.origin.y = keyboard.window.frame.size.height;
                         [keyboard setFrame: newFrame];
                         
                         CGRect toolBarFrame = toolbar.frame;
                         CGFloat keyboardY = (keyboard)? keyboard.frame.origin.y : self.view.bottom;
                         toolBarFrame.origin.y = MIN(minimizedToolbarY,keyboardY - 68);
                         [toolbar setFrame: toolBarFrame];
                         
                         CGFloat tableHeight = toolbar.origin.y - tableView.frame.origin.y;
                         tableView.height = tableHeight;
                     }
     
                     completion:^(BOOL finished){
                             //keyboard.hidden = YES;
                         [textField resignFirstResponder];
                     }];
}

- (void)animateKeyboardReturnToOriginalPosition
{
    [UIView beginAnimations:nil context:NULL];
    CGRect newFrame = keyboard.frame;
    newFrame.origin.y = originalKeyboardY;
    [keyboard setFrame: newFrame];
    
    CGRect toolBarFrame = toolbar.frame;
    CGFloat keyboardY = (keyboard)? keyboard.frame.origin.y : self.view.bottom;
    toolBarFrame.origin.y = MIN(minimizedToolbarY,keyboardY - 68);
    [toolbar setFrame: toolBarFrame];
    
    CGFloat tableHeight = toolbar.origin.y - tableView.frame.origin.y;
    tableView.height = tableHeight;
    [UIView commitAnimations];
}
#pragma mark - UITableViewDatasource and UITableViewDelegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count;
    if(self.thread)
    {
        count = [self.thread.messages count];
    }
    else
    {
        count = 0;
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* sortedMessagesForThread = [self.thread sortedMessages];
    SPMessage* message = [sortedMessagesForThread objectAtIndex:indexPath.row];
    
    CGSize size = [SPMessageView heightForMessageBody:message.content withWidth:tableView.frame.size.width - 28 - 20];
    return size.height + 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* sortedMessagesForThread = [self.thread sortedMessages];
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
#pragma mark - UITextField delegate methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //Cannot edit textbox while sending a previous message
    if(sending)
    {
        return NO;
    }
    
    //Disabled messaging if user has no assigned image
    if([[SPProfileManager sharedInstance] canSendMessages])
    {
        return YES;
    }
    else
    {
        [SVProgressHUD show];
        
        if(![[SPProfileManager sharedInstance] isImageSet])
        {
            [SVProgressHUD dismissWithError:@"You must have a Pic set to send a message." afterDelay:2.0];
        }
        else if([[SPProfileManager sharedInstance] isImageExpired])
        {
            [SVProgressHUD dismissWithError:@"You must update your expired Pic to send a message." afterDelay:2.0];
        }
        
        return NO;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    if(!sending)
    {
        [self send:sendButton];
        return YES;
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* newContent = [textField.text stringByReplacingCharactersInRange:range withString:string];
    sendButton.enabled  = ([newContent length] > 0);
    return YES;
}
@end
