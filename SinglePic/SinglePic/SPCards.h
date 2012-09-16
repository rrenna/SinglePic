//
//  SPCards.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

typedef enum
{
    CARD_STYLE_YELLOW = 0,
    CARD_STYLE_WHITE = 1
} CARD_STYLE;

@protocol SPCard <NSObject>
-(void)setStyle:(CARD_STYLE)style;
@end