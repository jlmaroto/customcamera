//
//  CustomCameraViewController.m
//  CustomCamera
//
//  Created by Shane Carr on 1/3/14.
//
//

#import "CustomCamera.h"
#import "CustomCameraViewController.h"
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import <ImageIO/CGImageDestination.h>
#import <MobileCoreServices/UTCoreTypes.h>

#define CDV_PHOTO_PREFIX @"cdv_photo_"

@implementation CustomCameraViewController

// Entry point method
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
        CALayer *btnLayer = [self.fotos layer];
        [btnLayer setMasksToBounds:YES];
        [btnLayer setCornerRadius:5.0f];
        
		// Instantiate the UIImagePickerController instance
		self.cameraPicker = [[UIImagePickerController alloc] init];
        
		// Configure the UIImagePickerController instance
		self.cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		self.cameraPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
		self.cameraPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		self.cameraPicker.showsCameraControls = NO;
        self.cameraPicker.cameraFlashMode=UIImagePickerControllerCameraFlashModeAuto;

		// Make us the delegate for the UIImagePickerController
		self.cameraPicker.delegate = self;
        
		// Set the frames to be full screen
		CGRect screenFrame = [[UIScreen mainScreen] bounds];
		self.view.frame = screenFrame;
		self.cameraPicker.view.frame = screenFrame;
        
		// Set this VC's view as the overlay view for the UIImagePickerController
		self.cameraPicker.cameraOverlayView = self.view;

	
        

    }
	return self;
}
- (IBAction)changeFlash:(id)sender {
    switch (self.cameraPicker.cameraFlashMode) {
        case UIImagePickerControllerCameraFlashModeAuto:
            [self.cameraPicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOn];
            [self.flashButton setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
            [self.flashButton setTitle:@"" forState:UIControlStateNormal];
            break;
        case UIImagePickerControllerCameraFlashModeOn:
            [self.cameraPicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
            [self.flashButton setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
            [self.flashButton setTitle:@"NO" forState:UIControlStateNormal];
            break;
        case UIImagePickerControllerCameraFlashModeOff:
        default:
            [self.cameraPicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeAuto];
            [self.flashButton setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
            [self.flashButton setTitle:@"A" forState:UIControlStateNormal];
            break;
            
            break;
    }
}

// Action method.  This is like an event callback in JavaScript.
-(IBAction) takePhotoButtonPressed:(id)sender forEvent:(UIEvent*)event {
	// Call the takePicture method on the UIImagePickerController to capture the image.
	[self.cameraPicker takePicture];
}
-(IBAction)changeCamera:(id)sender forEvent:(UIEvent*)event {
    if(self.cameraPicker.cameraDevice==UIImagePickerControllerCameraDeviceFront){
        self.cameraPicker.cameraDevice=UIImagePickerControllerCameraDeviceRear;
    }else{
        self.cameraPicker.cameraDevice=UIImagePickerControllerCameraDeviceFront;
    }
}
- (IBAction)selectFromRoll:(id)sender {
    self.cameraPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

// Delegate method.  UIImagePickerController will call this method as soon as the image captured above is ready to be processed.  This is also like an event callback in JavaScript.
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    CDVPluginResult* result = nil;
    
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    // IMAGE TYPE
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
        // get the image
        UIImage* image = nil;
        
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        [self.ImageView setImage:image];
        self.ImageView.hidden=NO;
        
        UIImage* scaledImage = nil;
        
        
        NSData* data = nil;
        // returnedImage is the image that is returned to caller and (optionally) saved to photo album
        UIImage* returnedImage = (scaledImage == nil ? image : scaledImage);
        
        data = UIImageJPEGRepresentation(returnedImage, 1.0);
        
        if(self.cameraPicker.sourceType==UIImagePickerControllerSourceTypeCamera){
            ALAssetsLibrary *library = [ALAssetsLibrary new];
            [library writeImageToSavedPhotosAlbum:returnedImage.CGImage orientation:(ALAssetOrientation)(returnedImage.imageOrientation) completionBlock:nil];
        }
        NSString* docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
        NSError* err = nil;
        NSFileManager* fileMgr = [[NSFileManager alloc] init]; // recommended by apple (vs [NSFileManager defaultManager]) to be threadsafe
        // generate unique file name
        NSString* filePath;
        
        int i = 1;
        do {
            filePath = [NSString stringWithFormat:@"%@/%@%03d.%@", docsPath, CDV_PHOTO_PREFIX, i++, @"jpg"];
        } while ([fileMgr fileExistsAtPath:filePath]);
        
        // save file
        if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[NSURL fileURLWithPath:filePath] absoluteString]];
        }
        
    }else{
        NSString* moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] absoluteString];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:moviePath];
    }
    
    
   	// Tell the plugin class that we're finished processing the image
	[self.plugin capturedImageWithPath:result];
}





-(void)imagePickerControllerDidCancel:(UIImagePickerController *)cameraPicker
{
    if(cameraPicker.sourceType==UIImagePickerControllerSourceTypePhotoLibrary){
        self.cameraPicker.sourceType=UIImagePickerControllerSourceTypeCamera;
    }
}
- (IBAction)skipImage:(id)sender {
CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"no image selected"];   // error callback expects string ATM
[self.plugin capturedImageWithPath:result];
}



@end