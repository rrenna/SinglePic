//
//  SPKnownErrorProfile.m
//  SinglePic
//
//  Created by Ryan Renna on 12-02-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPWebServiceErrorProfile.h"

@class SPWebServiceError;

@interface SPWebServiceErrorProfile()
@property (retain) NSString* url;
@property (assign) WEB_SERVICE_REQUEST_TYPE type;
@property (nonatomic, copy) errorHandlerBlock handlerBlock;
@end

@implementation SPWebServiceErrorProfile
@synthesize url,type,handlerBlock;

+(id)profileWithURLString:(NSString*)urlString andRequestType:(WEB_SERVICE_REQUEST_TYPE)type andErrorHandler:(errorHandlerBlock)handler
{
    return [[[SPWebServiceErrorProfile alloc] initWithURLString:urlString andRequestType:type andErrorHandler:handler] autorelease];
}
#pragma mark
-(id)initWithURLString:(NSString*)urlString andRequestType:(WEB_SERVICE_REQUEST_TYPE)type andErrorHandler:(errorHandlerBlock)handler
{
    self = [super init];
    if(self)
    {
        self.url = urlString;
        self.type = type;
        self.handlerBlock = handler;
    }
    return self;
}
-(void)dealloc
{
    [url release];
    [handlerBlock release];
    [super dealloc];
}
#pragma mark
-(BOOL)evaluateError:(NSError*)error
{
    if([error isKindOfClass:[SPWebServiceError class]])
    {
        if([[error domain] isEqualToString:url])
        {
            if((WEB_SERVICE_REQUEST_TYPE)[error type] == type)
            {
                return YES;
            }
        }
    }
    return NO;
}
-(void)handle
{
    self.handlerBlock();
}
@end
