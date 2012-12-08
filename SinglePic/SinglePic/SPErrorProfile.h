//
//  SPErrorProfile.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-12-08.
//
//

#import <Foundation/Foundation.h>

typedef void(^errorHandlerBlock)(NSError*);

@interface SPErrorProfile : NSObject
@property (retain) NSString* url;
@property (retain) NSString* serverError;
@property (nonatomic, copy) errorHandlerBlock handlerBlock;

+(id)profileWithURLString:(NSString*)urlString andErrorHandler:(errorHandlerBlock)handler;
+(id)profileWithURLString:(NSString*)urlString andServerError:(NSString*)serverError andErrorHandler:(errorHandlerBlock)handler;
-(id)initWithURLString:(NSString*)urlString andErrorHandler:(errorHandlerBlock)handler;
-(id)initWithURLString:(NSString*)urlString andServerError:(NSString*)serverError andErrorHandler:(errorHandlerBlock)handler;

-(BOOL)evaluateError:(NSError*)error;
-(void)handleError:(NSError*)error;
@end
