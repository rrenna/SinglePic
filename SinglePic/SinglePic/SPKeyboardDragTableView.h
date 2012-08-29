//
//  SPKeyboardDragTableView.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-08-29.
//
//

#import <UIKit/UIKit.h>

@protocol SPKeyboardDragTableViewDelegate <NSObject,UITableViewDelegate>
-(void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer;
@end

@interface SPKeyboardDragTableView : UITableView

@end
