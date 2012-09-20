//
//  SPInsetView.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPStyledView.h"
#import "UIColor+Expanded.h"

@implementation SPStyledView
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {        
        [self setupLayers:STYLE_DEFAULT];
        [self setStyle:STYLE_DEFAULT];
        [self setDepth:DEPTH_DEFAULT];
    }
    return  self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.frame = frame;
        
        [self setupLayers:STYLE_DEFAULT];
        [self setStyle:STYLE_DEFAULT];
        [self setDepth:DEPTH_DEFAULT];
    }
    return self;
}
-(void)dealloc
{
    [bevelLayer release];
    [colorGradientLayer release];
    [colorLayer release];
    [darkenLayer release];
    [tint release];
    [super dealloc];
}
- (void)layoutSubviews 
{
    //CALayer resizing operations automatically animate any changes to their size/position, this manually disables that functionality
    /*[CATransaction flush];
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];*/
    
    // resize your layers based on the view's new bounds
    bevelLayer.frame = placeBevelLayerForViewWithDepth(self,depth);
    colorLayer.frame = placeColorLayerForViewWithDepth(self, depth);
    colorGradientLayer.frame = placeColorGradientLayerForViewWithDepth(self, depth);
    
    //[CATransaction commit];
}
-(void)setStyle:(STYLE)style
{
    if(style == STYLE_DEFAULT)
    {
        [tint release];
        tint = [TINT_DEFAULT retain];	
    }
    else if(style == STYLE_WHITE)
    {
        [tint release];
        tint = [TINT_WHITE retain];
    }
    else if(style == STYLE_TAB)
    {
        [tint release];
        tint = [TINT_TAB retain];
    }
    else if(style == STYLE_PAGE)
    {
        [tint release];
        tint = [TINT_PAGE retain];
    }
    else if(style == STYLE_BASE)
    {
        [tint release];
        tint = [TINT_BASE retain];
    }
    else if(style == STYLE_CONFIRM_BUTTON)
    {
        [tint release];
        tint = [TINT_CONFIRM_BUTTON retain];
    }
    else if(style == STYLE_ALTERNATIVE_ACTION_1_BUTTON)
    {
        [tint release];
        tint = [TINT_ALTERNATIVE_ACTION_1_BUTTON retain];
    }
    else if(style == STYLE_ALTERNATIVE_ACTION_2_BUTTON)
    {
        [tint release];
        tint = [TINT_ALTERNATIVE_ACTION_2_BUTTON retain];
    }
    
    colorLayer.backgroundColor = tint.CGColor;
    
    [self setNeedsDisplay];
    [self setNeedsLayout];
}
-(void)setDepth:(DEPTH)depth_
{
    depth = depth_;
    setDepthOfViewIncludingBevelLayerAndColorLayerAndColorGradientLayer(depth,self,bevelLayer,colorLayer,colorGradientLayer);    
}
#pragma mark - Private methods
- (void)setupLayers:(STYLE)style
{    
    bevelLayer = setupBevelLayerForView(self);
    colorLayer = setupColorLayerForView(self);
    colorGradientLayer = setupColorGradientLayerForViewWithStyle(self,style);
	
    [bevelLayer retain];
    [colorLayer retain];
    [colorGradientLayer retain];
    
    [self.layer addSublayer:bevelLayer];
    [self.layer addSublayer:colorLayer];
    [self.layer addSublayer:colorGradientLayer];
}
@end
