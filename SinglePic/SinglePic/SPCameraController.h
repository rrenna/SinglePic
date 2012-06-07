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
    IBOutlet SPStyledView* topBarView;
    IBOutlet SPStyledButton* cancelButton;
    IBOutlet SPStyledButton* switchCamerasButton;
    IBOutlet SPStyledButton* takePictureButton;
}
-(IBAction)cancel:(id)sender;
-(IBAction)switchCameras:(id)sender;
-(IBAction)takePicture:(id)sender;
@end
