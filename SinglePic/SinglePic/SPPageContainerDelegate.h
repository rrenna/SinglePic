//
//  SPPageContainerDelegate.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class SPPageController;

@protocol SPPageContainerDelegate <NSObject>
-(SPPageController*)createPage;
-(void) replacePage:(SPPageController*)page withNewPageContaining:(id)replacement;
-(void)removePage:(SPPageController*)page;
-(void)pushModalController:(UIViewController*)viewController;
-(void)pushModalContent:(UIView*)view;
-(void)setFullscreen:(BOOL)fullscreen;
-(void)closeAllPages;
-(void)minimize;
@end
