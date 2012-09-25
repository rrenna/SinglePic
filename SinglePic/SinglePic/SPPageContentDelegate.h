//
//  SPPageContent.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//UIViewControllers which are used to populate SPPageControllers, can broadcast these notifications to have their parent tab perform certain actions
#define NOTIFICATION_PAGE_REPLACE_WITH_CONTENT @"NOTIFICATION_PAGE_REPLACE_WITH_CONTENT"
#define NOTIFICATION_PAGE_PUSH_MODAL_CONTROLLER @"NOTIFICATION_PAGE_PUSH_MODAL_CONTROLLER"
#define NOTIFICATION_PAGE_PUSH_MODAL_CONTENT @"NOTIFICATION_PAGE_PUSH_MODAL_CONTENT"
#define NOTIFICATION_PAGE_SET_FULLSCREEN @"NOTIFICATION_PAGE_SET_FULLSCREEN"
#define NOTIFICATION_PAGE_CLOSE @"NOTIFICATION_PAGE_CLOSE"

//Keys used to store name/value parameters in a Notification's bundled dictionary
#define KEY_CONTENT @"KEY_CONTENT"
#define KEY_FULLSCREEN @"KEY_FULLSCREEN"

@protocol SPPageContentDelegate <NSObject>
//Content Controller informing Page Controller
-(void)replaceWith:(id)content;
-(void)pushModalController:(UIViewController*)viewController;
-(void)pushModalContent:(UIView*)view;
-(void)setFullscreen:(BOOL)fullscreen;
-(void)setCascadeCloseTab:(BOOL)cascadeCloseTab;
-(void)closeTab;
-(void)close;
//Page Controller informing Content Controller
-(void)willClose;
@end
