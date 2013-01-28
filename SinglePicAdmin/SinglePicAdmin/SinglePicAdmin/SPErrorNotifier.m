//
//  SPErrorNotifier.m
//  SinglePicAdmin
//
//  Created by Ryan Renna on 2013-01-28.
//  Copyright (c) 2013 Ryan Renna. All rights reserved.
//

#import "SPErrorNotifier.h"

@implementation SPErrorNotifier
-(void)presentErrorIdentifiedBy:(int)identifier withTitle:(NSString*)title andBody:(NSString*)body allowingFeedback:(BOOL)allowsFeedback
{
    NSAssert(NO, @"Not yet implemented");
}
-(void)presentAnnonymousErrorWithTitle:(NSString*)title andBody:(NSString*)body
{
    NSAlert* bucketErrorAlert = [NSAlert new];
    bucketErrorAlert.informativeText = title;
    bucketErrorAlert.messageText = body;
    [bucketErrorAlert runModal];
}
@end
