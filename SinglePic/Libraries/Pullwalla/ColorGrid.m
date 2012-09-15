//
//  ColorGrid.m
//  ColorScratchPath
//
//  Created by Nathanael De Jager on 12-01-24.
//  Copyright (c) 2012 Nathanael De Jager. All rights reserved.
//

#import "ColorGrid.h"
#import "ColorBlock.h"

@implementation ColorGrid

@synthesize colors;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Initialize with an array of colors (strings of hex)
- (id)initWithFrame:(CGRect)frame colors:(NSArray *)gridColors
{
    self = [self initWithFrame:frame];
    if(self)
    {
        NSScanner *scanner = nil;
        colors = [NSMutableArray arrayWithCapacity:[gridColors count]];
        unsigned colorHex;
        
        for (NSString *color in gridColors)
        {
            scanner = [NSScanner scannerWithString:color];
            
            [scanner scanHexInt:&colorHex];
            UIColor *currentColor = OPAQUE_HEXCOLOR(colorHex);
            
            [colors addObject:currentColor];
        }
        
        [self drawRow];
    }
    
    return self;
}

// Draw a grid of animated colors (displayed during loading)
- (void)drawGrid
{
    [self removeAllSubviews];
    
    for( int row = 0; row < ROWS; row++)
    {
        for( int column = 0; column < COLUMNS; column++)
        {
            ColorBlock *colorBlock = [[[ColorBlock alloc] initWithFrame:CGRectMake(column * CELL_DIMENSION, row * CELL_DIMENSION, CELL_DIMENSION, CELL_DIMENSION)
                                                                colors:colors 
                                                         startingIndex:0
                                                         shouldAnimate:YES] autorelease];
            
            [self addSubview:colorBlock];
        }
    }
}

// Draw a row of static colors (displayed during a pull).
- (void)drawRow
{
    [self removeAllSubviews];
    
    for( int column = 0; column < COLUMNS; column++)
    {
        ColorBlock *colorBlock = [[[ColorBlock alloc] initWithFrame:CGRectMake(column * CELL_DIMENSION, 0, CELL_DIMENSION, CELL_DIMENSION * ROWS - 1)
                                                            colors:colors 
                                                     startingIndex:column % [colors count]
                                                     shouldAnimate:NO] autorelease];
        
        [self addSubview:colorBlock];
    }
}

// Remove all the blocks and columns
- (void)removeAllSubviews
{
    for (ColorBlock *view in self.subviews) {
        [view stopAnimation];
        [view removeFromSuperview];
    }
}

@end
