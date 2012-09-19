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
    LABEL_STYLE_EXTRA_SMALL,
    LABEL_STYLE_SMALL,
    LABEL_STYLE_MEDIUM
} LABEL_STYLE;

@interface SPLabel : UILabel

@property (assign) LABEL_STYLE style;
@end
