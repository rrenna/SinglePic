//
//  SPReachabilityView.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPRequests.h"
#import "AFHTTPClient.h"

@class SPReachabilityPopupController;

@interface SPReachabilityPopupController : NSObject <UIAlertViewDelegate>
-(SPReachabilityPopupController*)init;
-(void)show;
-(void)hide;
@end
