//
//  SPCaptureManager.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-10-18.
//
//

#import <AVFoundation/AVFoundation.h>

#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"

@interface SPCaptureHelper : NSObject

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) UIImage *stillImage;
@property (retain) AVCaptureSession *captureSession;

- (void)addVideoPreviewLayer;
- (void)addStillImageOutput;
- (void)addVideoInputFrontCamera:(BOOL)front;
- (BOOL)isFlashMode;
- (BOOL)canSetFlashMode;
- (void)switchFlashMode;
- (BOOL)isFrontCamera;
- (BOOL)canSwitchCamera;
- (void)switchCamera;
- (void)captureWithCompletion:(void (^)(UIImage* capturedImage))onCompletion;

@end
