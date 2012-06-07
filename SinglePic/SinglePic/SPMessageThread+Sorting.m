//
//  SPMessageThread+Sorting.m
//  SinglePic
//
//  Created by Ryan Renna on 12-01-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPMessageThread+Sorting.h"

@implementation SPMessageThread (SPMessageThread_Sorting)
-(NSArray*)sortedMessages
{
        NSSortDescriptor *sortNameDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES] autorelease];
        NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortNameDescriptor, nil] autorelease];
        return [self.messages sortedArrayUsingDescriptors:sortDescriptors];
}
@end
