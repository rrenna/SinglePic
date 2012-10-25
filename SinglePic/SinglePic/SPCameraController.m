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
@end

@implementation SPCameraController
@synthesize captureHelper;

#pragma mark - View lifecycle
-(id)init
{
    self = [self initWithNibName:@"SPCameraController" bundle:nil];
    if(self)
    {
        //[imagePicker cameraFlashMode];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //Look and Feel
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
        self.captureHelper = [[SPCaptureHelper new] autorelease];
        
        [self.captureHelper addVideoInputFrontCamera:NO]; // set to YES for Front Camera, No for Back camera
        
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
        
        /*
        self.imagePicker = [[[UIImagePickerController alloc] init] autorelease];
        imagePicker.delegate = self;
        imagePicker.view.frame = CGRectMake(0, 0, cameraContainerView.width, cameraContainerView.width);
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
            switchFlashModeButton.enabled = YES;
            imagePicker.showsCameraControls = NO;
            imagePicker.navigationBarHidden = YES;
            imagePicker.toolbarHidden = YES;
            imagePicker.wantsFullScreenLayout = YES;
        }
       
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
        {
            switchCameraBarButton.enabled = YES;
        }

        [cameraContainerView addSubview:imagePicker.view];
         */
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
-(void)dealloc
{
    [self.captureHelper release];
    [super dealloc];
}
#pragma mark - Overriden methods
-(void)close
{
    [self.captureHelper.previewLayer removeFromSuperlayer];
    self.captureHelper = nil;
    
    [super close];
}
#pragma mark - IBActions
-(IBAction)cancel:(id)sender
{
    [SPSoundHelper playTap];
    
    [self close];
}
-(IBAction)switchCameras:(id)sender
{
    [SPSoundHelper playTap];
    
    if([self.captureHelper canSwitchCamera])
    {
        [self.captureHelper switchCamera];
    }

    /*if(self.imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
    {
        //self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        switchFlashModeButton.enabled = YES;
    }
    else
    {
        //self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        switchFlashModeButton.enabled = NO;
    }*/
}
-(IBAction)switchFlashMode:(id)sender
{
    [SPSoundHelper playTap];
    
    /*if(self.imagePicker.cameraFlashMode == UIImagePickerControllerCameraFlashModeOff)
    {
        //imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        switchFlashModeButton.image = [UIImage imageNamed:@"icon_Flash-on"];
    }
    else
    {
        //imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        switchFlashModeButton.image = [UIImage imageNamed:@"icon_Flash-off"];
    }*/
}
-(IBAction)takePicture:(id)sender
{
    //Perform alternative logic when running on the simulator
    #if TARGET_IPHONE_SIMULATOR
    UIImage* modifiedImage = [UIImage imageNamed:@"testingImage"];
    
    [cameraPreviewImageView setImage:modifiedImage borderWidth:6.0 shadowDepth:5.0 controlPointXOffset:83.3 controlPointYOffset:166.6];

    CGAffineTransform swingTransform = CGAffineTransformIdentity;
    swingTransform = CGAffineTransformRotate(swingTransform, 0.06);
    
    [UIView beginAnimations:@"swing" context:cameraPreviewImageView];
    [UIView setAnimationDuration:0.5];
    
    cameraPreviewImageView.transform = swingTransform;
    cameraPreviewImageView.center = CGPointMake(160,200);
    
    [UIView commitAnimations];
    
    [self setMyPicture:modifiedImage];
    #else
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
       
        UIImage* originalImage = capturedImage;
        UIImage* modifiedImage = nil;
        
        float minDimension = MIN(originalImage.size.width, originalImage.size.height);
        
        //Note X refers to Y on screen, as physical camera is sideways
        float xOffset = (originalImage.size.height - minDimension) / 2;
        
        //xOffset is used to crop an equal amount from the top and bottom of the image
        UIImage *croppedImage = [originalImage croppedImage:CGRectMake(xOffset,0,minDimension,minDimension) ];
        
        /*
        if(picker.cameraDevice == UIImagePickerControllerCameraDeviceRear)
        {
            UIImageOrientation originalOrientation = UIImageOrientationRight;
            modifiedImage = [UIImage imageWithCGImage:croppedImage.CGImage scale:1.0 orientation: originalOrientation];
        }
        else
        {*/
            CGSize imageSize = croppedImage.size;
            UIGraphicsBeginImageContextWithOptions(imageSize, YES, 1.0);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextRotateCTM(ctx, M_PI/2);
            CGContextTranslateCTM(ctx, 0, -imageSize.width);
            CGContextScaleCTM(ctx, imageSize.height/imageSize.width, imageSize.width/imageSize.height);
            CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, imageSize.width, imageSize.height), croppedImage.CGImage);
            modifiedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        //}
        
        [cameraPreviewImageView setImage:modifiedImage borderWidth:6.0 shadowDepth:5.0 controlPointXOffset:83.3 controlPointYOffset:166.6];
    
        CGAffineTransform swingTransform = CGAffineTransformIdentity;
        swingTransform = CGAffineTransformRotate(swingTransform, 0.06);
    
        [UIView beginAnimations:@"swing" context:cameraPreviewImageView];
        [UIView setAnimationDuration:0.5];
        
        cameraPreviewImageView.transform = swingTransform;
        cameraPreviewImageView.center = CGPointMake(160,200);
        
        [UIView commitAnimations];
        
        [self setMyPicture:modifiedImage];
    }];
    
    /*
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self.imagePicker takePicture];
    }*/
    #endif
}
#pragma mark - Private methods
-(void)setMyPicture:(UIImage*)image
{
    uploadProgressBar.progress = 0.0;
    uploadProgressBar.hidden = NO;
    
    //[SVProgressHUD showWithStatus:@"Uploading" maskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
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
         //[SVProgressHUD dismissWithError:@"Woops! Couldn't upload. Try again."];
         
     }]; 
}
/*
#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage* modifiedImage = nil;
    
    float minDimension = MIN(originalImage.size.width, originalImage.size.height);
    UIImage *croppedImage = [originalImage croppedImage:CGRectMake(0,0,minDimension,minDimension) ];
    
    if(picker.cameraDevice == UIImagePickerControllerCameraDeviceRear)
    {
        UIImageOrientation originalOrientation = UIImageOrientationRight;
        modifiedImage = [UIImage imageWithCGImage:croppedImage.CGImage scale:1.0 orientation: originalOrientation];
    }
    else
    {
        CGSize imageSize = croppedImage.size;
        UIGraphicsBeginImageContextWithOptions(imageSize, YES, 1.0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextRotateCTM(ctx, M_PI/2);
        CGContextTranslateCTM(ctx, 0, -imageSize.width);
        CGContextScaleCTM(ctx, imageSize.height/imageSize.width, imageSize.width/imageSize.height);
        CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, imageSize.width, imageSize.height), croppedImage.CGImage);
        modifiedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }    
    
    [cameraPreviewImageView setImage:modifiedImage borderWidth:6.0 shadowDepth:15.0 controlPointXOffset:83.3 controlPointYOffset:166.6];
    
        //cameraPreviewImageView.image = modifiedImage;
    
    [self setMyPicture:modifiedImage];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        //The ImagePicker will remove the status bar, this restores it
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
        
            //imagePicker.cameraViewTransform = CGAffineTransformMakeScale(1.0, 1.0);
            //imagePicker.cameraViewTransform = CGAffineTransformTranslate(imagePicker.cameraViewTransform, 0.0, 150.0);
    }
    
    [self performSelector:@selector(makeCameraVisible) withObject:nil afterDelay:1.0];
}*/
- (void)viewDidUnload {
    uploadProgressBar = nil;
    [super viewDidUnload];
}
@end
