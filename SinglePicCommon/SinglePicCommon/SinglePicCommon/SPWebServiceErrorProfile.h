//
//  SPKnownErrorProfile.h
//  SinglePic
//
//  Created by Ryan Renna on 12-02-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPErrorProfile.h"
#import "SPWebServiceError.h"


@interface SPWebServiceErrorProfile : SPErrorProfile

+(id)profileWithURLString:(NSString*)urlString andRequestType:(WEB_SERVICE_REQUEST_TYPE)type andErrorHandler:(errorHandlerBlock)handler;
+(id)profileWithURLString:(NSString*)urlString andServerError:(NSString*)serverError andRequestType:(WEB_SERVICE_REQUEST_TYPE)type andErrorHandler:(errorHandlerBlock)handler;
-(id)initWithURLString:(NSString*)urlString andRequestType:(WEB_SERVICE_REQUEST_TYPE)type andErrorHandler:(errorHandlerBlock)handler;
-(id)initWithURLString:(NSString*)urlString andServerError:(NSString*)serverError andRequestType:(WEB_SERVICE_REQUEST_TYPE)type andErrorHandler:(errorHandlerBlock)handler;
@end
