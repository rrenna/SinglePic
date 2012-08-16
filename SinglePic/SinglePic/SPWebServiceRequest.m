//
//  PMAWebServiceRequestOperation.m
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPWebServiceRequest.h"

@implementation SPWebServiceRequest
@synthesize name;
@synthesize parameter;
@synthesize requiresToken;

#pragma mark
-(id)initWithNamespace:(REQUEST_NAMESPACE)_name andParameter:(NSString*)_parameter andPayload:(id)payload requiresToken:(BOOL)_requiresToken
{
    self = [super initWithURL:nil];
    if(self)
    {
        name = _name;
        parameter = [_parameter copy];
        requiresToken = _requiresToken;
        
        //If a payload is provided, this is a post request
        if(payload)
        {
            if([payload isKindOfClass:[NSString class]])
            {
                //NOTE: Below line removed on Dima's request, not sure if it'll ever been needed
                // again but keeping reference for historical reasons
                [self addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                
                NSData* stringData = [payload dataUsingEncoding:NSUTF8StringEncoding];
                [self setHTTPBody:stringData];
            }
            else
            {
                [self setHTTPBody:payload];
            }
        }
        
        [self generateURL];
    }
    
    return self;
}
-(void)dealloc
{
    [parameter release];
    [super dealloc];
}
-(void)generateURL
{
    NSURL* webServiceURL;
    
    if(self.parameter)
    {
        if(self.requiresToken)
        {
            NSString* userToken = [[SPRequestManager sharedInstance] userToken];
            
            NSString * escapedUserToken = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                           NULL,
                                                                                           (CFStringRef)userToken,
                                                                                           NULL,
                                                                                           (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                           kCFStringEncodingUTF8 );
            
            NSString* urlString = [NSString stringWithFormat:@"%@/%@/%@/token/%@",SERVER_ADDRESS,REQUEST_NAMESPACES[name],parameter,escapedUserToken];
            webServiceURL = [NSURL URLWithString:urlString];
            [escapedUserToken release];
        }
        else
        {
            webServiceURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@/%@",SERVER_ADDRESS,REQUEST_NAMESPACES[name],parameter]];
        }
    }
    else
    {
        if(self.requiresToken)
        {
            NSString* userToken = [[SPRequestManager sharedInstance] userToken];
            NSString * escapedUserToken = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                              NULL,
                                                                                              (CFStringRef)userToken,
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8 );
            webServiceURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@/token/%@",SERVER_ADDRESS,REQUEST_NAMESPACES[name],escapedUserToken]];
            [escapedUserToken release];
        }
        else
        {
            webServiceURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@",SERVER_ADDRESS,REQUEST_NAMESPACES[name]]];
        }
    }

    [self setURL:webServiceURL];
}
@end
