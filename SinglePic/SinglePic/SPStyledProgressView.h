//
//  SPInsetProgressView.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPStyles.h"
#import "SPStyledView.h"
#import "SPLabel.h"

@interface SPStyledProgressView : SPStyledView <SPStyle>
@property (assign) float progress;
@property (assign) NSString* progressStatus;
@property (retain) UIColor* progressColour;
@property (retain) UIColor* lowProgressColour;

@end
