//
//  SPAboutStyle.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPAboutStyle.h"

@implementation SPAboutStyle
- (UIColor *)backgroundColor
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"BG-linen-black.png"]];
}
- (UIImage *)listCellBackgroundSingle
{
    return [[UIImage imageNamed:@"MDACCellBackgroundSingle.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:10];
}
- (UIFont *)listCellFont
{
    return [UIFont fontWithName:FONT_NAME_PRIMARY size:17];
}
- (UIFont *)iconCellDetailFont
{
    return [UIFont fontWithName:FONT_NAME_PRIMARY size:14];
}
- (UIFont *)listCellDetailFont
{
    return [UIFont fontWithName:FONT_NAME_PRIMARY size:15];

}
@end
