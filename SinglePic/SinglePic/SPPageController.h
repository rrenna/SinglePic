//
//  SPPageController.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPPageContainerDelegate.h"
#import "SPPageContentDelegate.h"
#import "SPStyledView.h"

//iPhone screen coorindates (in portrait mode) for the various Tab states
#define PAGE_POS_LEFT_OFFSCREEN -275
#define PAGE_POS_LEFT_MAXIMIZED 0
#define PAGE_SNAP_BUFFER 50

@interface SPPageController : UIViewController <UIGestureRecognizerDelegate>
{
    IBOutlet UIView* transparentInsetView;
    IBOutlet UIImageView *handleImageView;
    IBOutlet UIView* contentView;
@protected
    NSInteger dragStart_;
    NSInteger lastDragOffset_;
    UIPanGestureRecognizer *panRecognizer_;
    UIViewController* controller_;
}
@property (assign) id <SPPageContainerDelegate> containerDelegate;

-(void)close;
//Set Content
-(void)setController:(UIViewController*)controller;
-(void)setContent:(UIView *)view;
//
- (void) removeObservationFromContentController;
- (void) addObservationForContentController;
@end
