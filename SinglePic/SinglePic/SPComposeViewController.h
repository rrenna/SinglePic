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
-(id)initWithIdentifier:(NSString*)identifier;
-(id)initWithProfile:(SPProfile*)profile;
//IBActions
-(IBAction)cancel:(id)sender;
-(IBAction)send:(id)sender;
@end
