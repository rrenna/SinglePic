//
//  SPTabContentDelegate.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPTabController;

//UIViewControllers which are used to populate SPTabControllers, can broadcast these notifications to have their parent tab perform certain actions
#define NOTIFICATION_TAB_REPLACE_WITH_CONTENT @"NOTIFICATION_TAB_REPLACE_WITH_CONTENT"
#define NOTIFICATION_TAB_PUSH_MODAL_CONTROLLER @"NOTIFICATION_TAB_PUSH_MODAL_CONTROLLER"
#define NOTIFICATION_TAB_PUSH_MODAL_CONTENT @"NOTIFICATION_TAB_PUSH_MODAL_CONTENT"
#define NOTIFICATION_TAB_SET_FULLSCREEN @"NOTIFICATION_TAB_SET_FULLSCREEN"
#define NOTIFICATION_TAB_MINIMIZE @"NOTIFICATION_TAB_MINIMIZE"
#define NOTIFICATION_TAB_CLOSE @"NOTIFICATION_TAB_CLOSE"

//Keys used to store name/value parameters in a Notification's bundled dictionary
#define KEY_CONTENT @"KEY_CONTENT"
#define KEY_FULLSCREEN @"KEY_FULLSCREEN"

@protocol SPTabContentDelegate <NSObject>
//Content Controller informing Tab Controller
-(void)replaceWith:(id)content;
-(void)pushModalController:(UIViewController*)viewController;
-(void)pushModalContent:(UIView*)view;
-(void)setFullscreen:(BOOL)fullscreen;
-(void)minimize;
-(void)close;
//Tab Controller informing Content Controller
-(void)willMinimize;
-(void)willClose;
@end

