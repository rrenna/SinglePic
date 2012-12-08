//
//  SPTabController.h
//  SinglePic
//
//  Created by Ryan Renna on 11-12-07.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPSheetController.h"
#import "SPPageController.h"
#import "UIView+SizesAndEdges.h"
#import "SPTabContentDelegate.h"
#import "SPTabContainerDelegate.h"

@interface SPTabController : SPSheetController <SPPageContainerDelegate>
{
    IBOutlet UIView* handleView;
    IBOutlet UIView* secretEdgeView;
}
@property (assign) id <SPTabContainerDelegate> containerDelegate;
@property (assign) BOOL fullscreen;

-(void)maximize;
-(void)maximizeIsFullscreen:(BOOL)fullscreen;
//Push Sub-Content
-(void)pushModalController:(UIViewController*)viewController;
-(void)pushModalContent:(UIView*)view;
@end
