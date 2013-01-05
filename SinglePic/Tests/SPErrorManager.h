//
//  SPErrorManager.h
//  SinglePic
//
//  Created by Ryan Renna on 2013-01-05.
//
//

#import <Foundation/Foundation.h>

@interface SPErrorManager : NSObject
+(SPErrorManager*)sharedInstance;

//Stubs
-(void)alertWithTitle:(NSString*)title Description:(NSString*)description;
//Stubs
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser; //Allows Reporting
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser allowReporting:(BOOL)allowReporting;
@end
