//
//  SPSwitchOrientationController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-02-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPSwitchOrientationCardController.h"
#import "SPOrientationChooser.h"

@interface SPSwitchOrientationCardController()
-(void)setLabelWithGender:(GENDER)gender andPreference:(GENDER)preference;
@end

@implementation SPSwitchOrientationCardController
#define MINIMIZED_SIZE 45
#define MAXIMIZED_SIZE 220
#pragma mark - View lifecycle
- (id) init
{
    self = [self initWithNibName:@"SPSwitchOrientationCardController" bundle:nil];
    if(self)
    {
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.height = MINIMIZED_SIZE;
    
    [self setLabelWithGender:[[SPProfileManager sharedInstance] myGender]  andPreference:[[SPProfileManager sharedInstance] myPreference]];
    [changeButton setStyle:STYLE_CONFIRM_BUTTON];
}
-(void)dealloc
{
    [orientationChooser release];
    [super dealloc];
}
#pragma mark - IBOutlet
-(IBAction)open:(id)sender
{
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:MAXIMIZED_SIZE],@"height",[NSNumber numberWithInt:[self.view tag]],@"index",self.view,@"view",nil];
    
    if(!orientationChooser)
    {
        orientationChooser = [[SPOrientationChooser alloc] initWithFrame:CGRectMake(floor(self.view.width * 0.05),floor(MAXIMIZED_SIZE * 0.07),floor(self.view.width * 0.9),floor(MAXIMIZED_SIZE * 0.7))];
        orientationChooser.delegate = self;
        orientationChooser.alpha = 0.0;
        [self.view addSubview:orientationChooser];
        [orientationChooser release];
    }
    
    //Fade out content, animate resize, fade in new content
    [UIView animateWithDuration:0.3 animations:^
    {
        self.view.height = MAXIMIZED_SIZE;
        orientationLabel.alpha = 0.0;
        orientationIcon.alpha = 0.0;
        changeButton.alpha = 1.0;
    } 
    completion:^(BOOL finished) 
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            orientationChooser.alpha = 1.0;
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STACKPANEL_CONTENT_RESIZED object:userInfo];
    }];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STACKPANEL_CONTENT_WILL_RESIZE object:userInfo];
}
-(IBAction)change:(id)sender
{    
    changeButton.enabled = NO;
    
    [[SPProfileManager sharedInstance] saveMyGender:orientationChooser.chosenGender andPreference:orientationChooser.chosenPreference withCompletionHandler:^(id responseObject) 
    {
        //Re-enable Change button
        changeButton.enabled = YES;
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:MINIMIZED_SIZE],@"height",[NSNumber numberWithInt:[self.view tag]],@"index",self.view,@"view",nil];
        
        //Set new title
        GENDER chosenGender = orientationChooser.chosenGender;
        GENDER chosenPreference = orientationChooser.chosenPreference;
        
        [self setLabelWithGender:chosenGender andPreference:chosenPreference];
        
        //When we minimize this control, we can flush the switch orientation control out of memory
        [orientationChooser removeFromSuperview];
        orientationChooser = nil;
        changeButton.alpha = 0.0;
        
        [UIView animateWithDuration:0.3 animations:^
        {
            //Minimize card
            self.view.height = MINIMIZED_SIZE;
            
            orientationLabel.alpha = 1.0;
            orientationIcon.alpha = 1.0;
            orientationChooser.alpha = 0.0;
        }
        completion:^(BOOL finished) 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STACKPANEL_CONTENT_RESIZED object:userInfo];
            [orientationChooser removeFromSuperview];
        }];
        
        //After a gender/preference has successfully been set, reset the profile stream
        [[SPProfileManager sharedInstance] restartProfiles];
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STACKPANEL_CONTENT_WILL_RESIZE object:userInfo];        
    } 
    andErrorHandler:^
    {
        //Re-enable Change button
        changeButton.enabled = YES;
        
        //TODO : 
    }];
}
#pragma mark - Private methods
-(void)setLabelWithGender:(GENDER)gender andPreference:(GENDER)preference
{
    orientationLabel.text = [NSString stringWithFormat:@"I'm a %@ seeking a %@",GENDER_NAMES[gender],GENDER_NAMES[preference] ];
}
#pragma mark - SPOrientationChooserViewDelegate methods
-(void)orientationChooserSelectionChanged:(SPOrientationChooser*)chooser
{
    //Currently does nothing
}
@end
