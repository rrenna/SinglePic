//
//  SPMessagesViewController.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPStyledButton.h"
#import "SPStyledView.h"

@interface SPMessagesViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet __weak SPLabel *titleLabel;
    IBOutlet __weak SPStyledView* insetView;
    IBOutlet __weak SPStyledButton* refreshButton;
    IBOutlet __weak SPStyledButton* editButton;
    IBOutlet __weak SPStyledView* activityBackgroundView;
    IBOutlet __weak UIActivityIndicatorView* activityView;
    IBOutlet __weak UITableView* tableView;
}
-(IBAction)refresh:(id)sender;
-(IBAction)edit:(id)sender;
@end
