//
//  SPProfileIconController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPProfileIconController.h"
#import "SPProfile.h"

@interface SPProfileIconController()
{
    IBOutlet UIImageView* iconView;
    IBOutlet UIView* pictureStyledView;
    SPProfile* profile;
}
@end

@implementation SPProfileIconController

#pragma mark - View lifecycle

-(id)initWithProfile:(SPProfile*)profile_
{
    self = [self initWithNibName:@"SPProfileIconController" bundle:nil];
    if(self)
    {
        profile = profile_;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([profile isValid])
    {
        [[SPProfileManager sharedInstance] retrieveProfileThumbnail:profile withCompletionHandler:^(UIImage *thumbnail)
         {
             iconView.image = thumbnail;
         }
         andErrorHandler:nil];
    }
    

}
@end
