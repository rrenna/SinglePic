//
//  SoundHelper.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-10-25.
//
//

#import "SPSoundHelper.h"
#import <AudioToolbox/AudioServices.h>

static CFURLRef tapSoundURLRef;
static CFURLRef alertSoundURLRef;
static SystemSoundID tapSoundID;
static SystemSoundID alertSoundID;

static BOOL soundEffectsEnabledInApp; //Cache the setting to avoid extra message calls

@interface SPSoundHelper()
+(void)updateSoundEffectsEnabledInApp;
@end

@implementation SPSoundHelper
+(void)load
{
    NSURL *tapSoundURL = [[NSBundle mainBundle] URLForResource: @"tap" withExtension: @"wav"];
    NSURL* alertSoundURL = [[NSBundle mainBundle] URLForResource: @"alert" withExtension: @"wav"];
    soundEffectsEnabledInApp = NO;//Default value
    
    tapSoundURLRef = (__bridge CFURLRef) tapSoundURL;
    alertSoundURLRef = (__bridge CFURLRef) alertSoundURL;
    
    AudioServicesCreateSystemSoundID (tapSoundURLRef,&tapSoundID);
    AudioServicesCreateSystemSoundID (alertSoundURLRef,&alertSoundID);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSoundEffectsEnabledInApp) name:NOTIFICATION_CLIENT_SETTINGS_CHANGED object:nil];
}
//Instead of querying the setting during every sound (which may cause a delay) we cache the setting value
// locally and update it when the settings have been changed in some way
+(void)updateSoundEffectsEnabledInApp
{
    soundEffectsEnabledInApp = [[SPSettingsManager sharedInstance] soundEffectsEnabled];
}
#pragma mark - Sound playback methods
+(void) playTap
{
    if(soundEffectsEnabledInApp)
    AudioServicesPlaySystemSound (tapSoundID);
}
+(void) playAlert
{
    if(soundEffectsEnabledInApp)
    AudioServicesPlaySystemSound (alertSoundID);
}
#pragma mark - Vibration methods
+(void) vibrate
{
    //Vibrate the device (NOTE: Does nothing on devices which do not support vibrations)
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
@end
