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
#import "SPChatBubbleView.h"

@interface SPComposeViewController()
{
    UIView* keyboard;
    int originalKeyboardY;
    BOOL sending;
}
@property (retain) SPMessageThread* thread;
@property (retain) SPProfile* profile;
@property (retain) UIInputToolbar* toolbar;

-(void) _init;
-(void) profileLoaded;
-(void) reload;
-(void) messageSent;
-(void) messageRecieved;
-(void) scrollToBottomAnimated:(BOOL)animated;
@end

#define TABLE_RESIZE_OFFSET 27
#define HEIGHT_OF_TIME_LABEL 32
#define FINGER_GRAB_HAND_SIZE 20.0f
#define INPUT_TOOLBAR_SIZE 42.0f
#define MINIMIZED_TOOLBAR_Y (self.view.window.height - _toolbar.height)


@implementation SPComposeViewController
@synthesize minimizeContainerOnClose = _minimizeContainerOnClose;
@synthesize thread = _thread, profile = _profile, toolbar = _toolbar; //private

#pragma mark - View lifecycle
-(id)initWithIdentifier:(NSString*)identifier
{
    self = [self initWithNibName:@"SPComposeViewController" bundle:nil];
    if(self)
    {
        [self _init];
        
        __unsafe_unretained SPComposeViewController* weakSelf = self;
        [[SPProfileManager sharedInstance] retrieveProfile:identifier withCompletionHandler:^
         (SPProfile *profile)
         {
             weakSelf.profile = profile;
             [weakSelf profileLoaded];
             
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
    self.minimizeContainerOnClose = NO;
    sending = NO;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self]; //Ensures we are not listening to any more events
    [[NSNotificationCenter defaultCenter] removeObserver:tableView name:NOTIFICATION_NEW_MESSAGES_RECIEVED object:nil];
    
    [_thread release];
    [_profile release];
    [_toolbar release];
    [tableView release];
    [usernameLabel release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Localize Controls
    [closeButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    
    if(self.profile)
    {
        [self profileLoaded];
    }
    
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    
    _toolbar = [[UIInputToolbar alloc] initWithFrame:CGRectMake(0, window.height, window.width, INPUT_TOOLBAR_SIZE)];
    _toolbar.delegate = self;
    _toolbar.textView.placeholder = NSLocalizedString(@"Enter a Message", nil);
    
    [window addSubview:_toolbar];
    
    tableView.height = window.height - 107;
    
    [topBarView setStyle:STYLE_PAGE];
    [topBarView setDepth:DEPTH_OUTSET];
    
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
-(void) viewDidAppear:(BOOL)animated
{
    [UIView animateWithDuration:0.25
                     delay:0.0
                     options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         UIWindow* window = [[UIApplication sharedApplication] keyWindow];
                         CGRect toolBarFrame = _toolbar.frame;
                         toolBarFrame.origin.y = window.height - _toolbar.height;
                         [_toolbar setFrame: toolBarFrame];
                         
                     }
                     completion:^(BOOL finished)
                     {
                     
                     }];
    
    [super viewDidAppear:animated];
}
-(void) viewDidDisappear:(BOOL)animated
{
    keyboard.hidden = NO;
    [super viewDidDisappear:animated];
}
-(void)close
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _toolbar.top = _toolbar.window.height;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         [_toolbar removeFromSuperview];
                     }];
    
    [_toolbar.textView resignFirstResponder];

    [[NSNotificationCenter defaultCenter] removeObserver:self]; //When closing, we don't need to consume any of the keyboard specific events    
    
    [super close];
}
#pragma mark - IBActions
-(IBAction)cancel:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on the 'Close' button in a chat screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    [self setFullscreen:NO animated:YES];
    
    if(self.minimizeContainerOnClose)
    {
        [self minimizeContainer];
    }
    
    //When the Chat screen is spawned from the Messages screen it will dismiss it's container tab when closed to bring
    // the user back to the Messages screen
    
    [self close];
}
-(IBAction)send:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on the 'Send' button in a chat screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    _toolbar.inputButton.enabled = NO;
    sending = YES;
    
    [[SPMessageManager sharedInstance] sendMessage:_toolbar.textView.text toUserWithID:self.profile.identifier withCompletionHandler:^(id responseObject)
    {
        #if defined (BETA)
        [TestFlight passCheckpoint:@"Sent Message to User"];
        #endif
        
        _toolbar.textView.text = @"";
        _toolbar.inputButton.enabled = NO;
        sending = NO;
    } 
    andErrorHandler:^
    {
        //Error
        //TODO: Display error
        _toolbar.inputButton.enabled = YES;
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
    
    usernameLabel.text = self.profile.username;
    
    self.thread = [[SPMessageManager sharedInstance] getMessageThreadByUserID:self.profile.identifier];
    [[SPMessageManager sharedInstance] readMessageThread:self.thread];
    
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
    //textField = notification.object;
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
            
            _toolbar.top = keyboardEndFrameView.origin.y - _toolbar.height + 25;
            
            tableView.height = _toolbar.origin.y - (tableView.frame.origin.y + TABLE_RESIZE_OFFSET);
            
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
        
       CGFloat spaceAboveKeyboard = self.view.bounds.size.height - (keyboard.frame.size.height + _toolbar.frame.size.height) + FINGER_GRAB_HAND_SIZE;
 
         if (location.y < spaceAboveKeyboard) {
            return;
        }
        
        CGRect newFrame = keyboard.frame;
        CGFloat newY = originalKeyboardY + (location.y - spaceAboveKeyboard);
        newY = MAX(newY, originalKeyboardY);
        newFrame.origin.y = newY;
        
        [keyboard setFrame: newFrame];
        
        CGRect toolBarFrame = _toolbar.frame;
        CGFloat keyboardY = (keyboard)? keyboard.frame.origin.y : self.view.bottom;
        keyboardY = MIN(MINIMIZED_TOOLBAR_Y,keyboardY - _toolbar.height);
        toolBarFrame.origin.y = keyboardY;
        [_toolbar setFrame: toolBarFrame];
        
        tableView.height = _toolbar.origin.y - (tableView.frame.origin.y + TABLE_RESIZE_OFFSET);
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
                         
                         CGRect toolBarFrame = _toolbar.frame;
                         CGFloat keyboardY = (keyboard)? keyboard.frame.origin.y : self.view.bottom;
                         toolBarFrame.origin.y = MIN(MINIMIZED_TOOLBAR_Y,keyboardY - _toolbar.height);
                         [_toolbar setFrame: toolBarFrame];
                         
                         tableView.height = _toolbar.origin.y - (tableView.frame.origin.y + TABLE_RESIZE_OFFSET);
                     }
                     completion:^(BOOL finished) {
                         
                         [_toolbar.textView resignFirstResponder];
                     }];
}
- (void)animateKeyboardReturnToOriginalPosition
{
    [UIView beginAnimations:nil context:NULL];
    CGRect newFrame = keyboard.frame;
    newFrame.origin.y = originalKeyboardY;
    [keyboard setFrame: newFrame];
    
    CGRect toolBarFrame = _toolbar.frame;
    CGFloat keyboardY = (keyboard)? keyboard.frame.origin.y : self.view.bottom;
    toolBarFrame.origin.y = MIN(MINIMIZED_TOOLBAR_Y,keyboardY - _toolbar.height);
    [_toolbar setFrame: toolBarFrame];
    
    tableView.height = _toolbar.origin.y - (tableView.frame.origin.y + TABLE_RESIZE_OFFSET);

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
    
    CGSize size = [SPChatBubbleView heightForMessageBody:message.content withWidth:tableView.frame.size.width - 43 - 20];
    return size.height + 20 + HEIGHT_OF_TIME_LABEL; //top & bottom spacing in chat bubble + time label
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
        SPLabel* timestampLabel = [[[SPLabel alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, HEIGHT_OF_TIME_LABEL)] autorelease];
        [timestampLabel setStyle:LABEL_STYLE_EXTRA_SMALL];
        timestampLabel.text = [NSString  stringWithFormat:@"%@ ago", [TimeHelper ageOfDate:message.date] ];
        timestampLabel.backgroundColor = [UIColor clearColor];
        timestampLabel.textColor = [UIColor lightGrayColor];
        timestampLabel.shadowColor = [UIColor whiteColor];
        timestampLabel.textAlignment = UITextAlignmentCenter;
        timestampLabel.shadowOffset = CGSizeMake(1, 1);
        timestampLabel.textAlignment = UITextAlignmentCenter;
        timestampLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        
        CGRect messageFrame;
        CHAT_STYLE style;
        if([message.incoming boolValue])
        {
            //If incoming message
            messageFrame = CGRectMake(15, 24, cell.contentView.frame.size.width - 43, cell.contentView.frame.size.height - 25);
            style = CHAT_STYLE_INCOMING;
        }
        else
        {
            //If outgoing message
            messageFrame = CGRectMake(0, 24, cell.contentView.frame.size.width - 43, cell.contentView.frame.size.height - 24);
            style = CHAT_STYLE_OUTGOING;
        }
        
        SPChatBubbleView* messageView = [[[SPChatBubbleView alloc] initWithFrame:messageFrame] autorelease];
        messageView.chatStyle = style;
        messageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        [messageView setContent:message.content];
        
        [cell.contentView addSubview:timestampLabel];
        [cell.contentView addSubview:messageView];
    }
    
    return cell;
}
#pragma mark - UIInputToolbarDelegate
-(void)inputButtonPressed:(NSString *)inputText
{
    if(!sending)
    {
        [self send:nil];
    }
}
- (BOOL)expandingTextView:(UIExpandingTextView *)expandingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString* newContent = [expandingTextView.text stringByReplacingCharactersInRange:range withString:text];
    _toolbar.inputButton.enabled  = ([newContent length] > 0);
    return YES;
}
- (BOOL)expandingTextViewShouldBeginEditing:(UITextView *)textView
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
            [SVProgressHUD dismissWithError:NSLocalizedString(@"You must have a Pic set to send a message", nil) afterDelay:2.0];
        }
        else if([[SPProfileManager sharedInstance] isImageExpired])
        {
            [SVProgressHUD dismissWithError:NSLocalizedString(@"You must update your expired Pic to send a message",nil) afterDelay:2.0];
        }
        
        return NO;
    }
}

- (void)viewDidUnload {
    closeButton = nil;
    [super viewDidUnload];
}
@end
