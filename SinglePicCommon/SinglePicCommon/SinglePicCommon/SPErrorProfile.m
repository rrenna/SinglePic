//
//  SPErrorProfile.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-12-08.
//
//

#import "SPErrorProfile.h"

@interface SPErrorProfile ()

@end

@implementation SPErrorProfile
@synthesize url = _url,serverError = _serverError,handlerBlock = _handlerBlock;

+(id)profileWithURLString:(NSString*)urlString andErrorHandler:(errorHandlerBlock)handler
{
    return [self profileWithURLString:urlString andServerError:nil andErrorHandler:handler];
}
+(id)profileWithURLString:(NSString*)urlString andServerError:(NSString*)serverError andErrorHandler:(errorHandlerBlock)handler
{
    return [[self alloc] initWithURLString:urlString andServerError:serverError andErrorHandler:handler];
}
-(id)initWithURLString:(NSString*)urlString andErrorHandler:(errorHandlerBlock)handler
{
    self = [super init];
    if(self)
    {
        self.url = urlString;
        self.handlerBlock = handler;
    }
    return self;
}
-(id)initWithURLString:(NSString*)urlString andServerError:(NSString*)serverError andErrorHandler:(errorHandlerBlock)handler
{
    self = [super init];
    if(self)
    {
        self.url = urlString;
        self.serverError = serverError;
        self.handlerBlock = handler;
    }
    return self;
}
#pragma mark
-(BOOL)evaluateError:(NSError*)error
{
    BOOL match = NO;
    
    NSString* verboseURL = [NSString stringWithFormat:@"%@",_url];
    NSDictionary* userInfo = [error userInfo];
    NSURL* failingURL = [userInfo objectForKey:@"NSErrorFailingURLKey"];
    //IF a failure URL is not stored in the userDictionary, check if this error stores a url in the Domain property 
    NSString* failingURLString = (failingURLString) ? [failingURL absoluteString] : [error domain];

    if(failingURLString)
    {
        NSRange rangeOfVerboseURL = [failingURLString rangeOfString:verboseURL options:NSCaseInsensitiveSearch];
        
        if(rangeOfVerboseURL.location != NSNotFound)
        {
            match = YES;
        }
    }

    
    return match;
}
-(void)handleError:(NSError*)error
{
    self.handlerBlock(error);
}
@end
