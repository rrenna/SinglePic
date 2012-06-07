//
//  SPWebServiceError.h
//  SinglePic
//
//  Created by Ryan Renna on 12-02-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

typedef enum
{
    WEB_SERVICE_UNKNOWN_REQUEST = 0,
    WEB_SERVICE_GET_REQUEST = 1,
    WEB_SERVICE_POST_REQUEST = 2,
	WEB_SERVICE_DELETE_REQUEST = 3
} WEB_SERVICE_REQUEST_TYPE;

const extern NSString* WEB_SERVICE_REQUEST_TYPE_NAMES[4];

@interface SPWebServiceError : NSError
-(WEB_SERVICE_REQUEST_TYPE)type;
@end
