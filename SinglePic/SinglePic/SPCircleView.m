//
//  CircleView.m
//  iGoToronto
//
//  Created by Ryan Renna on 11-03-10.
//  Copyright 2011 Offblast Softworks. All rights reserved.
//

#import "SPCircleView.h"

@implementation SPCircleView
@synthesize color;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.backgroundColor = [UIColor clearColor];
        self.color = [UIColor redColor];
        smallerFrame = CGRectMake(1, 1, frame.size.width - 2, frame.size.height - 2);
    }
    return self;
}
-(void)drawRect:(CGRect)rect
{
	CGContextRef contextRef = UIGraphicsGetCurrentContext();
    // Draw a filled circle
    CGContextSetFillColorWithColor(contextRef, color.CGColor); 
	CGContextFillEllipseInRect(contextRef, smallerFrame);
    
    //Draw border
    CGContextSetLineWidth(contextRef, 2.0);
    CGContextSetStrokeColorWithColor(contextRef, [UIColor whiteColor].CGColor);
    CGContextStrokeEllipseInRect(contextRef, smallerFrame);
}
@end
