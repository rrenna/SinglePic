//
//  SPSheetController.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-20.
//
//

#import "SPPageContentDelegate.h"

@interface SPSheetController : UIViewController <UIGestureRecognizerDelegate>
{
    IBOutlet UIView* transparentInsetView;
    IBOutlet UIImageView *handleImageView;
    IBOutlet UIView* contentView;
    @protected
    NSInteger dragStart_;
    NSInteger lastDragOffset_;
    UIPanGestureRecognizer *panRecognizer_;
    UIViewController* controller_;
}

-(void)minimize;
-(void)close;
//Set Content
-(void)setController:(UIViewController*)controller;
-(void)setContent:(UIView *)view;
//Observation
- (void) removeObservationFromContentController;
- (void) addObservationForContentController;
//Touch Handling
- (void)moveStackWithOffset:(NSInteger)offset animated:(BOOL)animated userDragging:(BOOL)userDragging;
- (void)moveStackWithOffset:(NSInteger)offset animated:(BOOL)animated userDragging:(BOOL)userDragging onCompletion:(void(^)(BOOL finished))onCompletion;
@end