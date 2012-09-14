//
//  SPDialogBubbleView.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-14.
//
//

#import "SPDialogBubbleView.h"

@interface SPDialogBubbleView()
{
    UIImageView* backgroundImageView;
}
@end

@implementation SPDialogBubbleView
@synthesize dialogStyle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage* image = (dialogStyle == DIALOG_STYLE_ARROW_UP) ? [UIImage imageNamed:@"dialog-9slice-up"] : [UIImage imageNamed:@"dialog-9slice-down"];
        
        image = [image stretchableImageWithLeftCapWidth:15 topCapHeight:15];
        backgroundImageView = [[UIImageView alloc] initWithImage:image];
    }
    return self;
}
-(void)dealloc
{
    [backgroundImageView release];
    [super dealloc];
}
@end
