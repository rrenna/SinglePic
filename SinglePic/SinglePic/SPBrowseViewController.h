//
//  SPBrowseScreenController.h
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-23.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPTabContentViewController.h"

#define NOTIFICATION_BROWSE_SCREEN_PROFILE_SELECTED @"NOTIFICATION_BROWSE_SCREEN_PROFILE_SELECTED"

@protocol SPBlockViewDelegate;

@interface SPBrowseViewController : SPTabContentViewController <SPBlockViewDelegate,UIScrollViewDelegate>
{
    IBOutlet __weak UIScrollView* scrollView;
    IBOutlet __weak UIView* canvasView; 
    IBOutlet __weak UILabel* browseInstructionsLabel;
}

-(void)setup;

-(IBAction)restart:(id)sender;
-(IBAction)next:(id)sender;

@end

@interface _SPBrowseViewQueuedSelectorCall : NSObject
@property (assign) int ticks;
@property (assign) SEL selector;
@end
