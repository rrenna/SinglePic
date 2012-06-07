//
//  SPComposeViewController.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPPageContentViewController.h"
#import "SPStyledView.h"

@class SPComposeViewController,SPStyledButton;

@protocol ComposeViewDelegate <NSObject>
-(NSString*)targetUserIDForComposeView:(SPComposeViewController*)composeView;
-(UIImage*)targetUserImageForComposeView:(SPComposeViewController*)composeView;
-(BOOL)composeView:(SPComposeViewController*)composeView shouldSendMessage:(NSString*)message toUserID:(NSString*)userID;
@end

@interface SPComposeViewController : SPPageContentViewController
{
    IBOutlet SPStyledView* topBarView;
    IBOutlet UIImageView* imageView;
    IBOutlet SPStyledView* writingPadView;
    IBOutlet UITextView* textView;
    IBOutlet SPStyledButton* cancelButton;
    IBOutlet SPStyledButton* sendButton;
}
@property (assign) id<ComposeViewDelegate> delegate;

-(id)initWithDelegate:(id<ComposeViewDelegate>)delegate;
//IBActions
-(IBAction)cancel:(id)sender;
-(IBAction)send:(id)sender;
@end
