//
//  SPSwitchLocationViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-08-11.
//
//

#import "SPSwitchLocationCardController.h"

@interface SPSwitchLocationCardController ()
@property (strong) SPLocationChooser* locationChooser;
-(void)displayLocation;
@end

@implementation SPSwitchLocationCardController
#define MINIMIZED_SIZE 38
#define MAXIMIZED_SIZE 175
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
    
    [self displayLocation];
}
#pragma mark - IBOutlet
-(IBAction)open:(id)sender
{
    [SPSoundHelper playTap];
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:MAXIMIZED_SIZE],@"height",[NSNumber numberWithInt:[self.view tag]],@"index",self.view,@"view",nil];
    
    //Lazily load the location chooser
    if(!self.locationChooser)
    {
        self.locationChooser = [[SPLocationChooser alloc] initWithFrame:CGRectMake(3, 5, self.view.frame.size.width - 8, MAXIMIZED_SIZE - 5)];
        self.locationChooser.delegate = self;
    }
    
    [self.view addSubview:self.locationChooser];
    
    //Fade out content, animate resize, fade in new content
    [UIView animateWithDuration:0.3 animations:^
     {
         self.view.height = MAXIMIZED_SIZE;
         locationLabel.alpha = 0.0;
         locationIcon.alpha = 0.0;
     }
     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.3 animations:^
          {
                  self.locationChooser.alpha = 1.0;
          }];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STACKPANEL_CONTENT_RESIZED object:userInfo];
     }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STACKPANEL_CONTENT_WILL_RESIZE object:userInfo];
}
#pragma mark - Private methods
-(void)displayLocation
{
    SPBucket* myBucket = [[SPProfileManager sharedInstance] myBucket];
    locationLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"I live in", nil),myBucket.name];
}
#pragma mark - SPLocationChooserDelegate methods
-(void)locationChooserSelectionChanged:(SPLocationChooser*)chooser
{
    //New location chosen
    __unsafe_unretained SPSwitchLocationCardController* weakSelf = self;
    [[SPProfileManager sharedInstance] saveMyBucket:chooser.chosenBucket withCompletionHandler:^(id responseObject)
    {
        [self displayLocation];
        
        NSDictionary* userInfo = @{@"height":@(MINIMIZED_SIZE),@"index":@(weakSelf.view.tag),@"view":weakSelf.view};
        
        [UIView animateWithDuration:0.3 animations:^
        {
             //Minimize card
             weakSelf.view.height = MINIMIZED_SIZE;
             
             locationLabel.alpha = 1.0;
             locationIcon.alpha = 1.0;
             chooser.alpha = 0.0;
        }
        completion:^(BOOL finished)
        {
             [weakSelf.locationChooser removeFromSuperview];
             weakSelf.locationChooser = nil;
             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STACKPANEL_CONTENT_RESIZED object:userInfo];
        }];
        
            //After a gender/preference has successfully been set, reset the profile stream
        [[SPProfileManager sharedInstance] restartProfiles];
            //
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STACKPANEL_CONTENT_WILL_RESIZE object:userInfo];
        
    } andErrorHandler:^
    {

    }];
}
@end
