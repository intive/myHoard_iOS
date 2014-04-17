//
//  CameraOverlayView.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 16/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MHRoundButton;

@interface CameraOverlayView : UIView

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet MHRoundButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
