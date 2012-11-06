//
//  SPChatBubbleView.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-25.
//
//

#import "SPChatBubbleView.h"

@interface SPChatBubbleView()
{
    CHAT_STYLE _chatStyle;
}
-(void)_init;
@end

@implementation SPChatBubbleView
@dynamic chatStyle;

+(CGSize)heightForMessageBody:(NSString*)body withWidth:(float)width
{
    return [body sizeWithFont:[UIFont fontWithName:FONT_NAME_PRIMARY size:FONT_SIZE_SMALL] constrainedToSize:CGSizeMake(width,800)];
}

#pragma mark - Dyanamic Properties
#define SIDE_SPACING 10
#define TOP_SPACING 5
-(void)setChatStyle:(CHAT_STYLE)chatStyle
{
    _chatStyle = chatStyle;
    
    UIImage* chatImage = (chatStyle == CHAT_STYLE_INCOMING) ? [UIImage imageNamed:@"MessageBubble-white"] : [UIImage imageNamed:@"MessageBubble-blue"];
    self.image = [chatImage stretchableImageWithLeftCapWidth:SIDE_SPACING topCapHeight:TOP_SPACING];
}
-(CHAT_STYLE)chatStyle
{
    return _chatStyle;
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
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [self setChatStyle:CHAT_STYLE_OUTGOING];
}
-(void)setContent:(NSString*)content
{
    UILabel* messageContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(SIDE_SPACING + 3, TOP_SPACING, self.frame.size.width - (SIDE_SPACING*2) - 6, self.frame.size.height - (TOP_SPACING*2))];
    messageContentLabel.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:FONT_SIZE_SMALL];
    messageContentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    messageContentLabel.numberOfLines = 0;
    messageContentLabel.lineBreakMode = UILineBreakModeWordWrap;
    messageContentLabel.text = content;
    messageContentLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:messageContentLabel];
}
@end
