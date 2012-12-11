//
//  SPTabContentViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPTabContentViewController.h"

@implementation SPTabContentViewController

//Informing Tab Controller of intent
-(void)replaceWith:(id)content
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TAB_REPLACE_WITH_CONTENT object:self userInfo:[NSDictionary dictionaryWithObject:content forKey:KEY_CONTENT]];
}
-(void)pushModalController:(UIViewController*)viewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TAB_PUSH_MODAL_CONTROLLER object:self userInfo:[NSDictionary dictionaryWithObject:viewController forKey:KEY_CONTENT]];
}
-(void)pushModalContent:(UIView*)view
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TAB_PUSH_MODAL_CONTENT object:self userInfo:[NSDictionary dictionaryWithObject:view forKey:KEY_CONTENT]];
}
-(void)setFullscreen:(BOOL)fullscreen
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TAB_SET_FULLSCREEN object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:fullscreen] forKey:KEY_FULLSCREEN]];
}
-(void)minimize
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TAB_MINIMIZE object:self];
}
-(void)close
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TAB_CLOSE object:self];
}
//Recieving intent from Tab Controller
-(void)willMinimize
{
}
-(void)willClose
{
    
}
@end
