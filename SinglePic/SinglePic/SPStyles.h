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
    STYLE_NEUTRAL = 0,
    STYLE_WHITE = 1,
    STYLE_TAB = 2,
    STYLE_PAGE = 3,
    STYLE_BASE = 4,
    STYLE_CONFIRM_BUTTON = 5,
    STYLE_ALTERNATIVE_ACTION_1_BUTTON = 6,
    STYLE_ALTERNATIVE_ACTION_2_BUTTON = 7,
    STYLE_NAVIGATION = 8,
    STYLE_CHARCOAL = 9
} STYLE;

typedef enum
{
    DEPTH_INSET = 0,
    DEPTH_OUTSET = 1
} DEPTH;

//The default Style is a light gray neutral colour
#define STYLE_DEFAULT STYLE_NEUTRAL
//The default Depth is an 3d inset look
#define DEPTH_DEFAULT DEPTH_INSET
//Inset Colours
#define INSET_CORNER_RADIUS 6.0
#define INSET_BEVEL_LIGHT_COLOUR [UIColor colorWithWhite:1.0 alpha:0.3]
#define INSET_BEVEL_DARK_COLOUR [UIColor colorWithWhite:0.0 alpha:0.5]
#define INSET_EDGE_DARK_COLOUR [UIColor colorWithWhite:0.0 alpha:0.25]//Inset vs Outset diff
#define OUTSET_EDGE_DARK_COLOUR [UIColor colorWithWhite:0.0 alpha:0.25]//Inset vs Outset diff
#define CONTROL_EDGE_DARK_COLOUR [UIColor colorWithWhite:0.0 alpha:0.35]
//Custom Edges for Styles
#define CONFIRM_BUTTON_EDGE_COLOUR [UIColor colorWithRed:0.003 green:0.235 blue:0.513 alpha:0.75]
//
#define INSET_GRADIENT_BACKGROUND_START_COLOUR [UIColor colorWithWhite:1 alpha:0.05]
#define INSET_GRADIENT_BACKGROUND_END_COLOUR [UIColor colorWithWhite:0.2 alpha:0.05]//View vs Control diff                                                                     
//Custom Gradients for Styles
//-- Some styles have specific gradient colours assigned
//-- By default they will use their tint colour
#define BACKGROUND_GRADIENT_CONFIRM_BUTTON_START_COLOUR [UIColor colorWithRed:0.0 green:0.70 blue:0.84 alpha:1.0]
#define BACKGROUND_GRADIENT_CONFIRM_BUTTON_END_COLOUR [UIColor colorWithRed:0.0 green:0.42 blue:0.6 alpha:1.0]
#define BACKGROUND_GRADIENT_NEUTRAL_START_COLOUR [UIColor colorWithRed:0.85 green:0.847 blue:0.847 alpha:1.0]
#define BACKGROUND_GRADIENT_NEUTRAL_END_COLOUR [UIColor colorWithRed:0.733 green:0.733 blue:0.733 alpha:1.0]
#define BACKGROUND_GRADIENT_BASE_START_COLOUR [UIColor colorWithWhite:1 alpha:0.1]
#define BACKGROUND_GRADIENT_BASE_END_COLOUR [UIColor colorWithWhite:0.1 alpha:0.2]
#define BACKGROUND_GRADIENT_NAVIGATION_START_COLOUR [UIColor colorWithRed:0.556 green:0.192 blue:0.196 alpha:0.4]
#define BACKGROUND_GRADIENT_NAVIGATION_END_COLOUR [UIColor colorWithRed:0.43 green:0.16 blue:0.156 alpha:0.4]
//Tints for Styles
#define TINT_DEFAULT [UIColor colorWithWhite:0.8 alpha:1.0]
#define TINT_WHITE [UIColor colorWithWhite:1.0 alpha:1.0]
#define TINT_TAB [UIColor colorWithRed:0.927 green:0.892 blue:0.857 alpha:0.95]
#define TINT_BASE [UIColor colorWithRed:0.546 green:0.15 blue:0.15 alpha:1.0]
#define TINT_PAGE [UIColor colorWithRed:0.97 green:0.95 blue:0.9 alpha:1.0]
#define TINT_CONFIRM_BUTTON [UIColor colorWithRed:0.0 green:0.513 blue:0.686 alpha:1.0]
#define TINT_ALTERNATIVE_ACTION_1_BUTTON [UIColor colorWithRed:0.905 green:0.662 blue:0.0 alpha:1.0]
#define TINT_ALTERNATIVE_ACTION_2_BUTTON [UIColor colorWithRed:0.47 green:0.85 blue:0.12 alpha:1.0]
#define TINT_CHARCOAL [UIColor colorWithWhite:0.33 alpha:1.0]

@protocol SPStyle <NSObject>
-(void)setStyle:(STYLE)style;
-(void)setDepth:(DEPTH)depth;
@end

//Helper function to retrieve the primary colors from a specific style
UIColor* primaryColorForStyle(STYLE style);
//Helper functions used to construct CALayers for SPStyledView & SPStyledButton subclasses
//--Bevel Layer
CAGradientLayer* setupBevelLayerForView(UIView* view);
//--Gradient Layer
void updateColorGradientLayerForControlWithStyle(CAGradientLayer* layer, STYLE style);
CAGradientLayer* setupColorGradientLayerForControlWithStyle(UIControl* control,STYLE style);
CAGradientLayer* setupColorGradientLayerForViewWithStyle(UIView* view,STYLE style);
//--Color Layer
void updateColorLayerForViewWithStyle(CALayer* layer,STYLE style);
CALayer* setupColorLayerForControl(UIView* view);
CALayer* setupColorLayerForView(UIView* view);
//Helper functions used to place and resize CALayers for SPStyledView & SPStyledButton subclasses
CGRect placeBevelLayerForViewWithDepth(UIView* view,DEPTH depth);
CGRect placeColorGradientLayerForViewWithDepth(UIView* view,DEPTH depth);
CGRect placeColorLayerForViewWithDepth(UIView* view,DEPTH depth);
void setDepthOfControlIncludingBevelLayerAndColorLayerAndColorGradientLayer(DEPTH depth,UIView* view,CAGradientLayer *bevelLayer,CALayer* colorLayer,CAGradientLayer* colorGradientLayer);
void setDepthOfViewIncludingBevelLayerAndColorLayerAndColorGradientLayer(DEPTH depth,UIView* view,CAGradientLayer *bevelLayer,CALayer *colorLayer,CAGradientLayer *colorGradientLayer);