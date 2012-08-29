//
//  SPKeyboardDragTableView.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-08-29.
//
//

#import "SPKeyboardDragTableView.h"

@implementation SPKeyboardDragTableView


-(void)handlePan:(id)event
{
    [self.delegate panGesture:event];
    [super handlePan:event];
}

@end
