//
//  SPCameraController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-02-06.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "SVProgressHUD.h"
#import "SPCameraController.h"
#import "SPCaptureHelper.h"

@interface SPCameraController()
@property (retain) SPCaptureHelper* captureHelper;
@property (retain) UIImage* takenImage;
-(void)validatePicture:(UIImage*)image;
-(void)setMyPicture:(UIImage*)image;
-(void)setMyPicture:(UIImage*)image isFaceDetected:(BOOL)faceDetected;
-(void)setFlashIcon:(BOOL)flashEnabled;
-(void)enableViewfinder;
-(void)disableViewfinder;
@end

@implementation SPCameraController

#pragma mark - View lifecycle
-(id)init
{
    self = [self initWithNibName:@"SPCameraController" bundle:nil];
    if(self)
    {
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    //Look and Feel
    [[SPAppDelegate baseController] setStatusBarStyle:STYLE_CHARCOAL];
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"carbon_fibre.png"]];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [statusProceedButton setTitle:NSLocalizedString(@"Proceed",nil) forState:UIControlStateNormal];
    [statusCancelButton setTitle:NSLocalizedString(@"Cancel",nil) forState:UIControlStateNormal];
    
    cameraPreviewImageView.center = CGPointMake(160, -95.0);
    cameraPreviewImageView.image = nil;
    uploadProgressBar.hidden = YES;
    
    if(!self.captureHelper)
    {
        self.captureHelper = [SPCaptureHelper new];
        
        [self.captureHelper addVideoInputFrontCamera:YES]; // set to YES for Front Camera, No for Back camera
        
        [self.captureHelper addStillImageOutput];
        
        [self.captureHelper addVideoPreviewLayer];
        CGRect layerRect = [[cameraContainerView layer] bounds];
        [[self.captureHelper previewLayer] setBounds:layerRect];
        [[self.captureHelper previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
        [[self.captureHelper captureSession] startRunning];
        
        [self enableViewfinder];
        
        if([self.captureHelper canSwitchCamera])
        {
            switchCameraBarButton.enabled = YES;
        }
        
        if([self.captureHelper canSetFlashMode])
        {
            switchFlashModeButton.enabled = YES;
            [self setFlashIcon:[self.captureHelper isFlashMode]];
        }
    }
    
    //Pre-Request upload urls
    [[SPProfileManager sharedInstance] requestURLsToSaveMyPictureWithCompletionHandler:^
     (NSURL *imageUploadURL, NSURL *thumbnailUploadURL) 
    { 
       //No action required, these url's will be properly cached inside the SPProfileManager     
    } 
    andErrorHandler:^
    {
    }];
}
-(void)viewDidDisappear:(BOOL)animated
{
    cameraPreviewImageView.image = nil;
}
#pragma mark - Overriden methods
-(void)close
{
    [self.captureHelper.previewLayer removeFromSuperlayer];
    self.captureHelper = nil;
    
    [[SPAppDelegate baseController] setStatusBarStyle:STYLE_BASE];
    
    [super close];
}
#pragma mark - IBActions
-(IBAction)cancel:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on the Close icon button in the Camera screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    [self close];
}
-(IBAction)switchCameras:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on the Switch Camera icon button in the Camera screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    if([self.captureHelper canSwitchCamera])
    {
        [self.captureHelper switchCamera];
    }
}
-(IBAction)switchFlashMode:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on the Flash icon button in the Camera screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    if([self.captureHelper canSetFlashMode])
    {
        [self.captureHelper switchFlashMode];
    }
    
    //Switch flash icon
    if([self.captureHelper isFlashMode])
    {
        switchFlashModeButton.image = [UIImage imageNamed:@"icon_Flash-on"];
    }
    else
    {
        switchFlashModeButton.image = [UIImage imageNamed:@"icon_Flash-off"];
    }
}
-(IBAction)takePicture:(id)sender
{
    //Perform alternative logic when running on the simulator
    #if TARGET_IPHONE_SIMULATOR
    [Crashlytics setObjectValue:@"Clicked on the take picture button in the Camera screen - simulator." forKey:@"last_UI_action"];
    
    UIImage* modifiedImage = [UIImage imageNamed:@"testingImage"];
    
    [cameraPreviewImageView setImage:modifiedImage borderWidth:6.0 shadowDepth:5.0 controlPointXOffset:83.3 controlPointYOffset:166.6];

    CGAffineTransform swingTransform = CGAffineTransformIdentity;
    swingTransform = CGAffineTransformRotate(swingTransform, 0.06);
    
    [UIView beginAnimations:@"swing" context:nil];
    [UIView setAnimationDuration:0.5];
    
    cameraPreviewImageView.transform = swingTransform;
    cameraPreviewImageView.center = CGPointMake(160,200);
    
    [UIView commitAnimations];
    
    [self validatePicture:modifiedImage];
    #else
    [Crashlytics setObjectValue:@"Clicked on the take picture button in the Camera screen - device." forKey:@"last_UI_action"];
    
    [self disableViewfinder];
    
    //Replace with all white layer
    CALayer* flashColor = [CALayer layer];
    flashColor.frame = cameraContainerView.layer.bounds;
    flashColor.backgroundColor = [UIColor whiteColor].CGColor;
    [cameraContainerView.layer addSublayer:flashColor];
    
    [self.captureHelper captureWithCompletion:^(UIImage *capturedImage) {
       
        //Save image to Camera Roll (if enabled)
        if([[SPSettingsManager sharedInstance] saveToCameraRollEnabled])
        {
            UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil);
        }
        
        UIImage* originalImage = capturedImage;
        UIImage* modifiedImage = nil;
        
        float minDimension = MIN(originalImage.size.width, originalImage.size.height);
        
        //Note X refers to Y on screen, as physical camera is sideways
        float xOffset = (originalImage.size.height - minDimension) / 2;
        
        //xOffset is used to crop an equal amount from the top and bottom of the image
        UIImage *croppedImage = [originalImage croppedImage:CGRectMake(xOffset,0,minDimension,minDimension) ];
        
        CGSize imageSize = croppedImage.size;
        UIGraphicsBeginImageContextWithOptions(imageSize, YES, 1.0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextRotateCTM(ctx, M_PI/2);
        CGContextTranslateCTM(ctx, 0, -imageSize.width);
        CGContextScaleCTM(ctx, imageSize.height/imageSize.width, imageSize.width/imageSize.height);
        CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, imageSize.width, imageSize.height), croppedImage.CGImage);
        modifiedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
  
        [cameraPreviewImageView setImage:modifiedImage borderWidth:6.0 shadowDepth:5.0 controlPointXOffset:83.3 controlPointYOffset:166.6];
    
        CGAffineTransform swingTransform = CGAffineTransformIdentity;
        swingTransform = CGAffineTransformRotate(swingTransform, 0.06);
    
        [UIView beginAnimations:@"swing" context:nil];
        [UIView setAnimationDuration:0.5];
        
        cameraPreviewImageView.transform = swingTransform;

        CGFloat midY = CGRectGetMidY(cameraPreviewImageView.superview.frame);
        cameraPreviewImageView.center = CGPointMake(160,midY - 48);
        
        [UIView commitAnimations];
        
        [self validatePicture:modifiedImage];
    }];
    #endif
}
- (IBAction)statusProceed:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^
    {
        statusView.alpha = 0.0;
        statusProceedButton.alpha = 0.0;
        statusCancelButton.alpha = 0.0;
        takePictureButton.enabled = YES;
    }];
    
    [self setMyPicture:self.takenImage isFaceDetected:NO];
    self.takenImage = nil;
}
- (IBAction)statusCancel:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^
    {
        cameraPreviewImageView.center = CGPointMake(160, -95.0);
        statusView.alpha = 0.0;
        statusProceedButton.alpha = 0.0;
        statusCancelButton.alpha = 0.0;
        takePictureButton.enabled = YES;
        uploadProgressBar.hidden = YES;
        takePictureButton.hidden = NO;
    }];
    
    [self enableViewfinder];
}
#pragma mark - Private methods
-(void)validatePicture:(UIImage*)image
{
    CIImage* cIImage = [CIImage imageWithCGImage:image.CGImage];
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                                context:nil
                                                  options:@{CIDetectorAccuracy:CIDetectorAccuracyLow}];
    NSArray* facialFeatures = [faceDetector featuresInImage:cIImage];
    
    BOOL containsFace = NO;
    for(CIFeature* feature in facialFeatures)
    {
        if([feature isKindOfClass:[CIFaceFeature class]])
        {
            containsFace = YES;
            break;
        }
    }
    
    if(containsFace)
    {        
        [self setMyPicture:image isFaceDetected:YES];
    }
    else
    {
        self.takenImage = image;
        statusLabel.text = NSLocalizedString(@"A face cannot be validated in this photo. Proceed?", nil);
        [UIView animateWithDuration:0.2 animations:^
        {
            statusView.alpha = 1.0;
            statusProceedButton.alpha = 1.0;
            statusCancelButton.alpha = 1.0;
            takePictureButton.enabled = NO;
        }];
    }
}
-(void)setMyPicture:(UIImage*)image
{
    [self setMyPicture:image isFaceDetected:YES];
}
-(void)setMyPicture:(UIImage*)image isFaceDetected:(BOOL)faceDetected
{
    uploadProgressBar.progress = 0.0;
    uploadProgressBar.hidden = NO;
    takePictureButton.hidden = YES;
    
    NSDictionary* imageProperties = (faceDetected) ? @{@"face_detected":@"true"} : @{@"face_detected":@"false"};
    
    [[SPProfileManager sharedInstance] saveMyPicture:image withProperties:imageProperties   andCompletionHandler:^(id responseObject)
     {
        #if defined (BETA)
        [TestFlight passCheckpoint:@"Saved new Image"];
        #endif
         
        [uploadProgressBar setProgress:1.0 animated:YES];
        [self close];
     }
    andProgressHandler:^(float progress)
    {
        [uploadProgressBar setProgress:progress animated:YES];
    } 
    andErrorHandler:^
    {
        [SVProgressHUD show];
        [SVProgressHUD dismissWithError:NSLocalizedString(@"Sorry. There was an error uploading your photo. Please try again.", nil) afterDelay:2.0];

        [self statusCancel:nil];
    }];
}
-(void)setFlashIcon:(BOOL)flashEnabled
{
    //Switch flash icon
    if(flashEnabled)
    {
        switchFlashModeButton.image = [UIImage imageNamed:@"icon_Flash-on"];
    }
    else
    {
        switchFlashModeButton.image = [UIImage imageNamed:@"icon_Flash-off"];
    }
}
-(void)enableViewfinder
{
    [[cameraContainerView layer] addSublayer:[self.captureHelper previewLayer]];
    
    //Fade in viewfinder view
    [UIView animateWithDuration:0.33 animations:^{
        cameraContainerView.alpha = 1.0;
    }];
}
-(void)disableViewfinder
{
    //Remove Preview
    [self.captureHelper.previewLayer removeFromSuperlayer];
    
        //Fade white layer out
    [UIView animateWithDuration:0.33 animations:^{
        cameraContainerView.alpha = 0.0;
    }];
}
@end
