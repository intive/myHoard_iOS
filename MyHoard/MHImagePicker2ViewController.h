//
//  MHImagePicker2ViewController.h
//  MyHoard
//
//  Created by Milena Gnoińska on 29.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDatabaseManager.h"
#import "MHAddItem2ViewController.h"

@interface MHImagePicker2ViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) NSMutableArray *capturedImages;
@property (nonatomic) NSString *mediaId;

@end
