//
//  MHAddItemViewController.m
//  
//
//  Created by Konrad Gnoinski on 11/03/14.
//
//

#import "MHAddItemViewController.h"
#import "MHAddItem2ViewController.h"
#import "MHMedia.h"
#import "MHMediaHelper.h"
#import "MHDatabaseManager.h"

@interface MHAddItemViewController ()

@end

@implementation MHAddItemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.capturedImages = [[NSMutableArray alloc]init];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //if no camera, disable camera button
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [[self takePicture] setHidden:YES];
        self.view.backgroundColor = [UIColor colorWithRed:0.09375 green:0.09375 blue:0.09375 alpha:1.0];
        [self.navigationController.navigationBar setBarTintColor:[UIColor navigationBarBackgroundColor]];
        [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    }
}

- (IBAction)showImagePickerForCamera:(id)sender {
    
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)showImagePickerForPhotoLibrary:(id)sender {
    
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    
    
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
    CFURLRef url = CFURLCreateFromFileSystemRepresentation (kCFAllocatorDefault, (const UInt8 *)[fileName UTF8String], [fileName length], false);
    
    if (!url) {
        printf ("Bad input file path\n");
        return false;
    }
    
    CGImageSourceRef myImageSource;
    
    myImageSource = CGImageSourceCreateWithURL(url, NULL);
    
    CFDictionaryRef imagePropertiesDictionary;
    
    imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(myImageSource, 0, NULL);
    
    CFNumberRef imageLocation = (CFNumberRef)CFDictionaryGetValue(imagePropertiesDictionary, kCGImagePropertyGPSDictionary);
    if (!imageLocation)
    {
        CFRelease(imagePropertiesDictionary);
        CFRelease(myImageSource);
        
        NSLog(@"No location");
        return false;
    }
    else
    {
        return true;
    }
    
}

- (CLLocationCoordinate2D)locationForImage:(NSString *)fileName
{
    CFURLRef url = CFURLCreateFromFileSystemRepresentation (kCFAllocatorDefault, (const UInt8 *)[fileName UTF8String], [fileName length], false);
    
    if (!url)
    {
        printf ("Bad input file path\n");
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
        NSLog(@"No location");
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
        
        return CLLocationCoordinate2DMake(latitude, longtitude);
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
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    if ([self.capturedImages count] > 0) {
        if ([self.capturedImages count] == 1) {
            [self performSegueWithIdentifier:@"goToAddItem2" sender:self];
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

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
        NSLog(@"tak");
       // MHAddItem2ViewController *ng = [segue destinationViewController];
       // ng.capturedImages = self.capturedImages;
}



@end

