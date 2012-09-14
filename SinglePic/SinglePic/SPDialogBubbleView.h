//
//  SPDialogBubbleView.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-14.
//
//

#import <UIKit/UIKit.h>

typedef enum
{
    DIALOG_STYLE_ARROW_UP,
    DIALOG_STYLE_ARROW_DOWN
} DIALOG_STYLE;

@interface SPDialogBubbleView : UIView
@property (assign) DIALOG_STYLE dialogStyle;
@end
