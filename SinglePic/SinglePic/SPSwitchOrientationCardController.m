//
//  SPSwitchOrientationController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-02-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPSwitchOrientationCardController.h"

@interface SPSwitchOrientationCardController()
{
    SPOrientationChooser* orientationChooser;
}
-(void)setDisplayWithGender:(GENDER)gender andPreference:(GENDER)preference;
@end

@implementation SPSwitchOrientationCardController
#define MINIMIZED_SIZE 38
#define MAXIMIZED_SIZE 175
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
    
    [self setDisplayWithGender:[[SPProfileManager sharedInstance] myGender]  andPreference:[[SPProfileManager sharedInstance] myPreference]];
}
#pragma mark - IBOutlet
-(IBAction)open:(id)sender
{
    [Crashlytics setObjectValue:@"Open the switch orientation control." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:MAXIMIZED_SIZE],@"height",[NSNumber numberWithInt:[self.view tag]],@"index",self.view,@"view",nil];
    
    if(!orientationChooser)
    {
        orientationChooser = [[SPOrientationChooser alloc] initWithFrame:CGRectMake(floor(self.view.width * 0.02),floor(MAXIMIZED_SIZE * 0.0251),floor(self.view.width * 0.9625),floor(MAXIMIZED_SIZE * 0.98))];
        orientationChooser.delegate = self;
        orientationChooser.alpha = 0.0;
        [self.view addSubview:orientationChooser];
    }
    
    //Fade out content, animate resize, fade in new content
    __unsafe_unretained SPSwitchOrientationCardController* weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^
    {
        weakSelf.view.height = MAXIMIZED_SIZE;
        orientationLabel.alpha = 0.0;
        orientationIcon.alpha = 0.0;
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
    [Crashlytics setObjectValue:@"Clicked on an gender/preference in an opened switch orientation control." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    BOOL newSexSelected = (orientationChooser.chosenGender != [[SPProfileManager sharedInstance] myGender]);
    BOOL newPreferenceSelected = (orientationChooser.chosenPreference != [[SPProfileManager sharedInstance] myPreference]);
    //Used to communicate with the Stack Panel on resizing

    NSDictionary* userInfo = @{@"height":@(MINIMIZED_SIZE),@"index":@(self.view.tag),@"view":self.view};
    
    __unsafe_unretained SPSwitchOrientationCardController* weakSelf = self;
    void (^dismiss)() = ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STACKPANEL_CONTENT_WILL_RESIZE object:userInfo];  
        
        //When we minimize this control, we can flush the switch orientation control out of memory
        [orientationChooser removeFromSuperview];
        orientationChooser = nil;
        
        [UIView animateWithDuration:0.3 animations:^
         {
            //Minimize card
             weakSelf.view.height = MINIMIZED_SIZE;
             
             orientationLabel.alpha = 1.0;
             orientationIcon.alpha = 1.0;
             orientationChooser.alpha = 0.0;
         }
         completion:^(BOOL finished)
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STACKPANEL_CONTENT_RESIZED object:userInfo];
             [orientationChooser removeFromSuperview];
         }];

    };
    
    if(newSexSelected || newPreferenceSelected)
    {
        [[SPProfileManager sharedInstance] saveMyGender:orientationChooser.chosenGender andPreference:orientationChooser.chosenPreference withCompletionHandler:^(id responseObject)
         {
             //Set new title
             GENDER chosenGender = orientationChooser.chosenGender;
             GENDER chosenPreference = orientationChooser.chosenPreference;
             
             dismiss();
             
             [weakSelf setDisplayWithGender:chosenGender andPreference:chosenPreference];
         } 
         andErrorHandler:^
         {
         }];
    }
    else
    {  
        dismiss();
    }
}
#pragma mark - Private methods
-(void)setDisplayWithGender:(GENDER)gender andPreference:(GENDER)preference
{
    NSString* genderName = GENDER_NAMES[gender];
    NSString* preferenceName = GENDER_NAMES[preference];
    NSString* genderInitial = [genderName substringToIndex:1];
    NSString* preferenceInitial = [preferenceName substringToIndex:1];
    NSString* genderPreferenceKey = [NSString stringWithFormat:@"I'm a %@ seeking a %@", genderName, preferenceName ];
    
    NSString* iconFileName = [NSString stringWithFormat:@"Orientation-%@s%@-selected.png",[genderInitial capitalizedString],[preferenceInitial capitalizedString]];
    
    orientationIcon.image = [UIImage imageNamed:iconFileName];
    orientationLabel.text = NSLocalizedString(genderPreferenceKey, nil);
}
#pragma mark - SPOrientationChooserViewDelegate methods
-(void)orientationChooserSelectionChanged:(SPOrientationChooser*)chooser
{
    [self change:nil];
    //Currently does nothing
}
@end
