//
//  MHImagePickerViewController.m
//  MyHoard
//
//  Created by user on 3/2/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHImagePickerViewController.h"
#import "MHMedia.h"
#import "MHDatabaseManager.h"

@interface MHImagePickerViewController ()


@end

@implementation MHImagePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.capturedImages = [[NSMutableArray alloc]init];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //if no camera, disable camera button
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor cameraBottomBarBackgroundColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor cameraBottomBarBackgroundColor]];
    
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    
}


/*- (IBAction)showImagePickerForCamera:(id)sender {
    
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)showImagePickerForPhotoLibrary:(id)sender {
    
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}*/

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {

    if (sourceType == UIImagePickerControllerSourceTypeCamera
        && !([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]
            || [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]))
    {
        //TODO: Show alert about lack of camera device
        return;
    }

    if (self.imageView.isAnimating) {
        
        [self.imageView stopAnimating];
    }
    
    if (self.capturedImages.count > 0) {
        
        [self.capturedImages removeAllObjects];
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        imagePickerController.showsCameraControls = NO;
        
        [[NSBundle mainBundle] loadNibNamed:@"MHImagePickerViewController" owner:self options:nil];
        self.MHIPView.frame = imagePickerController.cameraOverlayView.frame;
        imagePickerController.cameraOverlayView = self.MHIPView;
        self.MHIPView = nil;
    }
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (BOOL)isLocationInImage:(NSString *)fileName
{
    BOOL ret = NO;
    CFURLRef url = CFURLCreateFromFileSystemRepresentation (kCFAllocatorDefault, (const UInt8 *)[fileName UTF8String], [fileName length], false);
    
    if (!url) {
        NSLog(@"%s: Bad input file path", __PRETTY_FUNCTION__);
        return ret;
    }
    
    CGImageSourceRef myImageSource;
    
    myImageSource = CGImageSourceCreateWithURL(url, NULL);
    
    CFDictionaryRef imagePropertiesDictionary;
    
    imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(myImageSource, 0, NULL);
    
    CFNumberRef imageLocation = (CFNumberRef)CFDictionaryGetValue(imagePropertiesDictionary, kCGImagePropertyGPSDictionary);

    if (!imageLocation)
    {
        NSLog(@"%s: No location", __PRETTY_FUNCTION__);
    }
    else
    {
        ret = YES;
    }
    
    CFRelease(imagePropertiesDictionary);
    CFRelease(myImageSource);
    CFRelease(url);

    return ret;
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (CLLocationCoordinate2D)locationForImage:(NSString *)fileName
{
    CFURLRef url = CFURLCreateFromFileSystemRepresentation (kCFAllocatorDefault, (const UInt8 *)[fileName UTF8String], [fileName length], false);
    
    if (!url)
    {
        NSLog (@"%s: Bad input file path", __PRETTY_FUNCTION__);
        return kCLLocationCoordinate2DInvalid;
    }
    
    CGImageSourceRef myImageSource;
    myImageSource = CGImageSourceCreateWithURL(url, NULL);
    CFDictionaryRef imagePropertiesDictionary;
    imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(myImageSource, 0, NULL);
    CFDictionaryRef imageLocation = CFDictionaryGetValue(imagePropertiesDictionary, kCGImagePropertyGPSDictionary);
    if (!imageLocation)
    {
        CFRelease(imagePropertiesDictionary);
        CFRelease(myImageSource);
        CFRelease(url);
        NSLog(@"%s: No location", __PRETTY_FUNCTION__);
        return kCLLocationCoordinate2DInvalid;
    }
    else
    {
        CLLocationDegrees latitude;
        CLLocationDegrees longtitude;
        if ([@"N"  isEqualToString: (NSString *)CFDictionaryGetValue(imageLocation, kCGImagePropertyGPSLatitudeRef)]) {
             latitude = [(NSString *)CFDictionaryGetValue(imageLocation, kCGImagePropertyGPSLatitude) doubleValue];
        } else {
             latitude = -[(NSString *)CFDictionaryGetValue(imageLocation, kCGImagePropertyGPSLatitude) doubleValue];
        }
        if ([@"E"  isEqualToString:(NSString *)CFDictionaryGetValue(imageLocation, kCGImagePropertyGPSLongitudeRef)]) {
             longtitude = [(NSString *)CFDictionaryGetValue(imageLocation, kCGImagePropertyGPSLongitude) doubleValue];
        } else {
             longtitude = -[(NSString *)CFDictionaryGetValue(imageLocation, kCGImagePropertyGPSLongitude) doubleValue];
        }
        
        
        CFRelease(imagePropertiesDictionary);
        CFRelease(myImageSource);
        CFRelease(url);
        
        return CLLocationCoordinate2DMake(latitude, longtitude);
    }
}
- (IBAction)switchCamera:(id)sender{
    self.camera = 0;
    [self addVideoInput];
    self.camera = 1;
}

- (void)addVideoInput {
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack && self.camera%2==0) {
                backCamera = device;
            }
            else if ([device position] == AVCaptureDevicePositionFront && self.camera%2==1) {
                frontCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
    if (!error) {
        if ([[self captureSession] canAddInput:frontFacingCameraDeviceInput])
            [[self captureSession] addInput:frontFacingCameraDeviceInput];
        else {
            NSLog(@"Couldn't add front facing video input");
        }
    }
    
    NSError *error1 = nil;
    AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error1];
    if (!error1) {
        if ([[self captureSession] canAddInput:backFacingCameraDeviceInput])
            [[self captureSession] addInput:backFacingCameraDeviceInput];
        else {
            NSLog(@"Couldn't add front facing video input");
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"cameraSegue"])
    {
        MHSavePhotoViewController *destinationViewController;
        destinationViewController.capturedImages = self.capturedImages;
    }
}




#pragma Xib toolbar actions

- (IBAction)done:(id)sender {

    [self finishAndUpdate];
}

- (IBAction)takePhoto:(id)sender {
    
    [self.imagePickerController takePicture];
}

- (void)finishAndUpdate {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.capturedImages count] > 0) {
        if ([self.capturedImages count] == 1) {
            [self.imageView setImage:[self.capturedImages objectAtIndex:0]];
        }
        
        [self.capturedImages removeAllObjects];
    }
    
    self.imagePickerController = nil;
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    [self.capturedImages addObject:image];
    
    NSURL *imageUrl = [info valueForKey:UIImagePickerControllerReferenceURL];
    
#warning - pass imageUrl to the add item view controller.
    
    [self finishAndUpdate];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
