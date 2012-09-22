//
//  SPBlockView.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPBlockView.h"

@interface SPBlockView()
@property (retain) id contentController;
@end

@implementation SPBlockView
@synthesize contentController = _contentController; //Private
@synthesize delegate,data,column,joint;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){}
    return self;
}
-(void)layoutSubviews
{
    UIButton* blockSelectButton = [[[UIButton alloc] initWithFrame:self.bounds] autorelease];
    [blockSelectButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:blockSelectButton];
}
-(void)dealloc
{
    [_contentController release];
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
    self.contentController = viewController;
    [self setContent:viewController.view];
}
-(void)setContent:(UIView*)view
{
    [self addSubview:view];
}
@end