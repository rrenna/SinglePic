//
//  SPStyles.m
//  SinglePic
//
//  Created by Ryan Renna on 12-02-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPStyles.h"

CAGradientLayer* setupBevelLayerForView(UIView* view)
{
    CAGradientLayer* bevelLayer = [CAGradientLayer layer];
    bevelLayer.frame = 	placeBevelLayerForViewWithDepth(view,DEPTH_DEFAULT);	
    bevelLayer.colors = [NSArray arrayWithObjects:(id)INSET_BEVEL_DARK_COLOUR.CGColor, INSET_BEVEL_LIGHT_COLOUR.CGColor, nil];
    bevelLayer.cornerRadius = INSET_CORNER_RADIUS;
    bevelLayer.needsDisplayOnBoundsChange = YES;
    return bevelLayer;
}
CAGradientLayer* setupColorGradientLayerForControl(UIControl* control)
{
    CAGradientLayer* colorGradientLayer = [[CAGradientLayer layer] retain];	
    colorGradientLayer.colors = [NSArray arrayWithObjects:(id)CONTROL_GRADIENT_BACKGROUND_START_COLOUR.CGColor, CONTROL_GRADIENT_BACKGROUND_END_COLOUR.CGColor , nil];		
    colorGradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];		
    colorGradientLayer.cornerRadius = INSET_CORNER_RADIUS;
    colorGradientLayer.needsDisplayOnBoundsChange = YES;
    return colorGradientLayer;
}
CAGradientLayer* setupColorGradientLayerForView(UIView* view)
{
    CAGradientLayer* colorGradientLayer = [[CAGradientLayer layer] retain];	
    colorGradientLayer.colors = [NSArray arrayWithObjects:(id)INSET_GRADIENT_BACKGROUND_START_COLOUR.CGColor, INSET_GRADIENT_BACKGROUND_END_COLOUR.CGColor , nil];		
    colorGradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];		
    colorGradientLayer.cornerRadius = INSET_CORNER_RADIUS;
    colorGradientLayer.needsDisplayOnBoundsChange = YES;
    return colorGradientLayer;
}
CALayer* setupColorLayerForView(UIView* view)
{
    CALayer* colorLayer = [CALayer layer];	
    colorLayer.borderColor = INSET_EDGE_DARK_COLOUR.CGColor;
    colorLayer.backgroundColor = INSET_TINT_DEFAULT.CGColor;
    colorLayer.borderWidth = 1.0;	
    colorLayer.cornerRadius = INSET_CORNER_RADIUS;
    colorLayer.needsDisplayOnBoundsChange = YES;
    return colorLayer;
}
void setDepthOfViewIncludingBevelLayerAndColorLayerAndColorGradientLayer(DEPTH depth,UIView* view,CAGradientLayer *bevelLayer,CALayer* colorLayer,CAGradientLayer* colorGradientLayer)
{
    if(depth == DEPTH_INSET)
    {
        bevelLayer.hidden = NO;
        bevelLayer.colors = [NSArray arrayWithObjects:(id)INSET_BEVEL_DARK_COLOUR.CGColor, INSET_BEVEL_LIGHT_COLOUR.CGColor, nil];
        
        colorLayer.borderColor = INSET_EDGE_DARK_COLOUR.CGColor;
        colorLayer.frame = CGRectMake(0, 1, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)-2);	
        colorGradientLayer.frame = CGRectMake(0, 1, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)-2);	
    }
    else if(depth == DEPTH_OUTSET)
    {
        bevelLayer.hidden = YES;
        colorLayer.borderColor = OUTSET_EDGE_DARK_COLOUR.CGColor;
        colorLayer.frame = CGRectMake(1, 1, CGRectGetWidth(view.frame)-2, CGRectGetHeight(view.frame)-2);
        colorGradientLayer.frame = CGRectMake(1,1, CGRectGetWidth(view.frame)-2, CGRectGetHeight(view.frame)-2);
    }
}
CGRect placeBevelLayerForViewWithDepth(UIView* view,DEPTH depth)
{
    return CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame));
}
CGRect placeColorGradientLayerForViewWithDepth(UIView* view,DEPTH depth)
{
    if(depth == DEPTH_INSET)
    {
        return CGRectMake(0, 1, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)-2);	
    }
    else if(depth == DEPTH_OUTSET)
    {
        return CGRectMake(1,1, CGRectGetWidth(view.frame)-2, CGRectGetHeight(view.frame)-2);
    }
}
CGRect placeColorLayerForViewWithDepth(UIView* view,DEPTH depth)
{
    if(depth == DEPTH_INSET)
    {
        return CGRectMake(0, 1, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)-2);	
    }
    else if(depth == DEPTH_OUTSET)
    {
        return CGRectMake(1, 1, CGRectGetWidth(view.frame)-2, CGRectGetHeight(view.frame)-2);
    }

}
