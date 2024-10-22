//
//  SPOptionCredit.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-10-26.
//
//

#import "SPOptionCredit.h"
#import "SPOptionCreditItem.h"

@implementation SPOptionCredit

@synthesize title;

- (id)initWithTitle:(NSString *)aTitle
{
    if ((self = [super initWithType:@"Options"])) {
        self.title = aTitle;
        items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithType:(NSString *)aType
{
    return [self initWithTitle:nil];
}

+ (id)creditWithType:(NSString *)aType
{
    return [self optionsCreditWithTitle:nil];
}

+ (id)optionsCreditWithTitle:(NSString *)aTitle
{
    return [[self alloc] initWithTitle:aTitle];
}

- (id)initWithDictionary:(NSDictionary *)aDict
{
    if ((self = [self initWithTitle:[aDict objectForKey:@"Title"]])) {
        NSArray *itemsList = [aDict objectForKey:@"Items"];
        for (NSDictionary *item in itemsList) {
            [self addItem:[SPOptionCreditItem itemWithDictionary:item]];
        }
    }
    return self;
}

+ (id)optionsCreditWithDictionary:(NSDictionary *)aDict
{
    return [[self alloc] initWithDictionary:aDict];
}

- (NSUInteger)count
{
    return [items count];
}

- (void)addItem:(SPOptionCreditItem *)anItem
{
    [items addObject:anItem];
}

- (void)removeItem:(SPOptionCreditItem *)anItem
{
    [items removeObject:anItem];
}

- (SPOptionCreditItem *)itemAtIndex:(NSUInteger)index
{
    return [items objectAtIndex:index];
}
@end
