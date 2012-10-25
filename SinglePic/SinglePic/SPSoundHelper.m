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
    NSURL *tapSoundURL = [[NSBundle mainBundle] URLForResource: @"tap2"
                                                withExtension: @"wav"];
    tapSoundURLRef = (__bridge CFURLRef) tapSoundURL;
    AudioServicesCreateSystemSoundID (tapSoundURLRef,&tapSoundID);
}
#pragma mark - Sound playback methods
+(void) playTap
{
    AudioServicesPlaySystemSound (tapSoundID);
}
+(void) playAlert
{
    
}
#pragma mark - Vibration methods
+(void) vibrate
{
    //Vibrate the device (NOTE: Does nothing on devices which do not support vibrations)
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
@end
