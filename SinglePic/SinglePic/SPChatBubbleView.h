//
//  SPChatBubbleView.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-25.
//
//

#import <UIKit/UIKit.h>

typedef enum
{
    CHAT_STYLE_INCOMING = 0,
    CHAT_STYLE_OUTGOING = 1
} CHAT_STYLE;

@interface SPChatBubbleView : UIImageView
@property (assign) CHAT_STYLE chatStyle;

+(CGSize)heightForMessageBody:(NSString*)body withWidth:(float)width;
-(void)setContent:(NSString*)content;
@end
