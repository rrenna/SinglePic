//
//  SPWebServiceError.m
//  SinglePic
//
//  Created by Ryan Renna on 12-02-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPWebServiceError.h"

const NSString* WEB_SERVICE_REQUEST_TYPE_NAMES[4] = {@"Unknown",@"Get",@"Post",@"Delete"};

@implementation SPWebServiceError

- (NSString *)localizedFailureReason
{
    if(self.userInfo)
    {
        return [self.userInfo objectForKey:@"error"];
    }
    return nil;
}
-(WEB_SERVICE_REQUEST_TYPE)type
{
    if(self.userInfo)
    {
        NSString* typeString = [self.userInfo objectForKey:@"type"];
        if([typeString isEqualToString:@"GET"])
        {
            return WEB_SERVICE_GET_REQUEST;
        }
        else if([typeString isEqualToString:@"POST"])
        {
            return WEB_SERVICE_POST_REQUEST;
        }
        //continue - return unknown
    }
    
    return WEB_SERVICE_UNKNOWN_REQUEST;
}
@end
