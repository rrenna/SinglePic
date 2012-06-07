//
//  SPCardView.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "SPCards.h"

@interface SPCardView : UIView <SPCard>
{
@private
    UIImageView* backgroundView;
}

-(void)setStyle:(CARD_STYLE)style;
@end
