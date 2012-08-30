//
//  SPComposeViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPComposeViewController.h"
//#import "DAKeyboardControl.h"
#import "SPMessageManager.h"
#import "SPMessage.h"
#import "SPStyledButton.h"
#import "SPMessageView.h"

@interface SPComposeViewController()
@property (retain) SPMessageThread* thread;
@property (retain) SPProfile* profile;
-(void) profileLoaded;
@end

static float FingerGrabHandleSize = 20.0f;
static float minimizedToolbarY = 406.0f;

@implementation SPComposeViewController
@synthesize delegate;
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
        self.profile = profile_;
        [self profileLoaded];
    }
    return self;
}
-(id)initWithDelegate:(id<ComposeViewDelegate>)delegate_
{
    self = [self initWithNibName:@"SPComposeViewController" bundle:nil];
    if(self)
    {
        self.delegate = delegate_;
        
        NSString* targetUserID = [delegate targetUserIDForComposeView:self];
        self.thread = [[SPMessageManager sharedInstance] getMessageThreadByUserID:targetUserID];
        
            //TODO: Decide if RELOAD functionality is needed
        /*
         
         //Signup for notification on message sent/recieved
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:NOTIFICATION_MESSAGE_SENT object:nil];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:NOTIFICATION_NEW_MESSAGES_RECIEVED object:nil];
         [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MESSAGE_SENT object:nil];
         [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NEW_MESSAGES_RECIEVED object:nil];
         
         */
        
    }
    return self;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:tableView name:NOTIFICATION_NEW_MESSAGES_RECIEVED object:nil];
    
    [_thread release];
    [toolbar release];
    [textField release];
    [tableView release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [topBarView setStyle:STYLE_PAGE];
    [topBarView setDepth:DEPTH_OUTSET];
    [cancelButton setStyle:STYLE_TAB];
    
    [writingPadView setStyle:STYLE_WHITE];
    [writingPadView setDepth:DEPTH_OUTSET];
    
    [sendButton setStyle:STYLE_CONFIRM_BUTTON];
    
    //
    //
    UIImage* avatar = [delegate targetUserImageForComposeView:self];
    imageView.image = avatar;
    
    /*
    self.view.keyboardTriggerOffset = toolbar.bounds.size.height;
    
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        
         //Try not to call "self" inside this block (retain cycle).
         //But if you do, make sure to remove DAKeyboardControl
         //when you are done with the view controller by calling:
         //[self.view removeKeyboardControl];
        
        
        CGRect toolBarFrame = toolbar.frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        toolbar.frame = toolBarFrame;
        
        CGRect tableViewFrame = tableView.frame;
        tableViewFrame.size.height = toolBarFrame.origin.y;
        tableView.frame = tableViewFrame;

    }];
     */
    
    //[tableView setCanCancelContentTouches:NO];
    //[tableView setExclusiveTouch:NO];
    
    // always know which keyboard is selected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldWasSelected:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    
    // register for when a keyboard pops up
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:tableView selector:@selector(reloadData) name:NOTIFICATION_NEW_MESSAGES_RECIEVED object:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
}

#pragma mark - IBActions
-(IBAction)cancel:(id)sender
{
    [self setFullscreen:NO];
    [self close];
}
-(IBAction)send:(id)sender
{
    sendButton.enabled = NO;
    
    NSString* targetUserID = [delegate targetUserIDForComposeView:self];
    [[SPMessageManager sharedInstance] sendMessage:textField.text toUserWithID:targetUserID withCompletionHandler:^(id responseObject)
    {
        #if defined (TESTING)
        [TestFlight passCheckpoint:@"Sent Message to User"];
        #endif
        
        [tableView reloadData];
        sendButton.enabled = YES;
    } 
    andErrorHandler:^
    {
        //Error
        //TODO: Display error
        sendButton.enabled = YES;
    }];
}
#pragma mark - Private methods
//Do not enable any interaction with this user until it's profile has been loaded
-(void)profileLoaded
{
    self.thread = [[SPMessageManager sharedInstance] getMessageThreadByUserID:self.profile.identifier];
    [tableView reloadData];
}
- (void)textfieldWasSelected:(NSNotification *)notification {
    
    textField = notification.object;
    
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
        completion:^(BOOL finished){}
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
    
    if(!keyboard.hidden)
    {
        CGPoint location = [gestureRecognizer locationInView:[self view]];
        CGPoint velocity = [gestureRecognizer velocityInView:self.view];
        
        if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
            originalKeyboardY = keyboard.frame.origin.y;
        }
        
        if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
            if (velocity.y > 0) {
                [self animateKeyboardOffscreen];
            }else{
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

- (void)animateKeyboardOffscreen {
    
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

- (void)animateKeyboardReturnToOriginalPosition {
    
    [UIView beginAnimations:nil context:NULL];
    CGRect newFrame = keyboard.frame;
    newFrame.origin.y = originalKeyboardY;
    [keyboard setFrame: newFrame];
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [self send:sendButton];
    return YES;
}
@end
