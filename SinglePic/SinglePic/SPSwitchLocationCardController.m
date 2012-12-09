//
//  SPSwitchLocationViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-08-11.
//
//

#import "SPSwitchLocationCardController.h"

@interface SPSwitchLocationCardController ()

@end

@implementation SPSwitchLocationCardController
#define MINIMIZED_SIZE 38
#define MAXIMIZED_SIZE 200
#pragma mark - View lifecycle
- (id) init
{
    self = [self initWithNibName:@"SPSwitchLocationCardController" bundle:nil];
    if(self)
    {
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.height = MINIMIZED_SIZE;
    
    SPBucket* myBucket = [[SPProfileManager sharedInstance] myBucket];
    locationLabel.text = myBucket.name;
    
    [changeButton setStyle:STYLE_CONFIRM_BUTTON];
}
#pragma mark - IBOutlet
-(IBAction)open:(id)sender
{
    [SPSoundHelper playTap];
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:MAXIMIZED_SIZE],@"height",[NSNumber numberWithInt:[self.view tag]],@"index",self.view,@"view",nil];
    
    //TODO: Lazily load the location chooser instead of instantiating it from a XIB
    
    //Fade out content, animate resize, fade in new content
    [UIView animateWithDuration:0.3 animations:^
     {
         self.view.height = MAXIMIZED_SIZE;
         locationLabel.alpha = 0.0;
         locationIcon.alpha = 0.0;
         changeButton.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.3 animations:^
          {
                  locationChooser.alpha = 1.0;
          }];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STACKPANEL_CONTENT_RESIZED object:userInfo];
     }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STACKPANEL_CONTENT_WILL_RESIZE object:userInfo];
}
-(IBAction)change:(id)sender
{
    [SPSoundHelper playTap];
    
    changeButton.enabled = NO;
    
    [[SPProfileManager sharedInstance] saveMyBucket:locationChooser.chosenBucket withCompletionHandler:^(id responseObject) {
        
        //Re-enable Change button
        changeButton.enabled = YES;
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:MINIMIZED_SIZE],@"height",[NSNumber numberWithInt:[self.view tag]],@"index",self.view,@"view",nil];
        
        [UIView animateWithDuration:0.3 animations:^
         {
                 //Minimize card
             self.view.height = MINIMIZED_SIZE;
             
             locationLabel.alpha = 1.0;
             locationIcon.alpha = 1.0;
             locationChooser.alpha = 0.0;
             changeButton.alpha = 0.0;
         }
                         completion:^(BOOL finished)
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STACKPANEL_CONTENT_RESIZED object:userInfo];
         }];
        
            //After a gender/preference has successfully been set, reset the profile stream
        [[SPProfileManager sharedInstance] restartProfiles];
            //
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STACKPANEL_CONTENT_WILL_RESIZE object:userInfo];
        
        
    } andErrorHandler:^{
        
        //Re-enable Change button
        changeButton.enabled = YES;
        
        //TODO :
    }];
    
}
#pragma mark - SPLocationChooserDelegate methods
-(void)locationChooserSelectionChanged:(SPLocationChooser*)chooser
{
    changeButton.enabled = YES;
}
@end
