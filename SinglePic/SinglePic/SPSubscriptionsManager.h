//
//  SPSubscriptionsManager.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-02-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPSingleton.h"
#import <StoreKit/StoreKit.h>

@interface SPSubscriptionsManager : SPSingleton <SKProductsRequestDelegate>
{
@private
    SKProductsRequest* productRequest;
}
//Retrieve iTunes Products
-(void)retrieveITunesProducts;
//Retrieve Transactions
-(void)getTransactionsWithCompletionHandler:(void (^)())onCompletion andErrorHandler:(void(^)())onError;
@end
