//
//  SPKnownErrorProfile.h
//  SinglePic
//
//  Created by Ryan Renna on 12-02-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPWebServiceError.h"

typedef void(^errorHandlerBlock)(void);

@interface SPWebServiceErrorProfile : NSObject

+(id)profileWithURLString:(NSString*)urlString andRequestType:(WEB_SERVICE_REQUEST_TYPE)type andErrorHandler:(errorHandlerBlock)handler;
-(id)initWithURLString:(NSString*)urlString andRequestType:(WEB_SERVICE_REQUEST_TYPE)type andErrorHandler:(errorHandlerBlock)handler;

-(BOOL)evaluateError:(NSError*)error;
-(void)handle;
@end
