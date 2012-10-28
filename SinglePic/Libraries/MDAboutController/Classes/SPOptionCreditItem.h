//
//  SPOptionCreditItem.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-10-26.
//
//

#import "MDACCreditItem.h"

typedef enum
{
    OPTION_TYPE_SWITCH,
    OPTION_TYPE_COMMAND
} OPTION_TYPE;

@interface SPOptionCreditItem : MDACCreditItem
@property (nonatomic, assign) OPTION_TYPE optionType;
@property (nonatomic, assign) SEL command;
@property (nonatomic, assign) SEL optionSetter;
@property (nonatomic, assign) SEL optionGetter;

@end
