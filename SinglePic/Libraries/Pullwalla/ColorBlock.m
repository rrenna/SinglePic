//
//  ColorBlock.m
//  ColorScratchPath
//
//  Created by Nathanael De Jager on 12-01-22.
//  Copyright (c) 2012 Nathanael De Jager. All rights reserved.
//

#import "ColorBlock.h"

#define TIMES_STEPS 4

@implementation ColorBlock

@synthesize colors;
@synthesize animate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

// Initialize with array of colors, a starting index (used in static vs animated rendering) and an animation flag.
- (id)initWithFrame:(CGRect)frame colors:(NSArray *)gridColors startingIndex:(int)startingIndex shouldAnimate:(BOOL)shouldAnimate
{
    self = [self initWithFrame:frame];
    
    animate = shouldAnimate;
    self.colors = gridColors;
    index = startingIndex;
    
    // Offset this block's animation so the grid doesn't blink in sync
    transitionDuration = ((arc4random() % TIMES_STEPS) + 1)*.10;
    
    [self startAnimation];
    
    return self;
    
}

// Animate or render the block depending on the current value of the animation flag
- (void)startAnimation {

    [UIView animateWithDuration:transitionDuration
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut
                     animations:^
     {
         if( animate )
         {
             int count = [colors count];
             index = arc4random() % count;
         }
         
         self.backgroundColor = [colors objectAtIndex:index];
     }
                     completion:^(BOOL finished) {
                         if( [self animate] )
                         {
                             [self startAnimation];
                         }
                     }
     ];    
}

// Stop animation, used in cleaning up the block
- (void)stopAnimation 
{
    [self setAnimate:NO];
}

@end
