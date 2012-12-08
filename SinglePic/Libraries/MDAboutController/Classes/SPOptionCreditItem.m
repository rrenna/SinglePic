//
//  SPOptionCreditItem.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-10-26.
//
//

#import "SPOptionCreditItem.h"

@implementation SPOptionCreditItem
@synthesize optionType, optionGetter, optionSetter;

-(id)initWithName:(NSString*)name andCommand:(SEL)command
{
    self = [super init];
    if(self)
    {
        self.name = name;
        self.optionType = OPTION_TYPE_COMMAND;
        self.command = command;
    }
    return self;
}
-(id)initWithName:(NSString*)name andOptionGetter:(SEL)getter andOptionSetter:(SEL)setter
{
    self = [super init];
    if(self)
    {
        self.name = name;
        self.optionType = OPTION_TYPE_SWITCH;
        self.optionGetter = getter;
        self.optionSetter = setter;
    }
    return self;
}
- (id)initWithDictionary:(NSDictionary *)aDict
{
    self = [super initWithDictionary:aDict];
    if(self)
    {
        NSString* optionTypeValue = [aDict objectForKey:@"Type"];
        
        if([optionTypeValue isEqualToString:@"Command"])
        {
            self.optionType = OPTION_TYPE_COMMAND;
            
            NSString* commandValue = [aDict objectForKey:@"Selector"];
            
            if(commandValue)
            {
                self.command = NSSelectorFromString(commandValue);
            }
        }
        else
        {
            self.optionType = OPTION_TYPE_SWITCH;
            
            NSString* getterValue = [aDict objectForKey:@"Getter"];
            NSString* setterValue = [aDict objectForKey:@"Setter"];

            if(getterValue)
            {
                self.optionGetter = NSSelectorFromString(getterValue);
            }
            if(setterValue)
            {
                self.optionSetter = NSSelectorFromString(setterValue);
            }
        }
    }
    return self;
}

+ (id)itemWithDictionary:(NSDictionary *)aDict
{
    return [[self alloc] initWithDictionary:aDict];
}
@end
