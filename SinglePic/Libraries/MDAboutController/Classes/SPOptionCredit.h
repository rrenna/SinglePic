//
//  SPOptionCredit.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-10-26.
//
//

#import "MDACCredit.h"
@class SPOptionCreditItem;

@interface SPOptionCredit : MDACCredit {
    NSString *title;
    NSMutableArray *items;
}

@property(nonatomic, copy) NSString *title;
@property(nonatomic, readonly) NSUInteger count;


- (id)initWithTitle:(NSString *)aTitle;
+ (id)optionsCreditWithTitle:(NSString *)aTitle;
- (id)initWithDictionary:(NSDictionary *)aDict;
+ (id)optionsCreditWithDictionary:(NSDictionary *)aDict;

- (void)addItem:(SPOptionCreditItem *)anItem;
- (void)removeItem:(SPOptionCreditItem *)anItem;
- (SPOptionCreditItem *)itemAtIndex:(NSUInteger)index;

@end
