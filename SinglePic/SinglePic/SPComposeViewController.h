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
    IBOutlet SPStyledView* topBarView;
    IBOutlet UIImageView* imageView;
    IBOutlet UILabel *usernameLabel;
    IBOutlet UITableView *tableView;
}
-(id)initWithIdentifier:(NSString*)identifier;
-(id)initWithProfile:(SPProfile*)profile;
//IBActions
-(IBAction)cancel:(id)sender;
-(IBAction)send:(id)sender;
@end
