//
//  Copyright (c) 2011 Aaron Brethorst
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  Modified by Ryan Renna
//
//  SPStackPanel.h
//

#import <UIKit/UIKit.h>

static NSString* NOTIFICATION_STACKPANEL_CONTENT_RESIZED = @"NOTIFICATION_STACKPANEL_CONTENT_RESIZED";
static NSString* NOTIFICATION_STACKPANEL_CONTENT_WILL_RESIZE = @"NOTIFICATION_STACKPANEL_CONTENT_WILL_RESIZE";

@class SPStackPanel;
@protocol SPStackPanelDelegate<NSObject>
@optional
- (void)stackPanel:(SPStackPanel*)aPanel didSelectView:(UIView*)aView;
- (void)stackPanelWillBeginDragging:(SPStackPanel *)aPanel;
@end

//Not yet implemented
/*
@protocol SPStackPanelContentDelegate<NSObject>
@optional
- (void)stackPanelContent:(UIView*)content willResizeToHeight:(CGFloat)height;
- (void)stackPanelContent:(UIView*)content didResizeToHeight:(CGFloat)height;
@end
*/

@interface SPStackPanel : UIView <UITableViewDelegate, UITableViewDataSource/*, SPStackPanelContentDelegate*/>
@property(nonatomic,assign) id<SPStackPanelDelegate> delegate;

// Add
- (void)addStackedView:(UIView*)v;
- (void)addStackedView:(UIView *)v reload:(BOOL)yn;
- (void)addStackedViews:(NSArray*)a;

// Remove
- (void)removeStackedViewAtIndex:(NSInteger)index;
- (void)removeStackedViewAtIndex:(NSInteger)index animation:(UITableViewRowAnimation)rowAnimation;
- (void)removeStackedView:(UIView*)aView;
- (void)removeStackedView:(UIView*)aView animation:(UITableViewRowAnimation)rowAnimation;

- (void)scrollToOffset:(CGPoint)offset;
- (void)reloadStack;
@end