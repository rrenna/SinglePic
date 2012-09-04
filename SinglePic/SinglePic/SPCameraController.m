//
//  SPCameraController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-02-06.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPCameraController.h"

@interface SPCameraController()
@property (retain) UIImagePickerController* imagePicker;
-(void)setMyPicture:(UIImage*)image;
-(void)makeCameraVisible;
-(void)makeCameraInvisible;
@end

@implementation SPCameraController
@synthesize imagePicker;

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
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"carbon_fibre.png"]];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!self.imagePicker)
    {
        self.imagePicker = [[[UIImagePickerController alloc] init] autorelease];
        imagePicker.delegate = self;
        imagePicker.view.frame = cameraContainerView.bounds;
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.showsCameraControls = NO;
        }
       
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
        {
            switchCameraBarButton.enabled = YES;
        }

        [cameraContainerView addSubview:imagePicker.view];
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
    [self makeCameraInvisible];
}
-(void)dealloc
{
    [imagePicker release];
    [super dealloc];
}
#pragma mark - Overriden methods
-(void)close
{
    [imagePicker.view removeFromSuperview];
    self.imagePicker = nil;
    [super close];
}
#pragma mark - IBActions
-(IBAction)cancel:(id)sender
{
    [self close];
}
-(IBAction)switchCameras:(id)sender
{
    if(self.imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
    {
        self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    else
    {
        self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}
-(IBAction)takePicture:(id)sender
{
    //Perform alternative logic when running on the simulator
    #if TARGET_IPHONE_SIMULATOR
    [self setMyPicture:[UIImage imageNamed:@"testingImage"]];
    #else
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self.imagePicker takePicture];
    }
    #endif
}
#pragma mark - Private methods
-(void)setMyPicture:(UIImage*)image
{
    //[SVProgressHUD showWithStatus:@"Uploading" maskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    [[SPProfileManager sharedInstance] saveMyPicture:image withCompletionHandler:^(id responseObject) 
     {
        #if defined (TESTING)
        [TestFlight passCheckpoint:@"Saved new Image"];
        #endif
         
        [self close];
     } 
     andErrorHandler:^
     {
         cameraPreviewImageView.image = nil;
         //[SVProgressHUD dismissWithError:@"Woops! Couldn't upload. Try again."]; 
     }]; 
}
-(void)makeCameraVisible
{
    [UIView animateWithDuration:0.75 animations:^
    {
        cameraContainerView.alpha = 1.0;
    }];
}
-(void)makeCameraInvisible
{
    cameraContainerView.alpha = 0.0;
}
#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageOrientation originalOrientation = (picker.cameraDevice == UIImagePickerControllerCameraDeviceRear) ? UIImageOrientationRight : UIImageOrientationLeftMirrored;
    
    float minDimension = MIN(originalImage.size.width, originalImage.size.height);
    
    UIImage *croppedImage = [originalImage croppedImage:CGRectMake(0,0,minDimension,minDimension) ];
    UIImage* resizedImage = [UIImage imageWithCGImage:croppedImage.CGImage scale:1.0 orientation: originalOrientation];
    
    cameraPreviewImageView.image = resizedImage;
    imagePicker.view.alpha = 0.0;
    
    [self setMyPicture:resizedImage];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        //The ImagePicker will remove the status bar, this restores it
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
        
        /*
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
        {
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
         */
    }
    
    [self performSelector:@selector(makeCameraVisible) withObject:nil afterDelay:1.0];
}
@end
