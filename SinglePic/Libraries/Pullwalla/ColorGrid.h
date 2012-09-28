//
//  ColorGrid.h
//  ColorScratchPath
//
//  Created by Nathanael De Jager on 12-01-24.
//  Copyright (c) 2012 Nathanael De Jager. All rights reserved.
//

#import <UIKit/UIKit.h>

#define OPAQUE_HEXCOLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 \
green:((c>>8)&0xFF)/255.0 \
blue:(c&0xFF)/255.0 \
alpha:1.0];

#define COLUMNS         16
#define ROWS            10
#define CELL_DIMENSION  20

@interface ColorGrid : UIView

@property(nonatomic, strong) NSMutableArray *colors;

- (id)initWithFrame:(CGRect)frame colors:(NSArray *)gridColors;
- (void)drawGrid;
- (void)drawRow;
- (void)removeAllSubviews;
@end
