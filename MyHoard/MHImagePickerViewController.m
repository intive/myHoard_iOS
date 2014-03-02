//
//  MHImagePickerViewController.m
//  MyHoard
//
//  Created by user on 3/2/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHImagePickerViewController.h"
#import "MHMedia.h"
#import "MHMediaHelper.h"
#import "MHDatabaseManager.h"

@interface MHImagePickerViewController ()

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
}

- (IBAction)showImagePickerForCamera:(id)sender {
    
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)showImagePickerForPhotoLibrary:(id)sender {
    
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    
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

    NSString *imagePath = [imageUrl absoluteString];
    
    NSString *mediaObjId = [[imageUrl path]lastPathComponent];
    
    [MHDatabaseManager insertMediaWithObjId:mediaObjId objItem:nil objCreatedDate:[NSDate date] objOwner:nil objLocalPath:imagePath];
    
    [self finishAndUpdate];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}



@end
