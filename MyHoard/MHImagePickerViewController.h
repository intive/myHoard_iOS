//
//  MHImagePickerViewController.h
//  MyHoard
//
//  Created by user on 3/2/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CLLocation;

extern const NSString* const kMHImagePickerInfoImage;
extern const NSString* const kMHImagePickerInfoLocation;

typedef void(^MHImagePickerCompletionBlock)(NSDictionary* info);

#import "CameraOverlayView.h"

@interface MHImagePickerViewController : UIImagePickerController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet CameraOverlayView *overlayView;
@property (nonatomic, copy) MHImagePickerCompletionBlock completionBlock;

@end
