//
//  SPStyledSegmentedControl.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-02-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SPStyles.h"

@interface SPStyledSegmentedControl : UISegmentedControl <SPStyle>
{
@private
	CALayer *colorLayer;
    CALayer *darkenLayer;
    CAGradientLayer *bevelLayer;
    CAGradientLayer *colorGradientLayer;
    UIColor* tint;
    UIColor* unselectedTint;
    UIFont* font;
}

-(void)setStyle:(STYLE)style;
@end
