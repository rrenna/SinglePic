//
//  SPComposeViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPComposeViewController.h"
#import "SPMessageManager.h"
#import "SPStyledButton.h"

@implementation SPComposeViewController
@synthesize delegate;

#pragma mark - View lifecycle
-(id)initWithDelegate:(id<ComposeViewDelegate>)delegate_
{
    self = [self initWithNibName:@"SPComposeViewController" bundle:nil];
    if(self)
    {
        self.delegate = delegate_;
    }
    return self;
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
    [textView becomeFirstResponder];
    //
    UIImage* avatar = [delegate targetUserImageForComposeView:self];
    imageView.image = avatar;
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
    [[SPMessageManager sharedInstance] sendMessage:textView.text toUserWithID:targetUserID withCompletionHandler:^(id responseObject) 
    {
        #if defined (TESTING)
        [TestFlight passCheckpoint:@"Sent Message to User"];
        #endif
        
        //Completion
        [self setFullscreen:NO];
        [self close];
    } 
    andErrorHandler:^
    {
        //Error
        //TODO: Display error
        sendButton.enabled = YES;
    }];
}
@end
