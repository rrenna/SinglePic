//
//  SPPageContentViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPPageContentViewController.h"

@interface SPPageContentViewController()
{
}
@end

@implementation SPPageContentViewController
//Informing Page Controller of intent
-(void)replaceWith:(id)content
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PAGE_REPLACE_WITH_CONTENT object:self userInfo:[NSDictionary dictionaryWithObject:content forKey:KEY_CONTENT]];
}
-(void)pushModalController:(UIViewController*)viewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PAGE_PUSH_MODAL_CONTROLLER object:self userInfo:[NSDictionary dictionaryWithObject:viewController forKey:KEY_CONTENT]];
}
-(void)pushModalContent:(UIView*)view
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PAGE_PUSH_MODAL_CONTENT object:self userInfo:[NSDictionary dictionaryWithObject:view forKey:KEY_CONTENT]];
}
-(void)setFullscreen:(BOOL)fullscreen
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PAGE_SET_FULLSCREEN object:self userInfo:@{KEY_FULLSCREEN:[NSNumber numberWithBool:fullscreen],KEY_FULLSCREEN_ANIMATED:@YES} ];    
}
-(void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PAGE_SET_FULLSCREEN object:self userInfo:@{KEY_FULLSCREEN:[NSNumber numberWithBool:fullscreen],KEY_FULLSCREEN_ANIMATED:[NSNumber numberWithBool:animated]} ];
}
-(void)close
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PAGE_CLOSE object:self];
}
//Recieving intent from Page Controller
-(void)minimizeContainer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PAGE_MINIMIZE_CONTAINER object:self];
}
-(void)willClose
{
}
@end
