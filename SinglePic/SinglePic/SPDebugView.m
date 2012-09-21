//
//  SPDebugView.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-20.
//
//

#import "SPDebugView.h"

@implementation SPDebugView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {}
    return self;
}
-(void)dealloc
{
    
    [super dealloc];
}
-(id)retain
{
    return [super retain];
}
-(oneway void)release
{
    [super release];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
