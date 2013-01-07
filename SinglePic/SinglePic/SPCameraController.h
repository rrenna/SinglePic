//
//  SPCameraController.h
//  SinglePic
//
//  Created by Ryan Renna on 12-02-06.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPTabContentViewController.h"

@interface SPCameraController : SPTabContentViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    IBOutlet UIView* cameraContainerView;
    IBOutlet UIImageView* cameraPreviewImageView;
    IBOutlet UIBarButtonItem* switchFlashModeButton;
    IBOutlet UIBarButtonItem* switchCameraBarButton;
    IBOutlet UIView *statusView;
    IBOutlet SPLabel *statusLabel;
    IBOutlet SPStyledButton *statusCancelButton;
    IBOutlet SPStyledButton *statusProceedButton;
    IBOutlet UIProgressView *uploadProgressBar;
    IBOutlet UIButton *takePictureButton;
}
-(IBAction)cancel:(id)sender;
-(IBAction)switchCameras:(id)sender;
-(IBAction)switchFlashMode:(id)sender;
-(IBAction)takePicture:(id)sender;
-(IBAction)statusProceed:(id)sender;
-(IBAction)statusCancel:(id)sender;
@end
