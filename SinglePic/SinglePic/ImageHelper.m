//
//  ImageHelper.m
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-18.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageHelper.h"

@implementation ImageHelper

+ (UIImage *) scaleImage:(UIImage*)image toSize: (CGSize)size
{
    // Scalling selected image to targeted size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    
    if(image.imageOrientation == UIImageOrientationRight)
    {
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), image.CGImage);
    }
    else
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), image.CGImage);
    
    CGImageRef scaledImage=CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    UIImage *output = [UIImage imageWithCGImage: scaledImage];
    CGImageRelease(scaledImage);
    
    return output;
}

+ (UIImage *) scaleImage:(UIImage*)image proportionalToSize: (CGSize)size1
{
    if(image.size.width>image.size.height)
    {
        size1 = CGSizeMake((image.size.width/image.size.height)*size1.height,size1.height);
    }
    else
    {
        size1 = CGSizeMake(size1.width,(image.size.height/image.size.width)*size1.width);
    }
    return [self scaleImage:image toSize:size1];
}

+ (UIImage *) scaleAndCropImage:(UIImage*) image toFitInDimension:(int)dimension
{
    CGSize proportionalSize;
    if(image.size.width>image.size.height)
    {
        proportionalSize = CGSizeMake((image.size.width/image.size.height)*dimension,dimension);
    }
    else
    {
        proportionalSize = CGSizeMake(dimension,(image.size.height/image.size.width)*dimension);
    }
    
    float minDimension = MIN(proportionalSize.width,proportionalSize.height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, minDimension, minDimension, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(context, CGRectMake(0, 0, minDimension, minDimension));

    if(image.imageOrientation == UIImageOrientationRight)
    {
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -700, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, proportionalSize.height, proportionalSize.width), image.CGImage);
    }
    else
        CGContextDrawImage(context, CGRectMake(0, 0, proportionalSize.width, proportionalSize.height), image.CGImage);
    
    
    CGImageRef scaledImage=CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    UIImage *output = [UIImage imageWithCGImage: scaledImage];
    CGImageRelease(scaledImage);
    
    return output;
}
@end
