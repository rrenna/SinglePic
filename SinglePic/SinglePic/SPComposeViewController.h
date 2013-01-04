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
#import "UIInputToolbar.h"

@class SPComposeViewController,SPStyledButton;

@interface SPComposeViewController : SPPageContentViewController <UIGestureRecognizerDelegate,SPKeyboardDragTableViewDelegate,UITableViewDataSource,UIInputToolbarDelegate,UIExpandingTextViewDelegate>
{
    IBOutlet __weak SPStyledView* topBarView;
    IBOutlet __weak SPStyledButton *closeButton;
    IBOutlet __weak UIButton *viewProfileButton;
    IBOutlet __weak UIImageView* imageView;
    IBOutlet __weak UILabel *usernameLabel;
    IBOutlet __weak UITableView *tableView;
}
@property (assign) BOOL minimizeContainerOnClose;

-(id)initWithIdentifier:(NSString*)identifier;
-(id)initWithProfile:(SPProfile*)profile;
//IBActions
-(IBAction)cancel:(id)sender;
-(IBAction)send:(id)sender;
-(IBAction)viewProfile:(id)sender;
@end
