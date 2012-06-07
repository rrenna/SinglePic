//
//  SPTouchPassThroughView.m
//  SinglePic
//
//  Created by Ryan Renna on 11-12-08.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPTouchPassThroughView.h"

@implementation SPTouchPassThroughView
@synthesize passThroughZone;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)dealloc
{
    [super dealloc];
}
#pragma mark
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect _passThroughZone = passThroughZone;
    if(_passThroughZone.size.width == 0)
    {
        //If a CGRect of ZERO size is being used, used the UIView's  full bounds instead
        _passThroughZone = self.bounds;
    }
    
    if(CGRectContainsPoint(_passThroughZone, point))
    {
        return NO;
    }
    else
    {
        return [super pointInside:point withEvent:event];
    }
}
@end
