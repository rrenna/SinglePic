//
//  SPErrorManager.m
//  SinglePic
//
//  Created by Ryan Renna on 12-02-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPErrorManager.h"
#import "SPWebServiceErrorProfile.h"
#import "LoggerClient.h"

@interface SPErrorManager()
{
    NSMutableArray* errorQueue;
    NSArray* knownErrors; // Known errors are url + httpMethod + error code combinations that when reported are given special treatment
}
-(void)handleUnknownError:(NSError*)error alertUser:(BOOL)alertUser allowReporting:(BOOL)allowReporting;
-(void)reportError:(NSError*)error;
@end

@implementation SPErrorManager
-(id)init
{
    self = [super init];
    if(self)
    {
        //We setup profiles of errors which are understood and can be displayed with static information and special functionality (if required)
        
        //Registration Errors
        //-- Problem assigning bucket
        SPWebServiceErrorProfile* bucketInvalidProfile = [SPWebServiceErrorProfile profileWithURLString:@"users" andServerError:@"no such bucket" andRequestType:WEB_SERVICE_POST_REQUEST andErrorHandler:^
        {
            [[SPErrorManager sharedInstance] alertWithTitle:@"Registration couldn't be completed" Description:@"There was a problem when we tried to create your account. If this problem persists please contact us."];
        }];
        //-- Email already exists
        SPWebServiceErrorProfile* emailTakenProfile = [SPWebServiceErrorProfile profileWithURLString:@"users"  andServerError:@"email exists" andRequestType:WEB_SERVICE_POST_REQUEST andErrorHandler:^
        {
            [[SPErrorManager sharedInstance] alertWithTitle:@"Registration information is invalid" Description:@"This email is already taken. Please try again."];
        }];
        //-- Email is invalid
        SPWebServiceErrorProfile* emailInvalidProfile = [SPWebServiceErrorProfile profileWithURLString:@"users"  andServerError:@"email invalid" andRequestType:WEB_SERVICE_POST_REQUEST andErrorHandler:^
       {
           [[SPErrorManager sharedInstance] alertWithTitle:@"Registration information is invalid" Description:@"This email appears to be invalid. Please try again."];
       }];
       //-- Username already exists
        SPWebServiceErrorProfile* usernameTakenProfile = [SPWebServiceErrorProfile profileWithURLString:@"users"  andServerError:@"username exists" andRequestType:WEB_SERVICE_POST_REQUEST andErrorHandler:^
        {
            [[SPErrorManager sharedInstance] alertWithTitle:@"Registration information is invalid" Description:@"This username is already taken. Please try again."];
        }];
        //Login Erors
        SPWebServiceErrorProfile* loginInvalidProfile = [SPWebServiceErrorProfile profileWithURLString:@"tokens"  andServerError:@"authentication failed" andRequestType:WEB_SERVICE_POST_REQUEST andErrorHandler:^
        {
            [[SPErrorManager sharedInstance] alertWithTitle:@"Invalid Login/Password" Description:@"This doesn't appear to be a valid email and password combination."];
        }];
        SPWebServiceErrorProfile* validateFailedProfile = [SPWebServiceErrorProfile profileWithURLString:@"tokens" andServerError:@"token not found" andRequestType:WEB_SERVICE_GET_REQUEST andErrorHandler:^
        {
            [[SPErrorManager sharedInstance] alertWithTitle:@"Login Expired" Description:@"Your login session has expired. You may have logged in on another device, please log in."];
        }];
        SPWebServiceErrorProfile* emailEmailProfile = [SPWebServiceErrorProfile profileWithURLString:@"token"  andServerError:@"not an email" andRequestType:WEB_SERVICE_POST_REQUEST andErrorHandler:^
        {
            [[SPErrorManager sharedInstance] alertWithTitle:@"Invalid Email" Description:@"This doesn't appear to be a valid email address."];
        }];
        
        errorQueue = [NSMutableArray new];
        knownErrors = [[NSArray alloc] initWithObjects:bucketInvalidProfile,emailTakenProfile,emailInvalidProfile,usernameTakenProfile,loginInvalidProfile,validateFailedProfile,emailEmailProfile,nil];
    }
    return self;
}
#pragma mark
-(void)alertWithTitle:(NSString*)title Description:(NSString*)description
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];

    [alert show];
    [alert release];
}
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser
{
    [self logError:error alertUser:alertUser allowReporting:YES];
}
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser allowReporting:(BOOL)allowReporting
{   
    #if defined (DEBUG)
    //Log the error using NSLogger - if debugging
    NSString* errorType = nil;
    NSString* errorInfo = nil;
    
    if([error userInfo]) {
        errorType = [[error userInfo] objectForKey:@"type"];
        errorInfo = [[error userInfo] objectForKey:@"error"];
    }
    
    LogMessage([error domain], 0, @"type:%@ error:%@",errorType,errorInfo);
    #endif
    
    BOOL handled = NO;
    for(SPWebServiceErrorProfile* errorProfile in knownErrors)
    {
        if([errorProfile evaluateError:error])
        {
            [errorProfile handle];
                //Set flag
            handled = YES;
            break;
        }
    }
    
    if(!handled)
    {
        [self handleUnknownError:error alertUser:alertUser allowReporting:allowReporting];
    }
}
#pragma mark - Private methods
-(void)handleUnknownError:(NSError*)error alertUser:(BOOL)alertUser allowReporting:(BOOL)allowReporting
{
    //Store Error
    [errorQueue addObject:error];
    
    //Display the reason for the failure in the console
    NSLog(@"%@",[error localizedDescription]);
    
    //Log
    //TODO: 
    
    //Alert user
    if(alertUser)
    {
        UIAlertView* failureAlert;
        if(allowReporting)
        {
            failureAlert = [[UIAlertView alloc] initWithTitle:[error localizedFailureReason] message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:ALERT_BUTTON_TITLE_REPORT,nil];
        }
        else
        {
            failureAlert = [[UIAlertView alloc] initWithTitle:[error localizedFailureReason] message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        }
        
        failureAlert.tag = error; //Index of current error, used to identify the callbacks of this AlertView
        failureAlert.delegate = self;
        [failureAlert show];
        [failureAlert release];
    }
}
-(void)reportError:(NSError*)error
{
    //If no descriptive error exists, try to display the http error code
    NSString* failureReason = ([error localizedFailureReason]) ? [error localizedFailureReason] : [NSString stringWithFormat:@"Error %i",[error code]];
    NSString* description = [error localizedDescription];
    WEB_SERVICE_REQUEST_TYPE method = WEB_SERVICE_UNKNOWN_REQUEST;
    if([error respondsToSelector:@selector(type)])
    {
        method = [error performSelector:@selector(type)];
    }
    
    //If beta testing - submit a testflight feedback form with the contents of this error and device information
    #if defined (TESTING)
    NSString* testFlightReport = [NSString stringWithFormat:@"Error:%@ \n Description:%@ Method:%@",failureReason,description,WEB_SERVICE_REQUEST_TYPE_NAMES[method]];
    [TestFlight submitFeedback:testFlightReport];
    #else
    //If this is not a test product, attempt to compose an email for the user to send
    if([MFMailComposeViewController canSendMail])
    {
        NSString* systemVersion = [[UIDevice currentDevice] systemVersion];
        NSString* model = [[UIDevice currentDevice] model];
        NSString* appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        NSString* emailSubject = [NSString stringWithFormat:@"[Bug Report : %@]",failureReason];
        NSString* emailBody = [NSString stringWithFormat:@"<html><body><br/><br/><br/><hr/><p>Please Add any details above this line.</p><p>System Version : <b>%@</b><br/>Model : <b>%@</b><br/>SinglePic Version : <b>%@</b><br/>Failure : <b>%@</b> </br>Description : <b>%@</b><br/>Method : <b>%@</b><br/>UserInfo<hr/><p><i>%@</i><p/> </p></body></html>",systemVersion,model,appVersion,failureReason,description,WEB_SERVICE_REQUEST_TYPE_NAMES[method],error.userInfo];
        
        MFMailComposeViewController *mailCompose = [[[MFMailComposeViewController alloc] init] autorelease];
        mailCompose.mailComposeDelegate = self;
        [mailCompose setToRecipients:[NSArray arrayWithObject:CONTACT_SUPPORT_EMAIL]];
        [mailCompose setSubject:emailSubject];
        [mailCompose setMessageBody:emailBody isHTML:YES];
        
        //Will modally present the mail compose controller over the root controller
        SPBaseController* base = [SPAppDelegate baseController];
        [base presentModalViewController:mailCompose animated:YES];
    }
    #endif
 }
#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:ALERT_BUTTON_TITLE_REPORT])
    {
            NSError* error = (NSError*)alertView.tag;
            [self reportError:error];
    }
}
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [errorQueue removeLastObject];
}
#pragma mark - MFMailComposeViewControllerDelegate methods
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}
@end
