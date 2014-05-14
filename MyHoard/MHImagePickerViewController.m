//
//  MHImagePickerViewController.m
//  MyHoard
//
//  Created by user on 3/2/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "MHImagePickerViewController.h"
#import "MHMedia.h"
#import "MHDatabaseManager.h"
#import "MHRoundButton.h"
#import "MHLocation.h"

const NSString* const kMHImagePickerInfoImage = @"kMHImagePickerInfoImage";
const NSString* const kMHImagePickerInfoLocation = @"kMHImagePickerInfoLocation";

@interface MHImagePickerViewController ()
{
    NSDictionary* _mediaInfo;
}

@end

@implementation MHImagePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[MHLocation sharedInstance] startGettingLocation];

    self.delegate = self;
    
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil];
        
        _overlayView.topView.backgroundColor = [UIColor cameraBottomBarBackgroundColor];
        _overlayView.bottomView.backgroundColor = [UIColor cameraBottomBarBackgroundColor];
        _overlayView.takePhotoButton.cornerRadius = _overlayView.takePhotoButton.frame.size.width / 2;
        _overlayView.imageView.hidden = YES;
        
        if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            _overlayView.cameraButton.enabled = NO;
        }
        
//        self.showsCameraControls = NO;
//        self.delegate = self;
    }
    
    self.allowsEditing = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

//    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
//        [self.view addSubview:_overlayView];
//        _overlayView.frame = self.view.bounds;
//
//        self.cameraViewTransform = CGAffineTransformScale(self.cameraViewTransform, 1, 1.5);        
//    }
}

- (IBAction)cameraButtonPressed:(id)sender {
    if (self.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    } else {
        self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
}

- (IBAction)takePhotoButtonPressed:(id)sender {
    [self takePicture];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)retakeButtonPressed:(id)sender {
    _overlayView.imageView.hidden = YES;
    _overlayView.imageView.image = nil;
    _overlayView.topView.hidden = NO;
    _overlayView.bottomView.hidden = NO;
}

- (NSDictionary*)infoDictionaryWithImage:(UIImage *)image andLocation:(CLLocation *)location {
 
    NSMutableDictionary* d = [NSMutableDictionary dictionary];
    if (image) {
        d[kMHImagePickerInfoImage] = image;
    }
    
    if (location) {
        d[kMHImagePickerInfoLocation] = location;
    }

    return d;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[MHLocation sharedInstance] stopGettingLocation];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    _mediaInfo = info;
    _overlayView.imageView.image = info[UIImagePickerControllerOriginalImage];
    _overlayView.imageView.hidden = NO;
    _overlayView.topView.hidden = YES;
    _overlayView.bottomView.hidden = YES;
    
    __block UIImage* image = info[UIImagePickerControllerOriginalImage];

    if (self.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:info[UIImagePickerControllerReferenceURL]
                 resultBlock:^(ALAsset *asset) {
                     CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
                     
                     _completionBlock([self infoDictionaryWithImage:image andLocation:location]);
                 }
         
                failureBlock:^(NSError *error) {
                    _completionBlock([self infoDictionaryWithImage:image andLocation:nil]);
                }];
    } else {
        
        _completionBlock([self infoDictionaryWithImage:image andLocation:[MHLocation sharedInstance].currentLocation]);
        
    }
    
    [[MHLocation sharedInstance] stopGettingLocation];
}

@end
