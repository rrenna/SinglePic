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
    IBOutlet SPStyledView* insetView;
    IBOutlet SPStyledSegmentedControl* likeTypeSegmentedControl;
    IBOutlet SPStyledButton* editButton;
    IBOutlet UITableView* tableView;
@private
    NSMutableArray* likes_;
    NSMutableArray* likedBy_;
}
-(IBAction)edit:(id)sender;
-(IBAction)likesTypeSwitched:(id)sender;

-(void)refreshLikedBy;
@end
