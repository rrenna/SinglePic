//
//  SPSubscriptionsManager.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-02-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface SPSubscriptionsManager : NSObject <SKProductsRequestDelegate>

+ (SPSubscriptionsManager *)sharedInstance;

//Retrieve iTunes Products
-(void)retrieveITunesProducts;
//Retrieve Transactions
-(void)getTransactionsWithCompletionHandler:(void (^)())onCompletion andErrorHandler:(void(^)())onError;
@end
