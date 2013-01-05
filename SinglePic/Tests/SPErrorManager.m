//
//  SPErrorManager.m
//  SinglePic
//
//  Created by Ryan Renna on 2013-01-05.
//
//

#import "SPErrorManager.h"

@implementation SPErrorManager

+ (SPErrorManager *)sharedInstance
{
    static dispatch_once_t once;
    static SPErrorManager *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[SPErrorManager alloc] init]; });
    return sharedInstance;
}

//Stubs
-(void)alertWithTitle:(NSString*)title Description:(NSString*)description
{
}
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser
{
}
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser allowReporting:(BOOL)allowReporting
{
}
@end
