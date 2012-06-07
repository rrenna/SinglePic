//
//  ImageHelper.h
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-18.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageHelper : NSObject

+ (UIImage *) scaleImage:(UIImage*)image toSize: (CGSize)size;
+ (UIImage *) scaleImage:(UIImage*)image proportionalToSize: (CGSize)size;

@end
