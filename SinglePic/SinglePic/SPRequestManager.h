//
//  PMARequestManager.h
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPSingleton.h"
#import "CJSONDeserializer.h"
#import "AFHTTPClient.h"
#import "SPWebServiceError.h"

@class SPWebServiceRequest;

@interface SPRequestManager : SPSingleton
@property (readonly) NSString* userToken;

//Reachability
-(void)EnableRealtimeReachabilityMonitoring;
-(void)ManuallyRefreshReachability;
//User Token Management
-(void)setUserToken:(NSString *)userToken;
-(void)setUserToken:(NSString *)userToken synchronize:(BOOL)synchronize;
-(void)removeUserToken;
-(void)removeUserTokenSynchronize:(BOOL)synchronize;
//Web Service Methods
-(void)getFromNamespace:(REQUEST_NAMESPACE)name withParameter:(NSString*)parameter requiringToken:(BOOL)requiresToken;
-(void)getFromNamespace:(REQUEST_NAMESPACE)name withParameter:(NSString*)parameter requiringToken:(BOOL)requiresToken withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)(SPWebServiceError* error))onError;
-(void)getFromNamespace:(REQUEST_NAMESPACE)name withParameter:(NSString*)parameter requiringToken:(BOOL)requiresToken withRetryCount:(int)retryCount withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)(SPWebServiceError* error))onError;
-(void)deleteFromNamespace:(REQUEST_NAMESPACE)name withParameter:(NSString*)parameter requiringToken:(BOOL)requiresToken withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)(SPWebServiceError* error))onError;
-(void)postToNamespace:(REQUEST_NAMESPACE)name withParameter:(NSString *)parameter andPayload:(id)payload requiringToken:(BOOL)requiresToken;
-(void)postToNamespace:(REQUEST_NAMESPACE)name withParameter:(NSString*)parameter andPayload:(id)payload requiringToken:(BOOL)requiresToken withCompletionHandler:(void (^)(id responseObject))onCompletion andErrorHandler:(void(^)(SPWebServiceError* error))onError;
//Image Methods
-(void)putToURL:(NSURL*)url withPayload:(id)payload withCompletionHandler:(void (^)(id responseObject))onCompletion andProgressHandler:(void (^)(float progress))onProgress andErrorHandler:(void(^)(NSError* error))onError;
-(void)getImageFromURL:(NSURL*)url withCompletionHandler:(void (^)(UIImage* responseImage))onCompletion andErrorHandler:(void(^)(NSError* error))onError;
@end