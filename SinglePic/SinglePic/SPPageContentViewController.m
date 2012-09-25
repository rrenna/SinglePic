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
    BOOL _cascadeCloseTab;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PAGE_SET_FULLSCREEN object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:fullscreen] forKey:KEY_FULLSCREEN]];
}
-(void)close
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PAGE_CLOSE object:self];
}
//Recieving intent from Page Controller
-(void)setCascadeCloseTab:(BOOL)cascadeCloseTab
{
    _cascadeCloseTab = cascadeCloseTab;
}
-(void)closeTab
{
    
}
-(void)willClose
{
    if(_cascadeCloseTab)
    {
        [self closeTab];
    }
}
@end
