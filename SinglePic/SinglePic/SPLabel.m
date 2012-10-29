//
//  SPLabel.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-19.
//
//

#import "SPLabel.h"

@interface SPLabel()
-(void)_init;
@end

@implementation SPLabel
@dynamic style;

#pragma mark - Dynamic Properties
-(void)setStyle:(LABEL_STYLE)style
{
    if(style == LABEL_STYLE_EXTRA_SMALL)
    {
        self.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:FONT_SIZE_EXTRA_SMALL];
    }
    else if(style == LABEL_STYLE_SMALL)
    {
        self.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:FONT_SIZE_SMALL];
    }
    else if(style == LABEL_STYLE_REGULAR)
    {
        self.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:FONT_SIZE_MEDIUM];
    }
    else if(style == LABEL_STYLE_REGULAR_HEAVY)
    {
        self.font = [UIFont fontWithName:FONT_NAME_SECONDARY size:FONT_SIZE_MEDIUM];
    }
}
#pragma mark
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _init];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self _init];
    }
    return self;
}
-(void)_init
{
    CGFloat size = [self.font pointSize];
    self.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:size];
}
@end
