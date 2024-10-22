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
-(void)handleError:(NSError*)error withTitle:(NSString*)title body:(NSString*)body alertUser:(BOOL)alertUser allowReporting:(BOOL)allowReporting;
-(void)handleUnknownError:(NSError*)error alertUser:(BOOL)alertUser allowReporting:(BOOL)allowReporting;
-(void)reportError:(NSError*)error;
@end

@implementation SPErrorManager

+ (SPErrorManager *)sharedInstance
{
    static dispatch_once_t once;
    static SPErrorManager *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[SPErrorManager alloc] init]; });
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        //We setup profiles of errors which are understood and can be displayed with static information and special functionality (if required)
        
        //Registration Errors
        //-- Problem assigning bucket
        SPWebServiceErrorProfile* bucketInvalidProfile = [SPWebServiceErrorProfile profileWithURLString:@"users" andServerError:@"no such bucket" andRequestType:WEB_SERVICE_POST_REQUEST andErrorHandler:^(NSError * error) {
                [[SPErrorManager sharedInstance] alertWithTitle:NSLocalizedString(@"Registration couldn't be completed",nil) Description:NSLocalizedString(@"There was a problem when we tried to create your account.",nil)];
        }];
        //-- Email already exists
        SPWebServiceErrorProfile* emailTakenProfile = [SPWebServiceErrorProfile profileWithURLString:@"users"  andServerError:@"email exists" andRequestType:WEB_SERVICE_POST_REQUEST andErrorHandler:^(NSError * error)
        {
            [[SPErrorManager sharedInstance] alertWithTitle:NSLocalizedString(@"Registration information is invalid",nil) Description:NSLocalizedString(@"This email is already taken. Please try again.",nil)];
        }];
        //-- Email is invalid
        SPWebServiceErrorProfile* emailInvalidProfile = [SPWebServiceErrorProfile profileWithURLString:@"users"  andServerError:@"email invalid" andRequestType:WEB_SERVICE_POST_REQUEST andErrorHandler:^(NSError * error)
       {
           [[SPErrorManager sharedInstance] alertWithTitle:NSLocalizedString(@"Registration information is invalid",nil) Description:NSLocalizedString(@"This email appears to be invalid. Please try again.",nil)];
       }];
       //-- Username already exists
        SPWebServiceErrorProfile* usernameTakenProfile = [SPWebServiceErrorProfile profileWithURLString:@"users"  andServerError:@"username exists" andRequestType:WEB_SERVICE_POST_REQUEST andErrorHandler:^(NSError * error)
        {
            [[SPErrorManager sharedInstance] alertWithTitle:NSLocalizedString(@"Registration information is invalid",nil) Description:NSLocalizedString(@"This username is already taken. Please try again.",nil)];
        }];
        //Login Erors
        SPWebServiceErrorProfile* loginInvalidProfile = [SPWebServiceErrorProfile profileWithURLString:@"tokens"  andServerError:@"authentication failed" andRequestType:WEB_SERVICE_POST_REQUEST andErrorHandler:^(NSError * error)
        {
            [[SPErrorManager sharedInstance] alertWithTitle:NSLocalizedString(@"Invalid Login/Password",nil) Description:NSLocalizedString(@"This doesn't appear to be a valid email and password combination.",nil)];
        }];
        SPWebServiceErrorProfile* validateFailedProfile = [SPWebServiceErrorProfile profileWithURLString:@"tokens" andServerError:@"token not found" andRequestType:WEB_SERVICE_GET_REQUEST andErrorHandler:^(NSError * error)
        {
            [[SPErrorManager sharedInstance] alertWithTitle:NSLocalizedString(@"Login Expired",nil) Description:NSLocalizedString(@"Your login session has expired. You may have logged in on another device, please log in.",nil)];
        }];
        SPWebServiceErrorProfile* emailEmailProfile = [SPWebServiceErrorProfile profileWithURLString:@"token"  andServerError:@"not an email" andRequestType:WEB_SERVICE_POST_REQUEST andErrorHandler:^(NSError * error)
        {
            [[SPErrorManager sharedInstance] alertWithTitle:NSLocalizedString(@"Invalid Email",nil) Description:NSLocalizedString(@"This doesn't appear to be a valid email address.",nil)];
        }];
        
        //Upload Errors
        //-- Problem downloading user's full image
        SPErrorProfile* downloadPhotoProfile = [SPErrorProfile profileWithURLString:@"http://singlepic_image_test.s3.amazonaws.com/full/" andErrorHandler:^(NSError * error) {
            
            [[SPErrorManager sharedInstance] handleError:error withTitle:NSLocalizedString(@"Cannot Access Image",nil) body:NSLocalizedString(@"We're sorry but there was a problem accessing an online image.",nil) alertUser:YES allowReporting:YES];
        }];
        
        errorQueue = [NSMutableArray new];
        knownErrors = [[NSArray alloc] initWithObjects:bucketInvalidProfile,emailTakenProfile,emailInvalidProfile,usernameTakenProfile,loginInvalidProfile,validateFailedProfile,emailEmailProfile,downloadPhotoProfile,nil];
    }
    return self;
}
#pragma mark
-(void)alertWithTitle:(NSString*)title Description:(NSString*)description
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];

    [alert show];
    [alert release];
}
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser
{
    [self logError:error alertUser:alertUser allowReporting:YES];
}
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser allowReporting:(BOOL)allowReporting
{   
    #ifndef RELEASE
    //Log the error using NSLogger - if debugging
    NSString* errorType = nil;
    
    if([error userInfo]) {
        errorType = [[error userInfo] objectForKey:@"type"];
    }
    
    LogMessage([error domain], 0, @"type:%@ error:%@",errorType,error);
    #endif
    
    BOOL handled = NO;
    for(SPWebServiceErrorProfile* errorProfile in knownErrors)
    {
        if([errorProfile evaluateError:error])
        {
            [errorProfile handleError:error];
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
-(void)handleError:(NSError*)error withTitle:(NSString*)title body:(NSString*)body alertUser:(BOOL)alertUser allowReporting:(BOOL)allowReporting
{
    #ifdef BETA
    //Log on Testflight
    TFLog(@"Unknown Error: %@",[error localizedDescription]);
    #endif
    
    #ifdef DEBUG
    //Display the reason for the failure in the console
    NSLog(@"Unknown Error: %@",[error localizedDescription]);
    #endif
    
    if(!error) //Shouldn't happen, but we don't want error handling code to, itself, crash
    {
        error = [NSError errorWithDomain:@"No error was provided to be handled." code:0 userInfo:nil];
    }
    
    //Store Error
    [errorQueue addObject:error];
    
        //Alert user
    if(alertUser)
    {
        NSString* alertTitle;
        NSString* alertBody;
        
        if([[SPSettingsManager sharedInstance] displayVerboseErrorsEnabled])
        {
            alertTitle = [error localizedFailureReason];
            alertBody = [error localizedDescription];
        }
        else
        {
            alertTitle = title;
            alertBody = body;
        }
        
        UIAlertView* failureAlert;
        if(allowReporting)
        {
            failureAlert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertBody delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:ALERT_BUTTON_TITLE_REPORT,nil];
        }
        else
        {
            failureAlert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertBody delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        }
        
        failureAlert.tag = error; //Index of current error, used to identify the callbacks of this AlertView
        failureAlert.delegate = self;
        [failureAlert show];
        [failureAlert release];
    }
}
-(void)handleUnknownError:(NSError*)error alertUser:(BOOL)alertUser allowReporting:(BOOL)allowReporting
{
    [self handleError:error withTitle:NSLocalizedString(@"We're Sorry",nil) body:NSLocalizedString(@"We had a problem connecting to the SinglePic server. Please report this issue if it persists.",nil) alertUser:alertUser allowReporting:allowReporting];
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
    #if defined (BETA)
    NSString* testFlightReport = [NSString stringWithFormat:@"Error:%@ \n Description:%@ Method:%@ UserInfo:%@",failureReason,description,WEB_SERVICE_REQUEST_TYPE_NAMES[method],error.userInfo];
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
