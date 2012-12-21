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
    id<SPKeyboardDragTableViewDelegate> _delegate = (id<SPKeyboardDragTableViewDelegate>) self.delegate;
    [_delegate panGesture:event];
    [super handlePan:event];
    
    /*
    [self.delegate panGesture:event];
    
    [super performSelector:@selector(handlePan:) withObject:event];
     */
}
@end
