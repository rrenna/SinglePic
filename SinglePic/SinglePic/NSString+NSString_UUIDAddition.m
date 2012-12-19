//
//  NSString+NSString_UUIDAddition.m
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-15.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+NSString_UUIDAddition.h"

@implementation NSString (UUIDAddition)
// return a new autoreleased UUID string
+ (NSString *)generateUUIDString;
{
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    // release the UUID
    CFRelease(uuid);
    
    return uuidString;
}
@end
