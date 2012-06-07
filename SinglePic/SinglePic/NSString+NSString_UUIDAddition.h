//
//  NSString+NSString_UUIDAddition.h
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-15.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UUIDAddition)
// return a new autoreleased UUID string
+ (NSString *)generateUUIDString;
@end
