//
//  SPTabController.m
//  SinglePic
//
//  Created by Ryan Renna on 11-12-07.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPTabController.h"
#import "SPCameraController.h"

@interface SPTabController()
@property(nonatomic, assign) NSInteger firstVisibleIndex;
@property(nonatomic, assign) CGFloat floatIndex;
-(SPPageController*)createPage;
-(void)addObservationForContentController;
-(void)removeObservationFromContentController;
-(void)replaceTabWithNotification:(NSNotification*)notification;
-(int)snapOffsetForPosition:(int)leftPosition withOriginPosition:(int)originPosition;
-(void)handlePanFrom:(UIPanGestureRecognizer *)recognizer;
-(void)pushModalContentWithNotification:(NSNotification*)notification;
-(void)pushModalControllerWithNotification:(NSNotification*)notification;
-(void)setFullScreenWithNotification:(NSNotification*)notification;
@end

@implementation SPTabController
@dynamic fullscreen;
@synthesize containerDelegate;
@synthesize firstVisibleIndex,floatIndex;//Private

#pragma mark - Dynamic Properties
-(void)setFullscreen:(BOOL)fullscreen_
{
    fullscreen = fullscreen_;
    
    int tabViewLeft,contentViewLeft,contentViewWidth;
    
    if(fullscreen)
    {
        tabViewLeft = TAB_POS_LEFT_FULLSCREEN;
        contentViewLeft = TAB_CONTENT_POS_LEFT_FULLSCREEN;
        contentViewWidth = TAB_CONTENT_WIDTH_FULLSCREEN;
    }
    else
    {
        tabViewLeft = TAB_POS_LEFT_MAXIMIZED;
        contentViewLeft = TAB_CONTENT_POS_LEFT;
        contentViewWidth = TAB_CONTENT_WIDTH;
    }

    contentView.width = contentViewWidth;
    contentView.left = contentViewLeft;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.left = tabViewLeft;
    }];
}
-(BOOL)fullscreen
{
    return fullscreen;
}
#pragma mark - View lifecycle
-(id)initIsFullscreen:(BOOL)fullscreen_
{
    self = [self initWithNibName:@"SPTabController" bundle:nil];
    if(self)
    {
        fullscreen = fullscreen_;
        pages = [NSMutableArray new];
        fullscreen = fullscreen_;
    }
    return self;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.left = TAB_POS_LEFT_OFFSCREEN;
    self.fullscreen = fullscreen;
}
-(void)dealloc
{
    [pages release];
    [handleImageView release];
    [super dealloc];
}
-(void)maximize
{
    int originOffset = -self.view.left + TAB_POS_LEFT_MAXIMIZED;    
    [self moveStackWithOffset:originOffset animated:YES userDragging:NO onCompletion:^(BOOL finished) 
     {
     }];
}
-(void)minimize
{
    //Used to inform the content cotroller that we will be minimizing the tab
    if([controller_ respondsToSelector:@selector(willMinimize)])
    {
        [controller_ performSelector:@selector(willMinimize)];
    }
    
    int originOffset = -self.view.left + TAB_POS_LEFT_MINIMIZED;    
    [self moveStackWithOffset:originOffset animated:YES userDragging:NO onCompletion:^(BOOL finished) 
    {
    }];
}
-(void)close
{
    //Used to inform the content cotroller that we will be closing the tab
    if([controller_ respondsToSelector:@selector(willClose)])
    {
        [controller_ performSelector:@selector(willClose)];
    }
    
    int originOffset = -self.view.left + TAB_POS_LEFT_OFFSCREEN;
    [self moveStackWithOffset:originOffset animated:YES userDragging:NO onCompletion:^(BOOL finished) 
     {
         [self.containerDelegate removeTab:self];
     }];
}
-(void)setController:(UIViewController *)controller
{
    [super setController:controller];
    
    //Camera controller has a unique handle image
    if([controller isKindOfClass:[SPCameraController class]])
    {
        handleImageView.image = [UIImage imageNamed:@"Parchment-Right-Camera"];
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
    [self setFullscreen:[fullscreenNumber boolValue]];
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
#pragma mark - Touch Handling
-(int)snapOffsetForPosition:(int)leftPosition withOriginPosition:(int)originPosition
{
    const int numberOfSnapPoints = 2;
    int differences[numberOfSnapPoints] = {leftPosition - TAB_POS_LEFT_MINIMIZED,leftPosition - TAB_POS_LEFT_MAXIMIZED};
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
       
    return -1 * differences[selectedIndex];
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
            NSInteger snapOffset = [self snapOffsetForPosition:self.view.left withOriginPosition:dragStart_];
            [self moveStackWithOffset:snapOffset animated:YES userDragging:NO];
        }

    }
}
#pragma mark - SPPageContainerDelegate methods
-(SPPageController*)createPage
{

    SPPageController* page = [[[SPPageController alloc] initWithNibName:@"SPPageController" bundle:nil] autorelease];
    page.containerDelegate = self;
    page.view.left = PAGE_POS_LEFT_OFFSCREEN;
    [self.view addSubview:page.view];
    [pages addObject:page];
    
     //Animate tab on-screen
     [UIView animateWithDuration:0.5 animations:^
     {
         //Push all current pages 5px to the right
         for(SPPageController* currentPage in pages)
         {
             currentPage.view.left += 5;
         }
         
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
    
    //Animate remaining pages
    [UIView animateWithDuration:0.5 animations:^
     {
         //Push all current pages 5px to the left
         for(SPPageController* currentPage in pages)
         {
             currentPage.view.left -= 5;
         }
    }];
}
-(void)closeAllPages
{
    for(SPPageController* page in pages)
    {
        [page close];
    }
}
@end
