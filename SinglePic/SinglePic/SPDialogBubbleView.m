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
    DIALOG_STYLE _dialogStyle;
}
-(void)_init;
@end

@implementation SPDialogBubbleView
@dynamic dialogStyle;

#pragma mark - Dyanamic Properties
-(void)setDialogStyle:(DIALOG_STYLE)dialogStyle
{
    _dialogStyle = dialogStyle;
    
    UIImage* dialogImage = (dialogStyle == DIALOG_STYLE_ARROW_UP) ? [UIImage imageNamed:@"dialog-up"] : [UIImage imageNamed:@"dialog-down"];
    self.image = [dialogImage stretchableImageWithLeftCapWidth:0 topCapHeight:25];
}
-(DIALOG_STYLE)dialogStyle
{
    return _dialogStyle;
}
#pragma mark
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
    self.contentMode = UIViewContentModeScaleToFill;
    [self setDialogStyle:DIALOG_STYLE_ARROW_UP];
}
@end
