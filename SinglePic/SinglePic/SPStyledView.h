//
//  SPInsetView.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SPStyles.h"

@interface SPStyledView : UIView <SPStyle>
{
@protected
	CALayer *colorLayer;
	CALayer *darkenLayer;
    CAGradientLayer* bevelLayer;
    CAGradientLayer *colorGradientLayer;
    DEPTH depth;
    UIColor *tint;
}
-(void)setStyle:(STYLE)style;
-(void)setDepth:(DEPTH)depth;
@end
