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
@property (assign) WEB_SERVICE_REQUEST_TYPE type;
@end

@implementation SPWebServiceErrorProfile
@synthesize type = _type;

+(id)profileWithURLString:(NSString*)urlString andRequestType:(WEB_SERVICE_REQUEST_TYPE)type andErrorHandler:(errorHandlerBlock)handler
{
    return [self profileWithURLString:urlString andServerError:nil andRequestType:type andErrorHandler:handler];
}
+(id)profileWithURLString:(NSString*)urlString andServerError:(NSString*)serverError andRequestType:(WEB_SERVICE_REQUEST_TYPE)type andErrorHandler:(errorHandlerBlock)handler
{
    return [[SPWebServiceErrorProfile alloc] initWithURLString:urlString andServerError:serverError andRequestType:type andErrorHandler:handler];
}
#pragma mark
-(id)initWithURLString:(NSString*)urlString andRequestType:(WEB_SERVICE_REQUEST_TYPE)type andErrorHandler:(errorHandlerBlock)handler
{
    self = [self initWithURLString:urlString andServerError:nil andRequestType:type andErrorHandler:handler];
    return self;
}
-(id)initWithURLString:(NSString*)urlString andServerError:(NSString*)serverError andRequestType:(WEB_SERVICE_REQUEST_TYPE)type andErrorHandler:(errorHandlerBlock)handler
{
    self = [super initWithURLString:urlString andServerError:serverError andErrorHandler:handler];
    if(self)
    {
        self.type = type;
    }
    return self;
}
#pragma mark
-(BOOL)evaluateError:(NSError*)error
{
    BOOL match = NO;
    
    if([error isKindOfClass:[SPWebServiceError class]])
    {
        NSString* verboseURL = [NSString stringWithFormat:@"%@%@",[[SPSettingsManager sharedInstance] serverAddress],self.url];
        NSRange rangeOfVerboseURL = [[error domain] rangeOfString:verboseURL options:NSCaseInsensitiveSearch];
        
        if(rangeOfVerboseURL.location != NSNotFound)
        {
            SPWebServiceError* err = (SPWebServiceError*)error;
            if((WEB_SERVICE_REQUEST_TYPE)[err type] == self.type)
            {
                //If we only want to catch specific server errors, we'll have filled in the serverError property
                if(self.serverError) {
                    
                    NSDictionary* responseData = [[error userInfo] objectForKey:@"response"];
                    NSString* returnedServerError = [responseData objectForKey:@"error"];
                    match = ([returnedServerError isEqualToString:self.serverError]);
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
-(void)handleError:(NSError*)error
{
    self.handlerBlock(error);
}
@end
