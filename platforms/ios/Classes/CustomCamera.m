//
//  CustomCamera.m
//  CustomCamera
//
//  Created by Shane Carr on 1/3/14.
//
//

#import "CustomCamera.h"

@implementation CustomCamera

// Cordova command method
-(void) openCamera:(CDVInvokedUrlCommand *)command {
    NSString* callbackId = command.callbackId;
    NSArray* arguments = command.arguments;
    
	// Set the hasPendingOperation field to prevent the webview from crashing
	self.hasPendingOperation = YES;
    
	// Save the CDVInvokedUrlCommand as a property.  We will need it later.
	self.latestCommand = command;
    
	// Make the overlay view controller.
	self.overlay = [[CustomCameraViewController alloc] initWithNibName:@"CustomCameraViewController" bundle:nil];
	self.overlay.plugin = self;
    
	// Display the view.  This will "slide up" a modal view from the bottom of the screen.
	[self.viewController presentViewController:self.overlay.cameraPicker animated:YES completion:nil];
}

// Method called by the overlay when the image is ready to be sent back to the web view
-(void) capturedImageWithPath:(CDVPluginResult*)result {
	[self.commandDelegate sendPluginResult:result callbackId:self.latestCommand.callbackId];
    
	// Unset the self.hasPendingOperation property
	self.hasPendingOperation = NO;
    
    // Hide the picker view
    [self.viewController dismissModalViewControllerAnimated:YES];
    self.overlay=nil;
}

@end
