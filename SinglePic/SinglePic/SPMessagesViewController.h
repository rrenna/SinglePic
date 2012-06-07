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
    IBOutlet SPStyledView* insetView;
    IBOutlet SPStyledButton* refreshButton;
    IBOutlet SPStyledButton* editButton;
    IBOutlet SPStyledView* activityBackgroundView;
    IBOutlet UIActivityIndicatorView* activityView;
    IBOutlet UITableView* tableView;
}
-(IBAction)refresh:(id)sender;
-(IBAction)edit:(id)sender;
@end
