//
//  SPErrorNotifierController.m
//  SinglePic
//
//  Created by Ryan Renna on 2013-01-28.
//
//

#import "SPErrorNotifierController.h"

@implementation SPErrorNotifierController

-(void)presentErrorIdentifiedBy:(int)identifier withTitle:(NSString*)title andBody:(NSString*)body allowingFeedback:(BOOL)allowsFeedback
{
    NSAssert(NO, @"Not yet implemented");
}
-(void)presentAnnonymousErrorWithTitle:(NSString*)title andBody:(NSString*)body
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:body delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
    
    [alert show];
}
@end
