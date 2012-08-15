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
    IBOutlet UIScrollView* scrollView;
    IBOutlet UIView* canvasView;    
    IBOutlet UIView* leftBottomView;
    IBOutlet UIView* centerBottomView;
    IBOutlet UIView* rightBottomView;
    IBOutlet UILabel* browseInstructionsLabel;
    UIView*  nextHeaderView;
    UILabel* nextLabel;
    UIImageView* nextArrow;
    UIActivityIndicatorView* nextSpinner;
    
    @private
    BOOL paused;
    BOOL isDragging;
    BOOL isLoading;
	NSTimer *tickTimer;
    NSTimer *dropTimer;
    int stackCount[3];
    NSMutableArray* destroyBlockQueue;
    NSMutableArray* queuedSelectorCalls;

}
-(void)setup;
-(void)visible;


-(IBAction)restart:(id)sender;
-(IBAction)next:(id)sender;
-(IBAction)reportToggle:(id)sender;
@end
