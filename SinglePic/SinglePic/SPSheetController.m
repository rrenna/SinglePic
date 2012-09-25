//
//  SPSheetController.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-20.
//
//

#import "SPSheetController.h"

@interface SPSheetController ()

@end

@implementation SPSheetController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // add a gesture recognizer to detect dragging to the guest controllers
    panRecognizer_ = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [panRecognizer_ setMaximumNumberOfTouches:1];
    [panRecognizer_ setDelaysTouchesBegan:NO];
    [panRecognizer_ setDelaysTouchesEnded:YES];
    [panRecognizer_ setCancelsTouchesInView:YES];
    panRecognizer_.delegate = self;
    [self.view addGestureRecognizer:panRecognizer_];
    
    //Assign the appropriate image to represent the right handle of the page
    [self  setHandleImage];
}
- (void) setHandleImage
{
}
-(void)viewDidLayoutSubviews
{
    [self.view setPassThroughZone: transparentInsetView.frame];
}
-(void)dealloc
{
    [contentView release];
    [panRecognizer_ release];
    [controller_ release];
    [super dealloc];
}
#pragma mark
-(void)minimize
{
    //Used to inform the content cotroller that we will be minimizing the tab
    if([controller_ respondsToSelector:@selector(willMinimize)])
    {
        [controller_ performSelector:@selector(willMinimize)];
    }
}
-(void)close
{
    [self removeObservationFromContentController];
    
    //Used to inform the content cotroller that we will be closing the tab
    if([controller_ respondsToSelector:@selector(willClose)])
    {
        [controller_ performSelector:@selector(willClose)];
    }
}
#pragma mark - Setting Content
-(void)setController:(UIViewController*)controller
{
    if(controller != controller_)
    {
        //Remove old controller
        if(controller_)
        {
            [self removeObservationFromContentController];
            [controller_ release];
        }
        //Update with new controller
        if(controller)
        {
            controller_ = [controller retain];
            //Listen for specific notifications from the designated content controller
            [self addObservationForContentController];
            
            [self setContent:controller_.view];
        }
    }
}
-(void)setContent:(UIView *)view
{
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if(view)
    {
        view.frame = contentView.bounds;
        [contentView addSubview:view];
    }
}
#pragma mark - Observation
- (void) removeObservationFromContentController
{
}
-(void) addObservationForContentController
{
}
#pragma mark - Touch Handling
- (void)moveStackWithOffset:(NSInteger)offset animated:(BOOL)animated userDragging:(BOOL)userDragging
{
    [self moveStackWithOffset:offset animated:animated userDragging:userDragging onCompletion:nil];
}
// moves the stack to a specific offset.
- (void)moveStackWithOffset:(NSInteger)offset animated:(BOOL)animated userDragging:(BOOL)userDragging onCompletion:(void(^)(BOOL finished))onCompletion
{
    [UIView animateWithDuration:animated ? 0.4f : 0.f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.view.left += offset;
        
    } completion:onCompletion];
}
@end
