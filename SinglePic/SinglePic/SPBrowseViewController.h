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
    BOOL isDragging;
    BOOL isLoading;
    BOOL isRestarting;
	NSTimer *tickTimer;
    NSTimer *dropTimer;
    NSMutableArray* queuedSelectorCalls;
    //Stack Management
    int stackCount[3];
    BOOL stackPaused[3];
}
-(void)setup;
-(void)visible;


-(IBAction)restart:(id)sender;
-(IBAction)next:(id)sender;
-(IBAction)reportToggle:(id)sender;
@end


@interface _SPBrowseViewQueuedSelectorCall : NSObject
@property (assign) int ticks;
@property (assign) SEL selector;
@end
