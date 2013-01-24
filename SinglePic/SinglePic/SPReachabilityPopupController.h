//
//  SPReachabilityView.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPReachabilityReporter.h"

@class SPReachabilityPopupController;

@interface SPReachabilityPopupController : NSObject <SPReachabilityReporter,UIAlertViewDelegate>

-(void)show;
-(void)hide;
@end
