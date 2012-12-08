//
//  SPSettingsViewController.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-07.
//
//

#import <UIKit/UIKit.h>
#import "MDAboutController.h"

@interface SPSettingsViewController : MDAboutController

-(void)logout;
//Options
-(BOOL)soundEffectsEnabledValue;
-(void)setSoundEffectsEnabledWithControl:(id)control;
-(BOOL)saveToCameraRollEnabledValue;
-(void)setSaveToCameraRollEnabledWithControl:(id)control;
-(BOOL)verboseErrorMessagesEnabled;
-(void)setVerboseErrorMessagesEnabledWithControl:(id)control;
@end
