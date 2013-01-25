//
//  SPAAppDelegate.h
//  SinglePicAdmin
//
//  Created by Ryan Renna on 2013-01-22.
//  Copyright (c) 2013 Ryan Renna. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SinglePicCommon/SPBaseApplicationController.h>

@interface SPAAppDelegate : NSObject <NSApplicationDelegate,SPBaseApplicationController,NSTableViewDataSource,NSTableViewDelegate>

@property (assign) IBOutlet NSWindow *window;

@end
