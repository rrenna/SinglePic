//
//  SPTabController.m
//  SinglePic
//
//  Created by Ryan Renna on 11-12-07.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPTabController.h"
#import "SPCameraController.h"

//iPhone screen coorindates (in portrait mode) for the various Tab states
#define TAB_POS_LEFT_OFFSCREEN -385
#define TAB_POS_LEFT_MINIMIZED -324
#define TAB_POS_LEFT_MAXIMIZED -58
#define TAB_POS_LEFT_FULLSCREEN -14

#define TAB_CONTENT_POS_LEFT 25
#define TAB_CONTENT_POS_LEFT_FULLSCREEN 14
#define TAB_CONTENT_WIDTH 305
#define TAB_CONTENT_WIDTH_FULLSCREEN 320

@interface SPTabController()
{
    NSMutableArray* pages;
}
@property(nonatomic, assign) NSInteger firstVisibleIndex;
@property(nonatomic, assign) CGFloat floatIndex;

-(SPPageController*)createPage;
-(void)addObservationForContentController;
-(void)removeObservationFromContentController;
-(void)replaceTabWithNotification:(NSNotification*)notification;
-(SHEET_STATE)sheetStateForPosition:(int)leftPosition withOriginPosition:(int)originPosition;
-(void)handlePanFrom:(UIPanGestureRecognizer *)recognizer;
-(void)pushModalContentWithNotification:(NSNotification*)notification;
-(void)pushModalControllerWithNotification:(NSNotification*)notification;
-(void)setFullScreenWithNotification:(NSNotification*)notification;
@end

@implementation SPTabController
@dynamic fullscreen;

#pragma mark - Dynamic Properties
-(void)setFullscreen:(BOOL)fullscreen_
{
    [self setFullscreen:fullscreen_ animated:YES];
}
-(void)setFullscreen:(BOOL)fullscreen_ animated:(BOOL)animated_
{
    state_ = (fullscreen_ == YES) ? SHEET_STATE_FULLSCREEN : SHEET_STATE_MAXIMIZED;
    [self transformToState:state_ shouldAnimate:animated_];
}
-(BOOL)fullscreen
{
    return (state_ == SHEET_STATE_FULLSCREEN);
}

