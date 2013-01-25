//
//  SPAAppDelegate.m
//  SinglePicAdmin
//
//  Created by Ryan Renna on 2013-01-22.
//  Copyright (c) 2013 Ryan Renna. All rights reserved.
//

#import "SPAAppDelegate.h"


@implementation SPAAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}
#pragma mark -
-(BOOL)canSendMail
{
    return NO;
}
-(void)presentEmailWithRecipients:(NSArray*)recipients andSubject:(NSString*)subject andBody:(NSString*)body
{
    NSAssert(NO,@"Implement on OS X");
}
#pragma mark - 
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return 5;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [NSView new];
}
@end
