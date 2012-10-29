//
//  SPLabel.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-09-19.
//
//

#import <UIKit/UIKit.h>

typedef enum
{
    LABEL_STYLE_EXTRA_SMALL = 0,
    LABEL_STYLE_SMALL = 1,
    LABEL_STYLE_REGULAR = 2,
    LABEL_STYLE_REGULAR_HEAVY = 3
} LABEL_STYLE;

@interface SPLabel : UILabel

@property (assign) LABEL_STYLE style;
@end
