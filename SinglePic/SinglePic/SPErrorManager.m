//
//  SPErrorManager.m
//  SinglePic
//
//  Created by Ryan Renna on 12-02-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPErrorManager.h"
#import "SPWebServiceErrorProfile.h"

@interface SPErrorManager()
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
        SPWebServiceErrorProfile* emailTakenProfile = [SPWebServiceErrorProfile profileWithURLString:@"https://singlepicdating.herokuapp.com/users" andRequestType:WEB_SERVICE_POST_REQUEST andErrorHandler:^
        {
            [[SPErrorManager sharedInstance] alertWithTitle:@"Registration information is invalid" Description:@"This email is already taken, or you've entered a invalid login and passord. Please try again."];
        }];
      
    
        errors = [NSMutableArray new];
        knownErrors = [[NSArray alloc] initWithObjects:emailTakenProfile,nil];
    }
    return self;
}
-(void)dealloc
{
    [errors release];
    [super dealloc];
}

#pragma mark
-(void)alertWithTitle:(NSString*)title Description:(NSString*)description
{
    NSDictionary* infoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:title,NSLocalizedFailureReasonErrorKey,description,NSLocalizedDescriptionKey,nil];
    NSError* alertError = [NSError errorWithDomain:@"" code:0 userInfo:infoDictionary];
    
    [self logError:alertError alertUser:YES allowReporting:NO];
}
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser
{
    [self logError:error alertUser:alertUser allowReporting:YES];
}
-(void)logError:(NSError*)error alertUser:(BOOL)alertUser allowReporting:(BOOL)allowReporting
{   
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
    [errors addObject:error];
    
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
        
        failureAlert.tag = [errors count] - 1; //Index of current error, used to identify the callbacks of this AlertView
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
        NSString* appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
 
        
        NSString* emailSubject = [NSString stringWithFormat:@"[Bug Report : %@]",failureReason];
        NSString* emailBody = [NSString stringWithFormat:@"<html><body><br/><br/><br/><hr/><p>Please Add any details above this line.</p><p>System Version : <b>%@</b><br/>Model : <b>%@</b><br/>SinglePic Version : <b>%@</b><br/>Failure : <b>%@</b> </br>Description : <b>%@</b><br/>Method : <b>%@</b> </p></body></html>",systemVersion,model,appVersion,failureReason,description,WEB_SERVICE_REQUEST_TYPE_NAMES[method]];
        
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
        int errorIndex = alertView.tag;
        if(errorIndex < [errors count])
        {
            [self reportError:[errors objectAtIndex:errorIndex]];   
        }
    }
}
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    int errorIndex = alertView.tag;
    [errors removeObject:[errors objectAtIndex:errorIndex]];
}
#pragma mark - MFMailComposeViewControllerDelegate methods
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}
@end
