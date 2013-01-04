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
    IBOutlet __weak UIView* cameraContainerView;
    IBOutlet __weak UIImageView* cameraPreviewImageView;
    IBOutlet __weak UIBarButtonItem* switchFlashModeButton;
    IBOutlet __weak UIBarButtonItem* switchCameraBarButton;
    IBOutlet __weak UIView *statusView;
    IBOutlet __weak SPLabel *statusLabel;
    IBOutlet __weak SPStyledButton *statusCancelButton;
    IBOutlet __weak SPStyledButton *statusProceedButton;
    IBOutlet __weak UIProgressView *uploadProgressBar;
    IBOutlet __weak UIButton *takePictureButton;
}
-(IBAction)cancel:(id)sender;
-(IBAction)switchCameras:(id)sender;
-(IBAction)switchFlashMode:(id)sender;
-(IBAction)takePicture:(id)sender;
-(IBAction)statusProceed:(id)sender;
-(IBAction)statusCancel:(id)sender;
@end
