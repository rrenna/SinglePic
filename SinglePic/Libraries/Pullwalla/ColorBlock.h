//
//  ColorBlock.h
//  ColorScratchPath
//
//  Created by Nathanael De Jager on 12-01-22.
//  Copyright (c) 2012 Nathanael De Jager. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorBlock : UIView
{
    uint index;
    float transitionDuration;
}

@property(nonatomic, retain) NSArray *colors;
@property(nonatomic, assign) BOOL animate;

- (id)initWithFrame:(CGRect)frame colors:(NSArray *)gridColors startingIndex:(int)startingIndex shouldAnimate:(BOOL)shouldAnimate;

- (void)startAnimation;
- (void)stopAnimation;


@end
