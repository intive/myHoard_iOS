//
//  MHSavePhotoViewController.h
//  MyHoard
//
//  Created by Milena Gnoińska on 27.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHBaseViewController.h"
#import "MHAddItemViewController.h"

@interface MHSavePhotoViewController : MHBaseViewController

@property (nonatomic) NSMutableArray *capturedImages;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)cancel:(id)sender;

@end
