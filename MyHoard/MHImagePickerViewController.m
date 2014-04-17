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
#import "MHRoundButton.h"

@interface MHImagePickerViewController ()
{
    id<UINavigationControllerDelegate,UIImagePickerControllerDelegate> _realDelegate;
    NSDictionary* _mediaInfo;
}

@end

@implementation MHImagePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    if ([_realDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
		[_realDelegate performSelector:@selector(imagePickerControllerDidCancel:) withObject:self];
	}
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)retakeButtonPressed:(id)sender {
    _overlayView.imageView.hidden = YES;
    _overlayView.imageView.image = nil;
    _overlayView.topView.hidden = NO;
    _overlayView.bottomView.hidden = NO;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    _mediaInfo = info;
    _overlayView.imageView.image = info[UIImagePickerControllerOriginalImage];
    _overlayView.imageView.hidden = NO;
    _overlayView.topView.hidden = YES;
    _overlayView.bottomView.hidden = YES;
}

- (void)setDelegate:(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)delegate {
//    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
//        if ([delegate isEqual:self]) {
//            [super setDelegate:delegate];
//        } else {
//            _realDelegate = delegate;
//        }
//    } else {
        [super setDelegate:delegate];
//    }
}

@end
