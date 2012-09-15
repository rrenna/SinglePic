//
//  SPDialogBubbleView.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-14.
//
//

#import "SPDialogBubbleView.h"

@interface SPDialogBubbleView()
-(void)_init;
@end

@implementation SPDialogBubbleView
@synthesize dialogStyle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self _init];
    }
    return self;
}
-(void)_init
{
    
    UIImage* dialogImage = (dialogStyle == DIALOG_STYLE_ARROW_UP) ? [UIImage imageNamed:@"icebreaker-MyProfileTall"] : [UIImage imageNamed:@"dialog-9slice-down"];
    
    if([dialogImage respondsToSelector:@selector(resizableImageWithCapInsets:)])
    {
        dialogImage = [dialogImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    }
    /*else
    {
        //Shitty 9-slice for iOS 4.3
        dialogImage = [dialogImage stretchableImageWithLeftCapWidth:50 topCapHeight:19];
    }*/
    

    self.image = dialogImage;
    self.contentMode = UIViewContentModeScaleToFill;
}
@end
