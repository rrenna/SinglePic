//
//  SPInsets.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef enum
{
    STYLE_NEUTRAL,
    STYLE_WHITE,
    STYLE_TAB,
    STYLE_PAGE,
    STYLE_BASE,
    STYLE_CONFIRM_BUTTON,
    STYLE_ALTERNATIVE_ACTION_1_BUTTON,
    STYLE_ALTERNATIVE_ACTION_2_BUTTON
} STYLE;
//The default Style is a light gray neutral colour
#define STYLE_DEFAULT STYLE_NEUTRAL


typedef enum
{
    DEPTH_INSET,
    DEPTH_OUTSET
} DEPTH;
//The default Depth is an 3d inset look
#define DEPTH_DEFAULT DEPTH_INSET


//Inset Colours
#define INSET_CORNER_RADIUS 6.0
#define INSET_BEVEL_LIGHT_COLOUR [UIColor colorWithWhite:1.0 alpha:0.5]
#define INSET_BEVEL_DARK_COLOUR [UIColor colorWithWhite:0.0 alpha:0.5]
#define INSET_EDGE_DARK_COLOUR [UIColor colorWithWhite:0.0 alpha:0.15]//Inset vs Outset diff
#define OUTSET_EDGE_DARK_COLOUR [UIColor colorWithWhite:0.0 alpha:0.25]//Inset vs Outset diff
#define INSET_GRADIENT_BACKGROUND_START_COLOUR [UIColor colorWithWhite:1 alpha:0.05]
#define INSET_GRADIENT_BACKGROUND_END_COLOUR [UIColor colorWithWhite:0.2 alpha:0.05]//View vs Control diff
#define CONTROL_GRADIENT_BACKGROUND_START_COLOUR [UIColor colorWithWhite:1 alpha:0.1]//View vs Control diff
#define CONTROL_GRADIENT_BACKGROUND_END_COLOUR [UIColor colorWithWhite:0.1 alpha:0.2]
//Tints for Styles
#define INSET_TINT_DEFAULT [UIColor colorWithWhite:0.8 alpha:1.0]
#define INSET_TINT_WHITE [UIColor colorWithWhite:1.0 alpha:1.0]
#define INSET_TINT_TAB [UIColor colorWithRed:0.96 green:0.94 blue:0.92 alpha:0.85]
#define INSET_TINT_BASE [UIColor colorWithRed:0.546 green:0.15 blue:0.15 alpha:1.0]
#define INSET_TINT_PAGE [UIColor colorWithRed:0.97 green:0.95 blue:0.9 alpha:1.0]
#define INSET_TINT_CONFIRM_BUTTON [UIColor colorWithRed:0.0 green:0.74 blue:0.86 alpha:1.0]
#define INSET_TINT_ALTERNATIVE_ACTION_1_BUTTON [UIColor colorWithRed:0.905 green:0.662 blue:0.0 alpha:1.0]
#define INSET_TINT_ALTERNATIVE_ACTION_2_BUTTON [UIColor colorWithRed:0.47 green:0.85 blue:0.12 alpha:1.0]

@protocol SPStyle <NSObject>
-(void)setStyle:(STYLE)style;
-(void)setDepth:(DEPTH)depth;
@end

//Helper functions used to construct CALayers for SPStyledView & SPStyledButton subclasses
CAGradientLayer* setupBevelLayerForView(UIView* view);
CAGradientLayer* setupColorGradientLayerForControl(UIControl* control);
CAGradientLayer* setupColorGradientLayerForView(UIView* view);
CALayer* setupColorLayerForView(UIView* view);
//Helper functions used to place and resize CALayers for SPStyledView & SPStyledButton subclasses
CGRect placeBevelLayerForViewWithDepth(UIView* view,DEPTH depth);
CGRect placeColorGradientLayerForViewWithDepth(UIView* view,DEPTH depth);
CGRect placeColorLayerForViewWithDepth(UIView* view,DEPTH depth);
void setDepthOfViewIncludingBevelLayerAndColorLayerAndColorGradientLayer(DEPTH depth,UIView* view,CAGradientLayer *bevelLayer,CALayer *colorLayer,CAGradientLayer *colorGradientLayer);