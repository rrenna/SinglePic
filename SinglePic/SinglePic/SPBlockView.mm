//
//  SPBlockView.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPBlockView.h"

@interface SPBlockView()
@end

@implementation SPBlockView
@synthesize delegate,data,column,joint;

-(void)layoutSubviews
{
    UIButton* blockSelectButton = [[[UIButton alloc] initWithFrame:self.bounds] autorelease];
    [blockSelectButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:blockSelectButton];
}
-(void)dealloc
{
    [controller_ release];
    [data release];
    [super dealloc];
}
#pragma mark - IBActions
-(IBAction)select:(id)sender
{
    [delegate blockViewWasSelected:self];
}
#pragma mark
-(void)setController:(UIViewController*)viewController
{
    controller_ = [viewController retain];
    [self setContent:viewController.view];
}
-(void)setContent:(UIView*)view
{
    [self addSubview:view];
}
@end