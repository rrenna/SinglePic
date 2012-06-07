//
//  SPCardView.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPCardView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SPCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.autoresizesSubviews = YES;
        self.backgroundColor = [UIColor clearColor];

        backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:backgroundView atIndex:0];
        
        [self setStyle:CARD_STYLE_YELLOW];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.autoresizesSubviews = YES;
        self.backgroundColor = [UIColor clearColor];
        
        backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self insertSubview:backgroundView atIndex:0];
        
        [self setStyle:CARD_STYLE_YELLOW];
    }
    return self;
}
-(void)dealloc
{
    [backgroundView release];
    [super dealloc];
}
#pragma mark
-(void)setStyle:(CARD_STYLE)style
{
    UIImage* cardNinepatchSource;
    if(style == CARD_STYLE_YELLOW)
    {
        cardNinepatchSource = [UIImage imageNamed:@"card-ninepatch-yellow"];
    }
    else
    {
        cardNinepatchSource = [UIImage imageNamed:@"card-ninepatch-white"];
    }
    
    UIImage* cardNinepatchImage = [cardNinepatchSource stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    backgroundView.image = cardNinepatchImage;
    
    [self setNeedsDisplay];
    [self setNeedsLayout];

}
#pragma mark - SPStackPanelContentDelegate
- (void)stackPanelContent:(UIView*)content willResizeToHeight:(CGFloat)height
{
    
}
- (void)stackPanelContent:(UIView*)content didResizeToHeight:(CGFloat)height
{

}
@end
