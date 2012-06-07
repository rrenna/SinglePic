//
//  SPProfileIconController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPProfileIconController.h"
#import "SPProfile.h"

@implementation SPProfileIconController

#pragma mark - View lifecycle

-(id)initWithProfile:(SPProfile*)profile_
{
    profile = [profile_ retain];
    
    self = [self initWithNibName:@"SPProfileIconController" bundle:nil];
    if(self)
    {
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [pictureStyledView setBorderWidth:5.0 shadowDepth:5.0 controlPointXOffset:0.0 controlPointYOffset:0.0];
        
    [profile retrieveThumbnailWithCompletionHandler:^(UIImage *thumbnail) 
     {  
         iconView.image = thumbnail;
     } 
     andErrorHandler:^
     {
         
     }];
}
-(void)dealloc
{
    [profile release];
    [super dealloc];
}
@end
