#import "SPCaptureHelper.h"
#import <ImageIO/ImageIO.h>

@interface SPCaptureHelper()
{
    BOOL isFrontCamera;
    BOOL isFlashMode;
}
@property (retain) AVCaptureStillImageOutput *stillImageOutput;
@end

@implementation SPCaptureHelper
#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
		[self setCaptureSession:[[AVCaptureSession alloc] init]];
        isFrontCamera = NO;
        isFlashMode = NO;
        
        #if TARGET_OS_IPHONE
        NSArray *devices = [AVCaptureDevice devices];
        for (AVCaptureDevice *device in devices) {
            
            if ([device isFlashActive])
            {
                isFlashMode = YES;
            }
        }
        #else
        //Flash is not avaliable on OS X
        isFlashMode = NO;
        #endif
	}
	return self;
}
- (void)addVideoPreviewLayer
{
	[self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];    
}
- (void)addVideoInputFrontCamera:(BOOL)front {
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera = nil;
    AVCaptureDevice *backCamera = nil;
    
    for (AVCaptureDevice *device in devices) {
    
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                backCamera = device;
            }
            else {
                frontCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    
    if (front && frontCamera)
    {
        AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!error)
        {
            if ([[self captureSession] canAddInput:frontFacingCameraDeviceInput]) {
                
                [[self captureSession] addInput:frontFacingCameraDeviceInput];
                isFrontCamera = YES;
            }
            else
            {
                NSLog(@"Couldn't add front facing video input");
            }
        }
    }
    else if(backCamera) //If back, or front doesn't exist
    {
        AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!error)
        {
            if ([[self captureSession] canAddInput:backFacingCameraDeviceInput]) {
                
                [[self captureSession] addInput:backFacingCameraDeviceInput];
                isFrontCamera = NO;
            }
            else
            {
                NSLog(@"Couldn't add back facing video input");
            }
        }
    }
}
- (BOOL)isFlashMode
{
    return isFlashMode;
}
- (BOOL)canSetFlashMode
{
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        
        if ([device hasMediaType:AVMediaTypeVideo] && [device hasFlash])  {
            return YES;
        }
    }
    return NO;
}
- (void)switchFlashMode
{
    isFlashMode = !isFlashMode; //Switch states
    
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        
        if ([device hasMediaType:AVMediaTypeVideo] && [device hasFlash])  {
            
            if([device lockForConfiguration:nil])
            {
                if(isFlashMode)
                {
                    [device setFlashMode:AVCaptureFlashModeOn];
                }
                else
                {
                    [device setFlashMode:AVCaptureFlashModeOff];
                }
            }
        }
    }
}
- (void)addStillImageOutput
{
    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [[self stillImageOutput] setOutputSettings:outputSettings];
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    [[self captureSession] addOutput:[self stillImageOutput]];
}
- (BOOL)isFrontCamera
{
    return isFrontCamera;
}
- (BOOL)canSwitchCamera
{
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera = nil;

    for (AVCaptureDevice *device in devices) {

        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionFront) {
                frontCamera = device;
            }
        }
    }
    
    return (frontCamera) ? YES : NO;
}
- (void)switchCamera
{
    isFrontCamera = !isFrontCamera;
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera = nil;
    AVCaptureDevice *backCamera = nil;
    
    for (AVCaptureDevice *device in devices) {
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {

                backCamera = device;
            }
            else {

                frontCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    
    for(id input in [[self captureSession] inputs])
    {
        [[self captureSession] removeInput:input];
    }

    
    if (isFrontCamera && frontCamera) {
        AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!error) {
            if ([[self captureSession] canAddInput:frontFacingCameraDeviceInput]) {
                [[self captureSession] addInput:frontFacingCameraDeviceInput];
            } else {
                NSLog(@"Couldn't add front facing video input");
            }
        }
    } else if(!isFrontCamera && backCamera) {
        AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!error) {
            if ([[self captureSession] canAddInput:backFacingCameraDeviceInput]) {
                [[self captureSession] addInput:backFacingCameraDeviceInput];
            } else {
                NSLog(@"Couldn't add back facing video input");
            }
        }
    }
}
-(void)captureWithCompletion:(void (^)(id capturedImage))onCompletion
{
    AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
            break;
        }
	}
    __unsafe_unretained SPCaptureHelper *weakSelf = self;
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection
                             completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
                                 
                                         CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                         if (exifAttachments) {
                                             NSLog(@"attachements: %@", exifAttachments);
                                         } else {
                                             NSLog(@"no attachments");
                                         }
                                         
                                         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                                        
                                         id image;
                                         #if TARGET_OS_IPHONE
                                            image = [[UIImage alloc] initWithData:imageData];
                                         #else
                                            NSAssert(NO,@"Implement on OS X");
                                         #endif
                                         
                                         [weakSelf setStillImage:image];
                                         
                                         onCompletion(weakSelf.stillImage);
                                         
                                     }];
}
- (void)dealloc {
    
	[[self captureSession] stopRunning];
}
@end
