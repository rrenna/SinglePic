//
//  SPMessageView.h
//  SinglePic
//
//  Created by Ryan Renna on 12-02-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPStyledView.h"

@interface SPMessageView : SPStyledView

+(CGSize)heightForMessageBody:(NSString*)body withWidth:(float)width;
-(void)setContent:(NSString*)content;
@end
