//
//  SPSettingsViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-03-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPSettingsViewController.h"
#import "MDAboutController.h"
#import "SPAboutStyle.h"

@interface SPSettingsViewController ()

@end

@implementation SPSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        style = [[SPAboutStyle style] retain];
        
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        self.modalPresentationStyle = UIModalPresentationFormSheet;

        //- (id)initWithRootViewController:(UIViewController *)rootViewController;
        
        // Custom initialization
    }
    return self;
}
-(void)dealloc
{
    [style release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view addSubview: navigationController.view];
    
    settingsScreenController.view.backgroundColor = [style backgroundColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
#pragma mark - IBActions
-(IBAction)close:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
-(IBAction)about:(id)sender
{
    MDAboutController* aboutController = [[[MDAboutController alloc] initWithStyle: [SPAboutStyle style]] autorelease];
    [aboutController removeLastCredit];
     
    [navigationController pushViewController:aboutController animated:YES];
}
-(IBAction)logout:(id)sender
{
    [[SPProfileManager sharedInstance] logout];
    [self close:nil];
}
@end
