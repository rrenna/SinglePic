//
//  SPStyles.m
//  SinglePic
//
//  Created by Ryan Renna on 12-02-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPStyles.h"
#import "UIColor+Expanded.h"

UIColor* primaryColorForStyle(STYLE style)
{
    if(style == STYLE_BASE)
    {
        return TINT_BASE;
    }
    else if(style == STYLE_WHITE)
    {
        return TINT_WHITE;
    }
    else if(style == STYLE_PAGE)
    {
        return TINT_PAGE;
    }
    else if(style == STYLE_TAB)
    {
        return TINT_TAB;
    }
    else if(style == STYLE_CONFIRM_BUTTON)
    {
        return TINT_CONFIRM_BUTTON;
    }
    else if(style == STYLE_ALTERNATIVE_ACTION_1_BUTTON)
    {
        return TINT_ALTERNATIVE_ACTION_1_BUTTON;
    }
    else if(style == STYLE_ALTERNATIVE_ACTION_2_BUTTON)
    {
        return TINT_ALTERNATIVE_ACTION_2_BUTTON;
    }
    
    //STYLE_NEUTRAL or default
    return TINT_DEFAULT;
}
#pragma mark
CAGradientLayer* setupBevelLayerForView(UIView* view)
{
    CAGradientLayer* bevelLayer = [CAGradientLayer layer];
    bevelLayer.frame = 	placeBevelLayerForViewWithDepth(view,DEPTH_DEFAULT);	
    bevelLayer.colors = @[(id)INSET_BEVEL_DARK_COLOUR.CGColor,
                          (id)INSET_BEVEL_LIGHT_COLOUR.CGColor];
    bevelLayer.cornerRadius = INSET_CORNER_RADIUS;
    bevelLayer.needsDisplayOnBoundsChange = YES;
    return bevelLayer;
}

