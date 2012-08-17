//
//  SPTabController.h
//  SinglePic
//
//  Created by Ryan Renna on 11-12-07.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPPageController.h"
#import "UIView+SizesAndEdges.h"
#import "SPTabContentDelegate.h"
#import "SPTabContainerDelegate.h"


//iPhone screen coorindates (in portrait mode) for the various Tab states
#define TAB_POS_LEFT_OFFSCREEN -385
#define TAB_POS_LEFT_MINIMIZED -324
#define TAB_POS_LEFT_MAXIMIZED -56
#define TAB_POS_LEFT_FULLSCREEN -14

#define TAB_CONTENT_POS_LEFT 25
#define TAB_CONTENT_POS_LEFT_FULLSCREEN 14
#define TAB_CONTENT_WIDTH 305
#define TAB_CONTENT_WIDTH_FULLSCREEN 320

@interface SPTabController : SPPageController <SPPageContainerDelegate>
{
    IBOutlet UIView* handleView;
    IBOutlet UIImageView *handleImageView;
    IBOutlet UIView* secretEdgeView;
@private
    NSMutableArray* pages;
    BOOL fullscreen;
}
@property (assign) id <SPTabContainerDelegate> containerDelegate;
@property (assign) BOOL fullscreen;

-(id)initIsFullscreen:(BOOL)fullscreen;
-(void)maximize;
-(void)minimize;
//Push Sub-Content
-(void)pushModalController:(UIViewController*)viewController;
-(void)pushModalContent:(UIView*)view;
@end
