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

@implementation SPSoundHelper
+(void)load
{
    NSURL *tapSoundURL = [[NSBundle mainBundle] URLForResource: @"tap" withExtension: @"wav"];
    NSURL* alertSoundURL = [[NSBundle mainBundle] URLForResource: @"alert" withExtension: @"wav"];
    
    tapSoundURLRef = (__bridge CFURLRef) tapSoundURL;
    alertSoundURLRef = (__bridge CFURLRef) alertSoundURL;
    
    AudioServicesCreateSystemSoundID (tapSoundURLRef,&tapSoundID);
    AudioServicesCreateSystemSoundID (alertSoundURLRef,&alertSoundID);
}
#pragma mark - Sound playback methods
+(void) playTap
{
    AudioServicesPlaySystemSound (tapSoundID);
}
+(void) playAlert
{
    AudioServicesPlaySystemSound (alertSoundID);
}
#pragma mark - Vibration methods
+(void) vibrate
{
    //Vibrate the device (NOTE: Does nothing on devices which do not support vibrations)
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
@end
