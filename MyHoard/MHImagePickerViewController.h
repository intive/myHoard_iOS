//
//  MHImagePickerViewController.h
//  MyHoard
//
//  Created by user on 3/2/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <CoreLocation/CoreLocation.h>


@interface MHImagePickerViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *MHIPView;
@property (weak, nonatomic) IBOutlet UIToolbar *MHIPToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *MHIPDoneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *MHIPTakePictureButton;

@property (nonatomic) UIImagePickerController *imagePickerController;

@property (nonatomic) NSMutableArray *capturedImages;

- (IBAction)showImagePickerForCamera:(id)sender;
- (IBAction)showImagePickerForPhotoLibrary:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (CLLocationCoordinate2D)locationForImage:(NSString *)fileName;
- (BOOL)isLocationInImage:(NSString *)fileName;

@end
