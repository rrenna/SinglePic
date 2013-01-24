//
//  SPMessage.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SPMessageThread;

@interface SPMessage : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * incoming;
@property (nonatomic, retain) SPMessageThread *thread;

@end
