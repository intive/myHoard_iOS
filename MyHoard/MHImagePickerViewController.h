//
//  MHImagePickerViewController.h
//  MyHoard
//
//  Created by user on 3/2/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "CameraOverlayView.h"

@interface MHImagePickerViewController : UIImagePickerController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet CameraOverlayView *overlayView;

@end
