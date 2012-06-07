//
//  SPSettingsViewController.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-03-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDACStyle;

@interface SPSettingsViewController : UIViewController
{
    IBOutlet UINavigationController* navigationController;
    IBOutlet UIViewController* settingsScreenController;
@private
        MDACStyle *style;
}

-(IBAction)close:(id)sender;
-(IBAction)about:(id)sender;
//Setting Actions
-(IBAction)logout:(id)sender;
@end
