//
//  SPCaptureManager.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-10-18.
//
//

#import "SPSingleton.h"
#import <AVFoundation/AVFoundation.h>

#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"

@interface SPCaptureHelper : NSObject

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) UIImage *stillImage;

- (void)addVideoPreviewLayer;
- (void)addStillImageOutput;
- (void)addVideoInputFrontCamera:(BOOL)front;
-(void)captureWithCompletion:(void (^)(UIImage* capturedImage))onCompletion;

@end
