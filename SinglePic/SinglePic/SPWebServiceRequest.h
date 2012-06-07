//
//  PMAWebServiceRequestOperation.h
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPRequests.h"

@class ASIHTTPRequest;

extern const NSString* REQUEST_NAMESPACES[];

@interface SPWebServiceRequest : NSMutableURLRequest
{
    @private
    REQUEST_NAMESPACE name;
    NSString* parameter;
    
}
@property (readonly) REQUEST_NAMESPACE name;
@property (readonly) NSString* parameter;
@property (readonly) BOOL requiresToken;

-(id)initWithNamespace:(REQUEST_NAMESPACE)_name andParameter:(NSString*)parameter andPayload:(id)payload requiresToken:(BOOL)requiresToken;
-(void)generateURL; //Should be called to regenerate URL after UserToken has been recieved
@end
