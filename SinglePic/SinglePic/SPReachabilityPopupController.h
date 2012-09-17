//
//  SPReachabilityView.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPRequests.h"

@protocol SPReachabilityPopupDelegate <NSObject>
-(void)reachabilityConfirmedForHostName:(NSString*)hostName;
@end

@interface SPReachabilityPopupController : NSObject <UIAlertViewDelegate>
{
@private
    UIAlertView* alertView;
}
-(SPReachabilityPopupController*)initWithDelegate:(id<SPReachabilityPopupDelegate>)delegate;
-(void)show;
@end
