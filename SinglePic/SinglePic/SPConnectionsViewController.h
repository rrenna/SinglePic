//
//  SPConnectionsViewController.h
//  SinglePic
//
//  Created by Ryan Renna on 12-02-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPStyledSegmentedControl.h"

@interface SPConnectionsViewController : UIViewController
{
    IBOutlet __weak SPLabel *titleLabel;
    IBOutlet __weak SPStyledView* insetView;
    IBOutlet __weak SPStyledSegmentedControl* likeTypeSegmentedControl;
    IBOutlet __weak SPStyledButton* editButton;
    IBOutlet __weak UITableView* tableView;
}
-(IBAction)edit:(id)sender;
-(IBAction)likesTypeSwitched:(id)sender;

-(void)refreshLikedBy;
@end
