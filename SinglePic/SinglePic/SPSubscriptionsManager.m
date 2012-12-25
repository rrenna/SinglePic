//
//  SPSubscriptionsManager.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-02-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPSubscriptionsManager.h"

@interface SPSubscriptionsManager()
{
    SKProductsRequest* productRequest;
}
@end

@implementation SPSubscriptionsManager

+ (SPSubscriptionsManager *)sharedInstance
{
    static dispatch_once_t once;
    static SPSubscriptionsManager *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[SPSubscriptionsManager alloc] init]; });
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        NSSet* productIDSet = [NSSet setWithObjects:@"singlePic.1_month", nil];
        productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIDSet];
        productRequest.delegate = self;
    }
    return self;
}
#pragma mark
-(void)retrieveITunesProducts
{
    [productRequest start];
}
-(void)getTransactionsWithCompletionHandler:(void (^)())onCompletion andErrorHandler:(void(^)())onError
{
    [[SPRequestManager sharedInstance] getFromNamespace:REQUEST_NAMESPACE_USERS withParameter:@"me/transactions" requiringToken:YES withCompletionHandler:^(id responseObject)
     {
         NSError *theError = nil;
         NSData* responseData = (NSData*)responseObject;
         NSArray* messagesData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&theError];

         BOOL messagesRecieved = NO;
         
         for(NSDictionary* transactionData in messagesData)
         {
             //
         }
     }
     andErrorHandler:^(NSError* error)
     {

     }];
}
#pragma mark - SKRequestDelegate methods
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Product Request completed");   
    
    /* //USED TO PRINT OUT THE PRODUCTS RECIEVED, DELETE AFTER CONFIRMATION WE'VE SETUP IAP CORRECTLY
    NSMutableString* string = [NSMutableString string];
    for(id thing in [response products])
    {
        [string appendString:[thing description]];
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Recieved" message:string delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles: nil];
    [alertView show];
     */
}
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Product Request error");      
}
@end
