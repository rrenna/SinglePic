//
//  SPRequests.h
//  SinglePic
//
//  Created by Ryan Renna on 12-02-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//Used to place information about SinglePic requests that other components may need to reference

typedef enum
{
    REQUEST_NAMESPACE_TOKENS = 0,
    REQUEST_NAMESPACE_USERS = 1,
    REQUEST_NAMESPACE_BUCKETS = 2,
} REQUEST_NAMESPACE;

static NSString* REQUEST_NAMESPACES[3] = {@"tokens",@"users",@"buckets"};
static NSString* SERVER_ADDRESS = @"https://singlepicdating.herokuapp.com";

