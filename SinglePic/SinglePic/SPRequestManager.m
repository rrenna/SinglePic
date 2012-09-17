//
//  PMARequestManager.m
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPRequestManager.h"
#import "SPWebServiceRequest.h"
#import "AFImageRequestOperation.h"
#import "AFJSONRequestOperation.h"

#define USER_DEFAULT_KEY_USER_TOKEN @"USER_DEFAULT_KEY_USER_TOKEN"

@interface SPRequestManager()
@property (retain) AFHTTPClient* httpClient;
@end

@implementation SPRequestManager
@dynamic userToken;
@synthesize httpClient;
#pragma mark - Dynamic Properties
-(NSString*)userToken
{
    if(!userToken)
    {
        //Check if a user token has been saved in NSUserDefaults
        userToken = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_USER_TOKEN] retain];
    }
    return userToken;
}
#pragma mark
-(id)init
{
    self = [super init];
    if(self)
    {
        NSString* baseURL = [[SPSettingsManager sharedInstance] serverAddress];
        self.httpClient = [[[AFHTTPClient alloc] initWithBaseURL: [NSURL URLWithString:baseURL] ] autorelease];
        [self.httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    }
    return self;
}
#pragma mark - User Token Management
-(void)setUserToken:(NSString *)userToken
{
    [self setUserToken:userToken synchronize:YES];
}
-(void)setUserToken:(NSString *)userToken synchronize:(BOOL)synchronize
{
    [self removeUserTokenSynchronize:NO];
    [[NSUserDefaults standardUserDefaults] setObject:userToken forKey:USER_DEFAULT_KEY_USER_TOKEN];
    if(synchronize)[[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)removeUserToken
{
    [self removeUserTokenSynchronize:YES];
}
-(void)removeUserTokenSynchronize:(BOOL)synchronize
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_KEY_USER_TOKEN];
    [userToken release];
    userToken = nil;
    if(synchronize)[[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark - Web Service methods
-(void)getFromNamespace:(REQUEST_NAMESPACE)name withParameter:(NSString*)parameter requiringToken:(BOOL)requiresToken
{
    [self getFromNamespace:name withParameter:parameter requiringToken:requiresToken withCompletionHandler:nil andErrorHandler:nil];
}
-(void)getFromNamespace:(REQUEST_NAMESPACE)name withParameter:(NSString*)parameter requiringToken:(BOOL)requiresToken withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)(SPWebServiceError* error))onError
{    
    [self requestToNamespace:name withType:WEB_SERVICE_GET_REQUEST andParameter:parameter andPayload:nil requiringToken:requiresToken withCompletionHandler:onCompletion andErrorHandler:onError];
}
-(void)deleteFromNamespace:(REQUEST_NAMESPACE)name withParameter:(NSString*)parameter requiringToken:(BOOL)requiresToken withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)(SPWebServiceError* error))onError
{
    [self requestToNamespace:name withType:WEB_SERVICE_DELETE_REQUEST andParameter:parameter andPayload:nil requiringToken:requiresToken withCompletionHandler:onCompletion andErrorHandler:onError];
}
-(void)postToNamespace:(REQUEST_NAMESPACE)name withParameter:(NSString *)parameter andPayload:(id)payload requiringToken:(BOOL)requiresToken
{
    [self requestToNamespace:name withType:WEB_SERVICE_POST_REQUEST andParameter:parameter andPayload:payload requiringToken:requiresToken withCompletionHandler:nil andErrorHandler:nil];
}
-(void)postToNamespace:(REQUEST_NAMESPACE)name withParameter:(NSString*)parameter andPayload:(id)payload requiringToken:(BOOL)requiresToken withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)(SPWebServiceError* error))onError
{
    [self requestToNamespace:name withType:WEB_SERVICE_POST_REQUEST andParameter:parameter andPayload:payload requiringToken:requiresToken withCompletionHandler:onCompletion andErrorHandler:onError];
}


-(NSString*)generatePathForNamespace:(REQUEST_NAMESPACE)namespace andParameter:(NSString*)parameter requiringToken:(BOOL)requiresToken
{
    NSString* path;
    NSString* serverAddress = [[SPSettingsManager sharedInstance] serverAddress];
    NSString* name = REQUEST_NAMESPACES[namespace];
    
    if(parameter)
    {
        if(requiresToken)
        {
            NSString* userToken = [[SPRequestManager sharedInstance] userToken];
            
            NSString * escapedUserToken = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                              NULL,
                                                                                              (CFStringRef)userToken,
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8 );
            
            path = [NSString stringWithFormat:@"%@/%@/token/%@",name,parameter,escapedUserToken];
            [escapedUserToken release];
        }
        else
        {
            path = [NSString stringWithFormat:@"%@/%@",name,parameter];
        }
    }
    else
    {
        if(requiresToken)
        {
            NSString* userToken = [[SPRequestManager sharedInstance] userToken];
            NSString * escapedUserToken = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                              NULL,
                                                                                              (CFStringRef)userToken,
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8 );
            path = [NSString stringWithFormat:@"%@/token/%@",name,escapedUserToken];
            [escapedUserToken release];
        }
        else
        {
            path =  [NSString stringWithFormat:@"%@/",name];
        }
    }
    
    return path;
}