#pragma mark - View lifecycle
-(id)initWithState:(SHEET_STATE)state
{
    self = [self initWithNibName:@"SPTabController" bundle:nil];
    if(self)
    {
        pages = [NSMutableArray new];
        state_ = state;
    }
    return self;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.left = TAB_POS_LEFT_OFFSCREEN;
}
- (void)viewDidAppear:(BOOL)animated
{
    //Don't attempt any tab placement + animation until properly resized
    [self transformToState:state_ shouldAnimate:YES];
}
- (void) setHandleImage
{
    //Add right-side parchment 9-slice
    UIImage* rightImage9Slice = [[UIImage imageNamed:@"Parchment-Right-9Slice.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:100];           
    handleImageView.image = rightImage9Slice;
    handleImageView.frame = CGRectMake(325, 0, 54, self.view.height);
    handleImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view insertSubview:handleImageView aboveSubview:transparentInsetView];
}
-(void)maximize
{
    [self maximizeIsFullscreen:NO];
}
-(void)maximizeIsFullscreen:(BOOL)fullscreen
{
    //Used to inform the content cotroller that we will be maximizing the tab
    if([controller_ respondsToSelector:@selector(willMaximize)])
    {
        [controller_ performSelector:@selector(willMaximize)];
    }

    state_ = (fullscreen) ? SHEET_STATE_FULLSCREEN : SHEET_STATE_MAXIMIZED;
    
    //Since this helper function will be setting the FULLSCREEN property, it does the 'right' things using this private method
    [self transformToState:state_ shouldAnimate:YES];
}
-(void)close
{
        int originOffset = -self.view.left + TAB_POS_LEFT_OFFSCREEN;
        [self moveStackWithOffset:originOffset animated:YES userDragging:NO onCompletion:^(BOOL finished)
        {
            [self.containerDelegate removeTab:self];
        }];
    
        [super close];
}
-(void)setController:(UIViewController *)controller
{
    [super setController:controller];
    
    //Camera controller has a unique handle image
    if([controller isKindOfClass:[SPCameraController class]])
    {
        //Add right-side parchment 9-slice
        UIImage* rightImage9Slice = [[UIImage imageNamed:@"Parchment-Right-Camera.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:115];
        handleImageView.image = rightImage9Slice;
    }
}
-(void)pushModalController:(UIViewController*)viewController
{
    SPPageController* page = [self createPage];
    [page setController:viewController];
}
-(void)pushModalContent:(UIView*)view
{
    SPPageController* page = [self createPage];
    [page setContent:view];
}
#pragma marl - IBActions
- (IBAction)toggleTabState:(id)sender
{
    if(state_ == SHEET_STATE_MINIMIZED)
    {
        [self maximize];
    }
    else if(state_ == SHEET_STATE_MAXIMIZED)
    {
        [self minimize];
    }
}
#pragma mark - Private methods
- (void) removeObservationFromContentController
{
    [super removeObservationFromContentController];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_TAB_MINIMIZE object:controller_];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_TAB_CLOSE object:controller_];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_TAB_REPLACE_WITH_CONTENT object:controller_];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_TAB_PUSH_MODAL_CONTROLLER object:controller_];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_TAB_PUSH_MODAL_CONTENT object:controller_];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_TAB_SET_FULLSCREEN object:controller_];
}
-(void) addObservationForContentController
{
    [super addObservationForContentController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(minimize) name:NOTIFICATION_TAB_MINIMIZE object:controller_];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(close) name:NOTIFICATION_TAB_CLOSE object:controller_];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replaceTabWithNotification:) name:NOTIFICATION_TAB_REPLACE_WITH_CONTENT object:controller_];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushModalControllerWithNotification:) name:NOTIFICATION_TAB_PUSH_MODAL_CONTROLLER object:controller_];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushModalContentWithNotification:) name:NOTIFICATION_TAB_PUSH_MODAL_CONTENT object:controller_];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFullScreenWithNotification:) name:NOTIFICATION_TAB_SET_FULLSCREEN object:controller_];
}
-(void)replaceTabWithNotification:(NSNotification*)notification
{
    id replacement = [notification.userInfo objectForKey:KEY_CONTENT];
    [self.containerDelegate replaceTab:self withNewTabContaining:replacement];
}
-(void)setFullScreenWithNotification:(NSNotification*)notification
{
    NSNumber* fullscreenNumber = [notification.userInfo objectForKey:KEY_FULLSCREEN];
    NSNumber* fullscreenAnimatedNumber = [notification.userInfo objectForKey:KEY_FULLSCREEN_ANIMATED];
    
    if(fullscreenAnimatedNumber)
    {
        [self setFullscreen:[fullscreenNumber boolValue] animated:[fullscreenAnimatedNumber boolValue]];
    }
    else
    {
        [self setFullscreen:[fullscreenNumber boolValue]];
    }
}
-(void)pushModalContentWithNotification:(NSNotification*)notification
{
    id replacement = [notification.userInfo objectForKey:KEY_CONTENT];
    [self pushModalContent:replacement];
}
-(void)pushModalControllerWithNotification:(NSNotification*)notification
{
    id replacement = [notification.userInfo objectForKey:KEY_CONTENT];
    [self pushModalController:replacement];
}
-(void)transformToState:(SHEET_STATE)state shouldAnimate:(BOOL)shouldAnimate
{
    [super transformToState:state shouldAnimate:shouldAnimate];
    
    int tabViewLeft,contentViewLeft,contentViewWidth;
    
    switch(state)
    {
        case SHEET_STATE_FULLSCREEN:
            tabViewLeft = TAB_POS_LEFT_FULLSCREEN;
            contentViewLeft = TAB_CONTENT_POS_LEFT_FULLSCREEN;
            contentViewWidth = TAB_CONTENT_WIDTH_FULLSCREEN;
            break;
        case SHEET_STATE_MAXIMIZED:
            tabViewLeft = TAB_POS_LEFT_MAXIMIZED;
            contentViewLeft = TAB_CONTENT_POS_LEFT;
            contentViewWidth = TAB_CONTENT_WIDTH;
            break;
        case SHEET_STATE_MINIMIZED:
            tabViewLeft = TAB_POS_LEFT_MINIMIZED;
            contentViewLeft = TAB_CONTENT_POS_LEFT;
            contentViewWidth = TAB_CONTENT_WIDTH;
            break;
    }
    
    contentView.width = contentViewWidth;
    contentView.left = contentViewLeft;
    
    if(shouldAnimate)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.left = tabViewLeft;
        }];
    }
    else
    {
        self.view.left = tabViewLeft;
    }
}
#pragma mark - Touch Handling
-(SHEET_STATE)sheetStateForPosition:(int)leftPosition withOriginPosition:(int)originPosition
{
    const int numberOfSnapPoints = 2;
    int differences[numberOfSnapPoints] = {leftPosition - TAB_POS_LEFT_MINIMIZED,leftPosition - TAB_POS_LEFT_MAXIMIZED};
    SHEET_STATE states[3] = {SHEET_STATE_MINIMIZED, SHEET_STATE_MAXIMIZED};
    
    int selectedIndex;
    
        //There are two ways we select which position to move the tab.
        // - First we check if we're within a buffer zone. An amount of points around a position that the tab can be moved, where it'll bounce back into it's initial position.
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
    
    return states[selectedIndex];
}
- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer 
{
    //Fullscreen tabs cannot be panned
    if(![self fullscreen])
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
        //If we're sliding to the right, revealing the hidden view
        // the closer we get to the hidden view, the slower we move the tab
        if(self.view.left >= -secretEdgeView.width  && offset > 0)
        {
            /*
             float slowFactor = ABS(self.view.left) / secretEdgeView.width;
            offset *= slowFactor;
            if(offset < 0.1) { offset = 1; }
            else if(offset <= 1) { offset = 1; }
            else { offset = 2; }
             */
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
            SHEET_STATE targetState = [self sheetStateForPosition:self.view.left withOriginPosition:dragStart_];
            
            if(targetState == SHEET_STATE_MINIMIZED)
            {
                [self minimize];
            }
            else if(targetState == SHEET_STATE_MAXIMIZED)
            {
                [self maximize];
            }
        }

    }
}
#pragma mark - SPPageContainerDelegate methods
-(SPPageController*)createPage
{
    SPPageController* page = [[SPPageController alloc] initWithNibName:@"SPPageController" bundle:nil];
    page.containerDelegate = self;
    page.view.left = PAGE_POS_LEFT_OFFSCREEN;
    page.view.height = self.view.height;
    
    [self.view addSubview:page.view];
    [pages addObject:page];
    
     //Animate tab on-screen

    [UIView animateWithDuration:0.5 animations:^
     {
         //Push all current pages 5px to the right
         /*
          for(SPPageController* currentPage in pages)
         {
             currentPage.view.left += 5;
         }*/
         
        page.view.left = PAGE_POS_LEFT_MAXIMIZED;
     } 
     completion:^(BOOL finished) 
     {
     }];
    
    return page;
}
-(void) replacePage:(SPPageController*)page withNewPageContaining:(id)replacement
{
    if([replacement isKindOfClass:[UIViewController class]])
    {
        [self pushModalController:replacement];
    }
    else
    {
        [self pushModalContent:replacement];
    }
    
    [page close];
}
-(void)removePage:(SPPageController*)page
{
    [page.view removeFromSuperview];
    [pages removeObject:page];
    
    /*
    //Animate remaining pages
    [UIView animateWithDuration:0.5 animations:^
     {
         //Push all current pages 5px to the left
         for(SPPageController* currentPage in pages)
         {
             currentPage.view.left -= 5;
         }
    }];
     */
}
-(void)closeAllPages
{
    for(SPPageController* page in pages)
    {
        [page close];
    }
}
@end
