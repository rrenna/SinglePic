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
    [topBarView setStyle:STYLE_TAB];
    [cancelButton setStyle:STYLE_TAB];
    
    [switchCamerasButton setDepth:DEPTH_INSET];
    [switchCamerasButton setStyle:STYLE_TAB];
    [takePictureButton setStyle:STYLE_CONFIRM_BUTTON];
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
            switchCamerasButton.enabled = YES;
        }

        [cameraContainerView addSubview:imagePicker.view];
    }
    
    imagePicker.view.alpha = 0.0;
    
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
    [imagePicker release];
    [super dealloc];
}
#pragma mark - Overriden methods
-(void)close
{
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
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self.imagePicker takePicture];
    }
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
    [UIView animateWithDuration:1.0 animations:^
    {
        imagePicker.view.alpha = 1.0;
    }];
    
}
#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    cameraPreviewImageView.image = [UIImage imageWithCGImage:originalImage.CGImage 
                                                       scale:1.0 orientation: UIImageOrientationLeftMirrored];
    [self setMyPicture:originalImage];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        //The ImagePicker will remove the status bar, this restores it
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
        {
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
    
    [self performSelector:@selector(makeCameraVisible) withObject:nil afterDelay:1.5];
}
@end
