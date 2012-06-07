//
//  SPTabContainerDelegate.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class SPTabController;

@protocol SPTabContainerDelegate <NSObject>
-(SPTabController*)createTabIsFullscreen:(BOOL)fullscreen;
-(void) replaceTab:(SPTabController*)tab withNewTabContaining:(id)replacement;
-(void)removeTab:(SPTabController*)tab;
-(void)minimizeAllTabs;
-(void)closeAllTabs;
@end
