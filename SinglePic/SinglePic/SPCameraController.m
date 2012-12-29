//
//  SPCameraController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-02-06.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SPCameraController.h"
#import "SPCaptureHelper.h"

@interface SPCameraController()
@property (retain) SPCaptureHelper* captureHelper;
-(void)setMyPicture:(UIImage*)image;
-(void)setFlashIcon:(BOOL)flashEnabled;
@end

@implementation SPCameraController
@synthesize captureHelper;

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
    
    cameraPreviewImageView.center = CGPointMake(160, -90.0);
    
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
        [[cameraContainerView layer] addSublayer:[self.captureHelper previewLayer]];
        
        [[self.captureHelper captureSession] startRunning];
        
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
    
    [self setMyPicture:modifiedImage];
    #else
    [Crashlytics setObjectValue:@"Clicked on the take picture button in the Camera screen - device." forKey:@"last_UI_action"];
    
    //Remove Preview
    [self.captureHelper.previewLayer removeFromSuperlayer];
    //Replace with all white layer
    CALayer* flashColor = [CALayer layer];
    flashColor.frame = cameraContainerView.layer.bounds;
    flashColor.backgroundColor = [UIColor whiteColor].CGColor;
    [cameraContainerView.layer addSublayer:flashColor];
    //Fade white layer out
    [UIView animateWithDuration:0.33 animations:^{
        cameraContainerView.alpha = 0.0;
    }];
    
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
        cameraPreviewImageView.center = CGPointMake(160,200);
        
        [UIView commitAnimations];
        
        [self setMyPicture:modifiedImage];
    }];
    #endif
}
#pragma mark - Private methods
-(void)setMyPicture:(UIImage*)image
{
    uploadProgressBar.progress = 0.0;
    uploadProgressBar.hidden = NO;

    [[SPProfileManager sharedInstance] saveMyPicture:image  withCompletionHandler:^(id responseObject) 
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
         cameraPreviewImageView.image = nil;
         uploadProgressBar.hidden = YES;
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
@end
