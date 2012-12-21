//
//  HelpOverlayViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-08-14.
//
//

#import "SPHelpOverlayViewController.h"

@interface SPHelpOverlayViewController ()

@end

@implementation SPHelpOverlayViewController
@synthesize delegate;

- (id) init
{
    self = [self initWithNibName:@"SPHelpOverlayViewController" bundle:nil];
    if(self)
    {
        _type = HELP_OVERLAY_LOGIN_OR_REGISTER; //Default type
    }
    return self;
}
-(id)initWithType:(HELP_OVERLAY_TYPE)type
{
    self = [self init];
    if(self)
    {
        _type = type;
    }
    return self;
}
#define FADE_DURATION 0.55
#define HELP_FADE_DURATION 0.1
- (void)viewDidLoad
{    
    [super viewDidLoad];

    if(_type == HELP_OVERLAY_LOGIN_OR_REGISTER)
    {
        overlayImageView.image = [UIImage imageNamed:@"Overlay_OOB_LOGIN.png"];
    }
    else if(_type == HELP_OVERLAY_BROWSE)
    {
        overlayImageView.image = [UIImage imageNamed:@"Overlay_OOB_BROWSE.png"];
    }
    else if(_type == HELP_OVERLAY_IMAGE_EXPIRY)
    {
        overlayImageView.image = [UIImage imageNamed:@"Overlay_OOB_EXPIRY.png"];
    }
    else
    {
        overlayImageView.image = [UIImage imageNamed:@"Overlay_OOB_NAVIGATION.png"];
    }
    
    [UIView animateWithDuration:FADE_DURATION animations:^{
        self.view.alpha = 1.0;
    }];
}

#pragma mark - IBActions
-(IBAction)dismiss:(id)sender
{
    [UIView animateWithDuration:HELP_FADE_DURATION animations:^{
        overlayImageView.alpha = 0.0;
    }];
    [UIView animateWithDuration:FADE_DURATION animations:^{
        self.view.alpha = 0.0;
    }
    completion:^(BOOL finished) {
        
        if(delegate)
        {
            [delegate helpOverlayDidDismiss:self];
        }
    
    }];
}
@end
