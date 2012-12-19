//
//  SPInsetProgressView.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPStyledProgressView.h"
#import <QuartzCore/QuartzCore.h>

#define LOW_PROGRESS_VALUE 0.10
@interface SPStyledProgressView()
{
    float progress;
    UIColor* progressColour;
    UIColor* lowProgressColour;
    CALayer* progressLayer;
    SPLabel* progressLabel;
}
-(void)setLayers;
-(void)setLabel;
@end

@implementation SPStyledProgressView

#pragma mark - Dynamic properties
-(float)progress
{
    return progress;
}
-(NSString*)progressStatus
{
    return progressLabel.text;
}
-(UIColor*)progressColour
{
    return progressColour;
}
-(UIColor*)lowProgressColour
{
    return lowProgressColour;
}
-(void)setProgress:(float)progress_
{
    progress = progress_;
    //Resize
    int width = CGRectGetWidth(self.frame) * progress;
    progressLayer.frame = CGRectMake(0, 1, width, CGRectGetHeight(self.frame)-2);
    //Set colour
    if(progress <= LOW_PROGRESS_VALUE)
    {
        progressLayer.backgroundColor = lowProgressColour.CGColor;
    }
    else
    {
        progressLayer.backgroundColor = progressColour.CGColor;
    }
}
-(void)setProgressStatus:(NSString *)progressStatus
{
    if(!progressLabel) [self setLabel];
    
    progressLabel.text = progressStatus;
}
-(void)setProgressColour:(UIColor *)progressColour_
{
    progressColour = progressColour_;
    
    if(!lowProgressColour)
    {
        progressLayer.backgroundColor = progressColour.CGColor;
    }
    else if(self.progress > LOW_PROGRESS_VALUE)
    {
        progressLayer.backgroundColor = progressColour.CGColor;
    }
}
-(void)setLowProgressColour:(UIColor *)lowProgressColour_
{
    lowProgressColour = lowProgressColour_;
    if(self.progress <= LOW_PROGRESS_VALUE)
    {
        progressLayer.backgroundColor = lowProgressColour.CGColor;
    }
}
#pragma mark
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        //Default progress colours
        self.progressColour = [UIColor colorWithRed:0.13 green:0.6 blue:0.23 alpha:1.0];
        self.lowProgressColour = [UIColor colorWithRed:1.0 green:0.0 blue:0.1 alpha:1.0];
        
        [self setLayers:STYLE_DEFAULT];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self setStyle:STYLE_DEFAULT];
        [self setDepth:DEPTH_DEFAULT];
        
        //Default progress colours
        self.progressColour = [UIColor colorWithRed:0.13 green:0.6 blue:0.23 alpha:1.0];
        self.lowProgressColour = [UIColor colorWithRed:1.0 green:0.0 blue:0.1 alpha:1.0];
        
        [self setLayers];
    }
    return self;
}
#pragma mark
-(void)setStyle:(STYLE)style
{
    if(style == STYLE_DEFAULT)
    {
        tint = TINT_DEFAULT;
    }
    else if(style == STYLE_TAB)
    {
        tint = TINT_TAB;
    }
    else if(style == STYLE_WHITE)
    {
        tint = TINT_WHITE;
    }
    else if(style == STYLE_BASE)
    {
        tint = TINT_BASE;
    }
    
    colorLayer.backgroundColor = tint.CGColor;
    
    [self setNeedsDisplay];
    [self setNeedsLayout];
}
#pragma mark - Private methods
-(void)setLabel
{
    CGRect progressStatusRect = CGRectMake(8, 1, CGRectGetWidth(self.frame) - 45, CGRectGetHeight(self.frame));
    progressLabel = [[SPLabel alloc] initWithFrame:progressStatusRect];
    progressLabel.style = LABEL_STYLE_EXTRA_SMALL;
    progressLabel.backgroundColor = [UIColor clearColor];
    progressLabel.textAlignment = UITextAlignmentLeft;
    progressLabel.textColor = [UIColor whiteColor];
    progressLabel.shadowColor = [UIColor darkGrayColor];
    progressLabel.shadowOffset = CGSizeMake(1,1);
    [self addSubview:progressLabel];
}
-(void)setLayers:(STYLE)style
{
    bevelLayer = setupBevelLayerForView(self);
    colorLayer = setupColorLayerForView(self);
    colorGradientLayer = setupColorGradientLayerForViewWithStyle(self,style);

    progressLayer = [CALayer layer];
    progressLayer.frame = CGRectMake(0, 1, 0, CGRectGetHeight(self.frame)-2);
    progressLayer.borderColor = [UIColor colorWithWhite:0 alpha:0.15].CGColor;
    progressLayer.borderWidth = 1.0;
    progressLayer.cornerRadius = INSET_CORNER_RADIUS;
    progressLayer.needsDisplayOnBoundsChange = YES;
    
    [self.layer addSublayer:bevelLayer];
    [self.layer addSublayer:colorLayer];
    [self.layer addSublayer:progressLayer];
    [self.layer addSublayer:colorGradientLayer];
}
@end
