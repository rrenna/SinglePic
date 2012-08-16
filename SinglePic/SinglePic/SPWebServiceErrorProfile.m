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
@property (retain) NSString* serverError;
@property (assign) WEB_SERVICE_REQUEST_TYPE type;
@property (nonatomic, copy) errorHandlerBlock handlerBlock;
@end

@implementation SPWebServiceErrorProfile
@synthesize url,serverError,type,handlerBlock;

+(id)profileWithURLString:(NSString*)urlString andRequestType:(WEB_SERVICE_REQUEST_TYPE)type andErrorHandler:(errorHandlerBlock)handler
{
    return [self profileWithURLString:urlString andServerError:nil andRequestType:type andErrorHandler:handler];
}
+(id)profileWithURLString:(NSString*)urlString andServerError:(NSString*)serverError andRequestType:(WEB_SERVICE_REQUEST_TYPE)type andErrorHandler:(errorHandlerBlock)handler
{
    return [[[SPWebServiceErrorProfile alloc] initWithURLString:urlString andServerError:serverError andRequestType:type andErrorHandler:handler] autorelease];
}
#pragma mark
-(id)initWithURLString:(NSString*)urlString andRequestType:(WEB_SERVICE_REQUEST_TYPE)type andErrorHandler:(errorHandlerBlock)handler
{
    self = [self initWithURLString:urlString andServerError:nil andRequestType:type andErrorHandler:handler];
    return self;
}
-(id)initWithURLString:(NSString*)urlString andServerError:(NSString*)serverError andRequestType:(WEB_SERVICE_REQUEST_TYPE)type andErrorHandler:(errorHandlerBlock)handler
{
    self = [super init];
    if(self)
    {
        self.url = urlString;
        self.serverError = serverError;
        self.type = type;
        self.handlerBlock = handler;
    }
    return self;
}
-(void)dealloc
{
    [url release];
    [serverError release];
    [handlerBlock release];
    [super dealloc];
}
#pragma mark
-(BOOL)evaluateError:(NSError*)error
{
    BOOL match = NO;
    
    if([error isKindOfClass:[SPWebServiceError class]])
    {
        if([[error domain] isEqualToString:url])
        {
            if((WEB_SERVICE_REQUEST_TYPE)[error type] == type)
            {
                //If we only want to catch specific server errors, we'll have filled in the serverError property
                if(serverError) {
                    
                    NSString* returnedServerError = [[error userInfo] objectForKey:@"error"];
                    match = ([returnedServerError isEqualToString:serverError]);
                    
                }
                else
                {
                    match = YES;
                }
            }
        }
    }
    return match;
}
-(void)handle
{
    self.handlerBlock();
}
@end
