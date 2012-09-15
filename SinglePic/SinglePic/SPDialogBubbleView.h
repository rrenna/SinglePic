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
    DIALOG_STYLE_ARROW_UP = 0,
    DIALOG_STYLE_ARROW_DOWN = 1
} DIALOG_STYLE;

@interface SPDialogBubbleView : UIImageView
@property (assign) DIALOG_STYLE dialogStyle;
@end
