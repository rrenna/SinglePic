//
//  SPPageController.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPSheetController.h"
#import "SPPageContainerDelegate.h"
#import "SPPageContentDelegate.h"
#import "SPStyledView.h"

//iPhone screen coorindates (in portrait mode) for the various Tab states
#define PAGE_POS_LEFT_OFFSCREEN -275
#define PAGE_POS_LEFT_MAXIMIZED 0
#define PAGE_SNAP_BUFFER 50

@interface SPPageController : SPSheetController
@property (assign) id <SPPageContainerDelegate> containerDelegate;

@end
