//
//  SPBlockView.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Box2D/Box2D.h>//Must be included AFTER MKMapKit or anything that includes MKMapKit

@class SPBlockView;
@protocol SPBlockViewDelegate <NSObject>
-(void)blockViewWasSelected : (SPBlockView*) blockView;
@end

@interface SPBlockView : UIView 

@property (assign) id<SPBlockViewDelegate> delegate;
@property (retain) id data;
@property (assign) int column;
@property b2PrismaticJoint* joint;

-(IBAction)select:(id)sender;

-(void)setController:(UIViewController*)viewController;
-(void)setContent:(UIView*)view;
@end