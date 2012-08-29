//
//  SPComposeViewController.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPPageContentViewController.h"
#import "SPKeyboardDragTableView.h"
#import "SPStyledView.h"

@class SPComposeViewController,SPStyledButton;

@protocol ComposeViewDelegate <NSObject> 
-(NSString*)targetUserIDForComposeView:(SPComposeViewController*)composeView;
-(UIImage*)targetUserImageForComposeView:(SPComposeViewController*)composeView;
-(BOOL)composeView:(SPComposeViewController*)composeView shouldSendMessage:(NSString*)message toUserID:(NSString*)userID;
@end

@interface SPComposeViewController : SPPageContentViewController <UIGestureRecognizerDelegate,SPKeyboardDragTableViewDelegate,UITableViewDataSource>
{
    IBOutlet SPStyledView* topBarView;
    IBOutlet UIImageView* imageView;
    IBOutlet SPStyledView* writingPadView;
    IBOutlet UITableView *tableView;
    IBOutlet UITextField *textField;
    IBOutlet UITextView* textView;
    IBOutlet SPStyledButton* cancelButton;
    IBOutlet SPStyledButton* sendButton;
    IBOutlet UIToolbar *toolbar;
    @private
    UIView* keyboard;
    int originalKeyboardY;
    int originalLocation;
}
@property (assign) id<ComposeViewDelegate> delegate;

-(id)initWithIdentifier:(NSString*)identifier;
-(id)initWithProfile:(SPProfile*)profile;
-(id)initWithDelegate:(id<ComposeViewDelegate>)delegate;
//IBActions
-(IBAction)cancel:(id)sender;
-(IBAction)send:(id)sender;
@end
