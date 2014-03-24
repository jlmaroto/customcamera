//
//  CustomCameraViewController.h
//  CustomCamera
//
//  Created by Shane Carr on 1/3/14.
//
//

#import <UIKit/UIKit.h>

// We can't import the CustomCamera class because it would make a circular reference, so "fake" the existence of the class like this:
@class CustomCamera;
@class CCCameraPicker;

@interface CustomCameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

// Action method
-(IBAction) takePhotoButtonPressed:(id)sender forEvent:(UIEvent*)event;
-(IBAction) changeCamera:(id)sender forEvent:(UIEvent*)event;

// Declare some properties (to be explained soon)
@property (weak, nonatomic) IBOutlet UIImageView *ImageView;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) CustomCamera* plugin;
@property (strong, nonatomic) UIImagePickerController* cameraPicker;
@property (weak, nonatomic) IBOutlet UIButton *fotos;
@property (readwrite, assign) BOOL hasPendingOperation;
@property (readwrite, atomic) int cameraFlashMode;
@end