void updateColorGradientLayerForControlWithStyle(CAGradientLayer* layer, STYLE style)
{
    if(style == STYLE_NAVIGATION)
    {
        layer.borderColor = [UIColor colorWithWhite:0.1 alpha:0.55].CGColor;
        
        layer.colors = @[
        (id)BACKGROUND_GRADIENT_NAVIGATION_START_COLOUR.CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.05].CGColor,
        (id)BACKGROUND_GRADIENT_NAVIGATION_START_COLOUR.CGColor,
        (id)BACKGROUND_GRADIENT_NAVIGATION_END_COLOUR.CGColor];
        
        layer.locations = @[[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.02],[NSNumber numberWithFloat:0.04], [NSNumber numberWithFloat:1.0]];
    }
    else
    {
        layer.borderColor = INSET_EDGE_DARK_COLOUR.CGColor;
        
        if(style == STYLE_CONFIRM_BUTTON)
        {
            layer.colors = @[(id)[UIColor whiteColor].CGColor,
            (id)BACKGROUND_GRADIENT_CONFIRM_BUTTON_START_COLOUR.CGColor,
            (id)BACKGROUND_GRADIENT_CONFIRM_BUTTON_END_COLOUR.CGColor];
            
            layer.locations = @[[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.1], [NSNumber numberWithFloat:1.0]];
        }
        else if(style == STYLE_ALTERNATIVE_ACTION_1_BUTTON)
        {
            layer.colors = @[(id)[UIColor whiteColor].CGColor,
            (id)TINT_ALTERNATIVE_ACTION_1_BUTTON.CGColor,
            (id)TINT_ALTERNATIVE_ACTION_1_BUTTON.CGColor];
            
            layer.locations = @[[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.1], [NSNumber numberWithFloat:1.0]];
        }
        else if(style == STYLE_NEUTRAL)
        {
            layer.colors = @[(id)[UIColor whiteColor].CGColor,
            (id)BACKGROUND_GRADIENT_NEUTRAL_START_COLOUR.CGColor,
            (id)BACKGROUND_GRADIENT_NEUTRAL_END_COLOUR.CGColor];
            
            layer.locations = @[[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.1], [NSNumber numberWithFloat:1.0]];
        }
        else if(style == STYLE_BASE)
        {
            layer.colors = @[
            (id)BACKGROUND_GRADIENT_BASE_START_COLOUR.CGColor,
            (id)BACKGROUND_GRADIENT_BASE_END_COLOUR.CGColor];
            
            layer.locations = @[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0]];
        }
        else if(style == STYLE_TAB)
        {
            layer.colors = @[(id)[UIColor whiteColor].CGColor,
            (id)TINT_TAB.CGColor,
            (id)TINT_TAB.CGColor];
            
            layer.locations = @[[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.1], [NSNumber numberWithFloat:1.0]];
        }
        else
        {
            layer.colors = @[
            (id)TINT_DEFAULT.CGColor,
            (id)TINT_DEFAULT.CGColor];
            
            layer.locations = @[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0]];
        }
            
    }
}
CAGradientLayer* setupColorGradientLayerForControlWithStyle(UIControl* control,STYLE style)
{
    CAGradientLayer* colorGradientLayer = [CAGradientLayer layer];
    
    updateColorGradientLayerForControlWithStyle(colorGradientLayer,style);

    colorGradientLayer.cornerRadius = INSET_CORNER_RADIUS;
    colorGradientLayer.needsDisplayOnBoundsChange = YES;
    colorGradientLayer.borderWidth = 1.0f;
    colorGradientLayer.cornerRadius = INSET_CORNER_RADIUS;
    
    return colorGradientLayer;
}
CAGradientLayer* setupColorGradientLayerForViewWithStyle(UIView* view,STYLE style)
{
    CAGradientLayer* colorGradientLayer = [CAGradientLayer layer];	
    colorGradientLayer.colors = [NSArray arrayWithObjects:(id)INSET_GRADIENT_BACKGROUND_START_COLOUR.CGColor, INSET_GRADIENT_BACKGROUND_END_COLOUR.CGColor , nil];		
    colorGradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];		
    colorGradientLayer.cornerRadius = INSET_CORNER_RADIUS;
    colorGradientLayer.needsDisplayOnBoundsChange = YES;
    return colorGradientLayer;
}
void updateColorLayerForViewWithStyle(CALayer* layer,STYLE style)
{
    layer.backgroundColor = primaryColorForStyle(style).CGColor;
}
CALayer* setupColorLayerForControl(UIView* view)
{
    CALayer* colorLayer = [CALayer layer];
    colorLayer.borderColor = INSET_EDGE_DARK_COLOUR.CGColor;
    colorLayer.backgroundColor = INSET_EDGE_DARK_COLOUR.CGColor;
    colorLayer.borderWidth = 2.0;
    colorLayer.cornerRadius = INSET_CORNER_RADIUS;
    colorLayer.needsDisplayOnBoundsChange = YES;
    return colorLayer;
}
CALayer* setupColorLayerForView(UIView* view)
{
    CALayer* colorLayer = [CALayer layer];	
    colorLayer.borderColor = INSET_EDGE_DARK_COLOUR.CGColor;
    colorLayer.backgroundColor = TINT_DEFAULT.CGColor;
    colorLayer.borderWidth = 1.0;	
    colorLayer.cornerRadius = INSET_CORNER_RADIUS;
    colorLayer.needsDisplayOnBoundsChange = YES;
    return colorLayer;
}
void setDepthOfControlIncludingBevelLayerAndColorLayerAndColorGradientLayer(DEPTH depth,UIView* view,CAGradientLayer *bevelLayer,CALayer* colorLayer,CAGradientLayer* colorGradientLayer)
{
    if(depth == DEPTH_INSET)
    {
        if(bevelLayer)
        {
            bevelLayer.hidden = NO;
            bevelLayer.colors = @[(id)[UIColor clearColor].CGColor,
                                  (id)INSET_BEVEL_LIGHT_COLOUR.CGColor];
            bevelLayer.locations = @[[NSNumber numberWithFloat:0.9],[NSNumber numberWithFloat:1.0]];
        }
        
        colorGradientLayer.frame = CGRectMake(0, 1, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)-2);
    }
    else if(depth == DEPTH_OUTSET)
    {
        bevelLayer.hidden = YES;
        
        if(colorLayer)
        {
            colorLayer.borderColor = OUTSET_EDGE_DARK_COLOUR.CGColor;
            colorLayer.frame = CGRectMake(1, 1, CGRectGetWidth(view.frame)-2, CGRectGetHeight(view.frame)-2);
        }
        
        colorGradientLayer.frame = CGRectMake(1,1, CGRectGetWidth(view.frame)-2, CGRectGetHeight(view.frame)-2);
    }
}
void setDepthOfViewIncludingBevelLayerAndColorLayerAndColorGradientLayer(DEPTH depth,UIView* view,CAGradientLayer *bevelLayer,CALayer* colorLayer,CAGradientLayer* colorGradientLayer)
{
    if(depth == DEPTH_INSET)
    {
        if(bevelLayer)
        {
            bevelLayer.hidden = NO;
            bevelLayer.colors = [NSArray arrayWithObjects:(id)INSET_BEVEL_DARK_COLOUR.CGColor, INSET_BEVEL_LIGHT_COLOUR.CGColor, nil];
        }
        
        if(colorLayer)
        {
            colorLayer.borderColor = INSET_EDGE_DARK_COLOUR.CGColor;
            colorLayer.frame = CGRectMake(0, 1, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)-2);
        }
        
        colorGradientLayer.frame = CGRectMake(0, 1, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)-2);
    }
    else if(depth == DEPTH_OUTSET)
    {
        bevelLayer.hidden = YES;
        
        if(colorLayer)
        {
            colorLayer.borderColor = OUTSET_EDGE_DARK_COLOUR.CGColor;
            colorLayer.frame = CGRectMake(1, 1, CGRectGetWidth(view.frame)-2, CGRectGetHeight(view.frame)-2);
        }
        
        colorGradientLayer.frame = CGRectMake(1,1, CGRectGetWidth(view.frame)-2, CGRectGetHeight(view.frame)-2);
    }
}
CGRect placeBevelLayerForViewWithDepth(UIView* view,DEPTH depth)
{
    return CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame));
}
CGRect placeColorGradientLayerForViewWithDepth(UIView* view,DEPTH depth)
{
    CGRect placement;
    if(depth == DEPTH_INSET)
    {
        placement = CGRectMake(0, 1, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)-2);
    }
    else if(depth == DEPTH_OUTSET)
    {
        placement = CGRectMake(1,1, CGRectGetWidth(view.frame)-2, CGRectGetHeight(view.frame)-2);
    }
    return placement;
}
CGRect placeColorLayerForViewWithDepth(UIView* view,DEPTH depth)
{
    CGRect placement;
    if(depth == DEPTH_INSET)
    {
        placement = CGRectMake(0, 1, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)-2);	
    }
    else if(depth == DEPTH_OUTSET)
    {
        placement = CGRectMake(1, 1, CGRectGetWidth(view.frame)-2, CGRectGetHeight(view.frame)-2);
    }
    return placement;
}
