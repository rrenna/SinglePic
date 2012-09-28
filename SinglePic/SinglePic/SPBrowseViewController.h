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

struct b2World;
struct b2Body;

@interface SPBrowseViewController : SPTabContentViewController <SPBlockViewDelegate,UIScrollViewDelegate>
{
    IBOutlet UIScrollView* scrollView;
    IBOutlet UIView* canvasView; 
    IBOutlet UIView* centerBottomView;
    IBOutlet UILabel* browseInstructionsLabel;
    
    @private
    //Box2D
    struct b2World* world;
    struct b2Body* groundBody;
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
