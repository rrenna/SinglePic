//
//  SPInsetButton.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPStyledButton.h"
#import "UIColor+Expanded.h"

#define kHeight 26.0
#define kPadding 20.0

@interface SPStyledButton()
- (void)setupLayers;
@end

@implementation SPStyledButton
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {        
        [self setupLayers];
        [self setStyle:STYLE_DEFAULT];
        [self setDepth:DEPTH_OUTSET];
    }
    return  self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.layer.needsDisplayOnBoundsChange = YES;
        self.frame = frame;
        
        [self setupLayers];
        [self setStyle:STYLE_DEFAULT];
        [self setDepth:DEPTH_OUTSET];
    }
    return self;
}
-(void)dealloc
{
    [bevelLayer release];
    [colorLayer release];
    [darkenLayer release];
    [colorGradientLayer release];
    [tint release];
    [super dealloc];
}
-(void)setStyle:(STYLE)style
{
    [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    [tint release];
    tint = [primaryColorForStyle(style) retain];
    
    if(style == STYLE_DEFAULT)
    {
        [self setTitleColor:[UIColor colorWithWhite:0.95 alpha:1] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5] forState:UIControlStateNormal];
        
        [self setTitleColor:[UIColor colorWithWhite:0.75 alpha:1] forState:UIControlStateHighlighted];
        [self setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.9] forState:UIControlStateHighlighted];
        
        [self setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateDisabled];
        [self setTitleShadowColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateDisabled];
    }
    else if(style == STYLE_WHITE)
    {
        [self setTitleColor:[UIColor colorWithWhite:0.9 alpha:1] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];	
        
        [self setTitleColor:[UIColor colorWithWhite:0.75 alpha:1] forState:UIControlStateHighlighted];
        [self setTitleShadowColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateHighlighted];
        
        [self setTitleColor:[UIColor colorWithWhite:0.95 alpha:1] forState:UIControlStateDisabled];
        [self setTitleShadowColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateDisabled];
    }
    else if(style == STYLE_TAB)
    {
        [self setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];	
        
        [self setTitleColor:[UIColor colorWithWhite:0.75 alpha:1] forState:UIControlStateHighlighted];
        [self setTitleShadowColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateHighlighted];
        
        [self setTitleColor:[UIColor colorWithWhite:0.75 alpha:1] forState:UIControlStateDisabled];
        [self setTitleShadowColor:[UIColor colorWithWhite:0.9 alpha:1] forState:UIControlStateDisabled];
    }
    else if(style == STYLE_PAGE)
    {
        [self setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];	
        
        [self setTitleColor:[UIColor colorWithWhite:0.75 alpha:1] forState:UIControlStateHighlighted];
        [self setTitleShadowColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateHighlighted];
    }
    else if(style == STYLE_BASE)
    {
        [self setTitleColor:[UIColor colorWithWhite:0.95 alpha:1] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5] forState:UIControlStateNormal];	
        
        [self setTitleColor:[UIColor colorWithWhite:0.75 alpha:1] forState:UIControlStateHighlighted];
        [self setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.9] forState:UIControlStateHighlighted];
        
        [self setTitleColor:[UIColor colorWithRed:0.546 green:0.15 blue:0.15 alpha:1.0] forState:UIControlStateDisabled];
        [self setTitleShadowColor:[UIColor colorWithRed:0.65 green:0.25 blue:0.25 alpha:1.0] forState:UIControlStateDisabled];
    }
    else if(style == STYLE_CONFIRM_BUTTON)
    {
        [self setTitleColor:[UIColor colorWithWhite:0.95 alpha:1] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5] forState:UIControlStateNormal];	
        
        [self setTitleColor:[UIColor colorWithWhite:0.75 alpha:1] forState:UIControlStateHighlighted];
        [self setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.9] forState:UIControlStateHighlighted];
        
        [self setTitleColor:[UIColor colorWithRed:0.0 green:0.58 blue:0.7 alpha:1.0] forState:UIControlStateDisabled];
        [self setTitleShadowColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateDisabled];
    }
    else if(style == STYLE_ALTERNATIVE_ACTION_1_BUTTON)
    {
        [self setTitleColor:[UIColor colorWithWhite:0.95 alpha:1] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5] forState:UIControlStateNormal];	
        
        [self setTitleColor:[UIColor colorWithWhite:0.75 alpha:1] forState:UIControlStateHighlighted];
        [self setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.9] forState:UIControlStateHighlighted];
        
        [self setTitleColor:[UIColor colorWithRed:0.8 green:0.55 blue:0.0 alpha:1.0] forState:UIControlStateDisabled];
        [self setTitleShadowColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateDisabled];
    }
    else if(style == STYLE_ALTERNATIVE_ACTION_2_BUTTON)
    {
        [self setTitleColor:[UIColor colorWithWhite:0.95 alpha:1] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5] forState:UIControlStateNormal];	
        
        [self setTitleColor:[UIColor colorWithWhite:0.75 alpha:1] forState:UIControlStateHighlighted];
        [self setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.9] forState:UIControlStateHighlighted];
    }
    
    self.titleLabel.textAlignment = UITextAlignmentCenter;
    self.titleLabel.shadowOffset = CGSizeMake(0, 1);
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:FONT_SIZE_MEDIUM];
    
    colorLayer.backgroundColor = tint.CGColor;
    
    [self setNeedsDisplay];
    [self setNeedsLayout];
}
-(void)setDepth:(DEPTH)depth
{
    setDepthOfViewIncludingBevelLayerAndColorLayerAndColorGradientLayer(depth,self,bevelLayer,colorLayer,colorGradientLayer);    
}
#pragma mark - Private methods
- (void)setupLayers
{    
    bevelLayer = setupBevelLayerForView(self);
    colorLayer = setupColorLayerForView(self);
    colorGradientLayer = setupColorGradientLayerForControl(self);	
	
    [bevelLayer retain];
    [colorLayer retain];
    [colorGradientLayer retain];	
    
    [self.layer addSublayer:bevelLayer];
    [self.layer addSublayer:colorLayer];
    [self.layer addSublayer:colorGradientLayer];
    [self bringSubviewToFront:self.titleLabel];
    [self bringSubviewToFront:self.imageView];
}
@end
