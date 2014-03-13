//
//  MHAddItemViewController.h
//  
//
//  Created by Konrad Gnoinski on 11/03/14.
//
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <CoreLocation/CoreLocation.h>

@interface MHAddItemViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *MHIPView;
@property (weak, nonatomic) IBOutlet UIToolbar *MHIPToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *MHIPDoneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *MHIPTakePictureButton;
@property (weak, nonatomic) IBOutlet UIButton *takePicture;

@property (nonatomic) UIImagePickerController *imagePickerController;

@property (nonatomic) NSMutableArray *capturedImages;

- (IBAction)showImagePickerForCamera:(id)sender;
- (IBAction)showImagePickerForPhotoLibrary:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (CLLocationCoordinate2D)locationForImage:(NSString *)fileName;
- (BOOL)isLocationInImage:(NSString *)fileName;

@end
