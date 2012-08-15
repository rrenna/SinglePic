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
        
    }
    return self;
}
#define FADE_DURATION 0.25
- (void)viewDidLoad
{
    [super viewDidLoad];

    [UIView animateWithDuration:FADE_DURATION animations:^{
        self.view.alpha = 1.0;
    }];
}

#pragma mark - IBActions
-(IBAction)dismiss:(id)sender
{
    [UIView animateWithDuration:FADE_DURATION animations:^{
        self.view.alpha = 0.0;
    }
    completion:^(BOOL finished) {
        
        [self.view removeFromSuperview];
        
        if(delegate)
        {
            [delegate helpOverlayDidDismiss:self];
        }
    
    }];
    
    
}
@end