-(void)requestToNamespace:(REQUEST_NAMESPACE)namespace withType:(WEB_SERVICE_REQUEST_TYPE)type andParameter:(NSString*)parameter andPayload:(id)payload requiringToken:(BOOL)requiresToken withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)(SPWebServiceError* error))onError
{    
    NSString* path = [self generatePathForNamespace:namespace andParameter:parameter requiringToken:requiresToken];
    
    if(type == WEB_SERVICE_GET_REQUEST)
    {
        [self.httpClient getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            onCompletion(responseObject);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
            /*
             
             if([responseJSON isKindOfClass:[NSDictionary class]])
             {
             userInfo = [NSMutableDictionary dictionaryWithDictionary:responseJSON];
             }
             else
             {
             userInfo = [NSMutableDictionary dictionary];
             }
             */
            
            [userInfo setObject:[operation.request HTTPMethod] forKey:@"type"];
            
            SPWebServiceError* SPError = [SPWebServiceError errorWithDomain:[operation.request.URL description] code:[[operation response] statusCode] userInfo:userInfo];
            
                //Display an alert
            [[SPErrorManager sharedInstance] logError:SPError alertUser:YES];
            
            
            if(onError)
            {
                onError(SPError);
            }
            
        }];
    }
    else if(type == WEB_SERVICE_POST_REQUEST)
    {
        [self.httpClient postPath:path parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        onCompletion(responseObject);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
            
            //We want to store the error in the dictionary, and add the HTTP type
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
            /*

            if([responseJSON isKindOfClass:[NSDictionary class]])
            {
                userInfo = [NSMutableDictionary dictionaryWithDictionary:responseJSON];
            }
            else
            {
                userInfo = [NSMutableDictionary dictionary];
            }
            */
             
            [userInfo setObject:[operation.request HTTPMethod] forKey:@"type"];
            
            SPWebServiceError* SPError = [SPWebServiceError errorWithDomain:[operation.request.URL description] code:[[operation response] statusCode] userInfo:userInfo];
            
                //Display an alert
            [[SPErrorManager sharedInstance] logError:SPError alertUser:YES];
            
            
            if(onError)
            {
                onError(SPError);
            }
            
        }];
    }
    //TODO: Implement DELETE
}
-(void)putToURL:(NSURL*)url withPayload:(id)payload withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)(NSError* error))onError
{    
    NSData* postData = nil;
    //UIImage representation
    #define COMPRESSION_QUALITY 0.75
    if([payload isKindOfClass:[UIImage class]])
    {
        UIImage* image = (UIImage*)payload;
        //Switching to BMP
        //postData = UIImagePNGRepresentation(image);
        postData = UIImageJPEGRepresentation(image,COMPRESSION_QUALITY);
    }
    //File Path of PNG
    else if([payload isKindOfClass:[NSString class]])
    {
        NSString* filePath = (NSString*)payload;
        UIImage* image = [[UIImage alloc] initWithContentsOfFile:filePath];
        //Switching to BMP
        //postData = UIImagePNGRepresentation(image);
        postData = UIImageJPEGRepresentation(image,COMPRESSION_QUALITY);
        [image release];
    }

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"image/png" forHTTPHeaderField:@"contentType"];
    [request setHTTPBody:postData];
    
    [httpClient enqueueHTTPRequestOperation:
     [httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) 
      {
          onCompletion(responseObject);
      } 
      failure:^(AFHTTPRequestOperation *operation, NSError *error) 
      {
          NSLog(@"PUT Request to URL failed : %@", operation.request.URL);
          
          if(onError)
          {
              onError(error);
          }
      }]
     ]; 
}
-(void)getFromURL:(NSURL*)url withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)(NSError* error))onError
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];    
    
    AFJSONRequestOperation* getJsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        onCompletion(JSON);
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        NSLog(@"GET Request to URL failed : %@", request.URL);
        
        if(onError)
        {
            onError(error);
        }
        
    }];
    
    [getJsonOperation start];
}
-(void)getImageFromURL:(NSURL*)url withCompletionHandler:(void (^)(UIImage* responseImage))onCompletion andErrorHandler:(void(^)(NSError* error))onError
{
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url]; 
    
    AFImageRequestOperation* imageRequest = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:^UIImage *(UIImage *image)
    {
        return image;
    }
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
    {
        onCompletion(image);
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
    {
        
        NSLog(@"GET Image Request to URL failed : %@", request.URL);
        
        if(onError)
        {
            onError(error);
        }
    }];
    
    [httpClient enqueueHTTPRequestOperation:imageRequest];
}
@end
