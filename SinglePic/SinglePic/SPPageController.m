//
//  SPPageController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPPageController.h"

@interface SPPageController()
-(void)setHandleImage;
-(int)snapOffsetForPosition:(int)leftPosition withOriginPosition:(int)originPosition;
-(void)handlePanFrom:(UIPanGestureRecognizer *)recognizer;
-(void)pushModalContentWithNotification:(NSNotification*)notification;
-(void)pushModalControllerWithNotification:(NSNotification*)notification;
-(void)setFullScreenWithNotification:(NSNotification*)notification;
-(void)minimizeContainerWithNotification:(NSNotification*)notification;
@end

@implementation SPPageController

-(void)viewDidLoad
{
    [super viewDidLoad];
}
- (void) setHandleImage
{
    //Add right-side parchment 9-slice
    UIImage* rightImage9Slice = [[UIImage imageNamed:@"Paper-Right.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:50];
    handleImageView.image = rightImage9Slice;
}
#pragma mark - Observation
-(void) addObservationForContentController
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(minimizeContainerWithNotification:) name:NOTIFICATION_PAGE_MINIMIZE_CONTAINER object:controller_];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(close) name:NOTIFICATION_PAGE_CLOSE object:controller_];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replacePageWithNotification:) name:NOTIFICATION_PAGE_REPLACE_WITH_CONTENT object:controller_];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushModalContentWithNotification:) name:NOTIFICATION_PAGE_PUSH_MODAL_CONTENT object:controller_];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushModalControllerWithNotification:) name:NOTIFICATION_PAGE_PUSH_MODAL_CONTROLLER object:controller_];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFullScreenWithNotification:) name:NOTIFICATION_PAGE_SET_FULLSCREEN object:controller_];
}
- (void) removeObservationFromContentController
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PAGE_MINIMIZE_CONTAINER object:controller_];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PAGE_CLOSE object:controller_];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PAGE_REPLACE_WITH_CONTENT object:controller_];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PAGE_PUSH_MODAL_CONTENT object:controller_];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PAGE_PUSH_MODAL_CONTROLLER object:controller_];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PAGE_SET_FULLSCREEN object:controller_];
}
#pragma mark
-(void)close
{
    int originOffset = -self.view.left + PAGE_POS_LEFT_OFFSCREEN;
    [self moveStackWithOffset:originOffset animated:YES userDragging:NO onCompletion:^(BOOL finished) 
     {
         [self.containerDelegate removePage:self];
     }];
    
    [super close];
}
-(void)replacePageWithNotification:(NSNotification*)notification
{
    id replacement = [notification.userInfo objectForKey:KEY_CONTENT];
    [self.containerDelegate replacePage:self withNewPageContaining:replacement];
}
-(void)setFullScreenWithNotification:(NSNotification*)notification
{
    NSNumber* fullscreenNumber = [notification.userInfo objectForKey:KEY_FULLSCREEN];
    NSNumber* fullscreenAnimatedNumber = [notification.userInfo objectForKey:KEY_FULLSCREEN_ANIMATED];
    
    if(fullscreenAnimatedNumber)
    {
        [self.containerDelegate setFullscreen:[fullscreenNumber boolValue] animated:[fullscreenAnimatedNumber boolValue]];
    }
    else
    {
        [self.containerDelegate setFullscreen:[fullscreenNumber boolValue]];
    }
}
-(void)pushModalContentWithNotification:(NSNotification*)notification
{
    id replacement = [notification.userInfo objectForKey:KEY_CONTENT];
    [self.containerDelegate pushModalContent:replacement];
}
-(void)pushModalControllerWithNotification:(NSNotification*)notification
{
    id replacement = [notification.userInfo objectForKey:KEY_CONTENT];
    [self.containerDelegate pushModalController:replacement];
}
-(void)minimizeContainerWithNotification:(NSNotification*)notification
{
    id container = self.containerDelegate;
    [container minimize];
}
#pragma mark - Touch Handling
-(int)snapOffsetForPosition:(int)leftPosition withOriginPosition:(int)originPosition 
{
    const int numberOfSnapPoints = 2;
    int differences[numberOfSnapPoints] = {leftPosition - PAGE_POS_LEFT_OFFSCREEN,leftPosition - PAGE_POS_LEFT_MAXIMIZED};
    
    int selectedIndex;
    
    //There are two ways we select which position to move the page. 
    // - First we check if we're within a buffer zone. An amount of points around a position that the page can be moved, where it'll bounce back into it's initial position.
    if(abs(differences[0]) < PAGE_SNAP_BUFFER)
    {
        selectedIndex = 0;
    }
    else if(abs(differences[1]) < PAGE_SNAP_BUFFER)
    {
        selectedIndex = 1;
    }
    // - The second strategy, when the tab has been moved outside the buffer zone, is to slide to the nearest point to the left.
    else
    {
        BOOL isMovingLeft = (self.view.left < originPosition);  
        if(isMovingLeft)
        {
            if(differences[1] > 0)
            {
                selectedIndex = 1;
            }
            else
            {
                selectedIndex = 0;
            }
        }
        else
        {        
            if(differences[0] < 0)
            {
                selectedIndex = 0;
            }
            else
            {
                selectedIndex = 1;
            }
        }
        
    }
        
    return -1 * differences[selectedIndex];
}
- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer 
{
    //Fullscreen tabs cannot be panned
    if(![self.containerDelegate fullscreen])
    {
        CGPoint translatedPoint = [recognizer translationInView:self.view];
        UIGestureRecognizerState state = recognizer.state;
        
        // reset last offset if gesture just started
        if (state == UIGestureRecognizerStateBegan) 
        {
            dragStart_ = self.view.left;
            lastDragOffset_ = 0;
        }
        
        NSInteger offset = translatedPoint.x - lastDragOffset_;
        if(self.view.left >= PAGE_POS_LEFT_MAXIMIZED  && offset > 0)
        {   
            //Don't allow any movement past this point
            offset = 0;
        }
        
        [self moveStackWithOffset:offset animated:NO userDragging:YES];
        
        // save last point to calculate new offset
        if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
            lastDragOffset_ = translatedPoint.x;
        }
        
        // perform snapping after gesture ended
        BOOL gestureEnded = state == UIGestureRecognizerStateEnded;
        if (gestureEnded) 
        {
            NSInteger snapOffset = [self snapOffsetForPosition:self.view.left withOriginPosition:dragStart_];
            
            //This dragging operation will end in the minmized position
            if(snapOffset + self.view.left <= PAGE_POS_LEFT_OFFSCREEN)
            {
                //After the animation completes, have the page close
                [self moveStackWithOffset:snapOffset animated:YES userDragging:NO onCompletion:^(BOOL finished) 
                {
                    [self close];
                }];
            }
            else
            {
                [self moveStackWithOffset:snapOffset animated:YES userDragging:NO];
            }
        }
    }
}
@end
