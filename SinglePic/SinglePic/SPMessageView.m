//
//  SPMessageView.m
//  SinglePic
//
//  Created by Ryan Renna on 12-02-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPMessageView.h"
#import "SPLabel.h"

@implementation SPMessageView

+(CGSize)heightForMessageBody:(NSString*)body withWidth:(float)width
{
    return [body sizeWithFont:[UIFont fontWithName:@"STHeitiSC-Light" size:12] constrainedToSize:CGSizeMake(width,600)];
}
#pragma mark
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self setStyle:STYLE_WHITE];
        [self setDepth:DEPTH_OUTSET];
    }
    return self;
}
-(void)setContent:(NSString*)content
{
    SPLabel* messageContentLabel = [[SPLabel alloc] initWithFrame:CGRectMake(10, 20, self.frame.size.width - 20, self.frame.size.height - 35)];
    messageContentLabel.style = LABEL_STYLE_SMALL;
    messageContentLabel.backgroundColor = [UIColor clearColor];
    messageContentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    messageContentLabel.numberOfLines = 0;
    messageContentLabel.lineBreakMode = UILineBreakModeWordWrap;
    messageContentLabel.text = content;
    [self addSubview:messageContentLabel];
}
@end
