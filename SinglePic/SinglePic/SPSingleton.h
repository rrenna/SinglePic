//
//  TFSingleton.h
//  TenFour
//
//  Created by Ryan Renna on 11-06-08.
//  Copyright 2011 TenFour Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

///A basic class designed to be subclassed for singleton classes
@interface SPSingleton : NSObject 
{    
}
+(void)cleanup;
+(id)sharedInstance;
@end
