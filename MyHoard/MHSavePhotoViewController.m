//
//  MHSavePhotoViewController.m
//  MyHoard
//
//  Created by Milena Gnoińska on 27.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHSavePhotoViewController.h"

@interface MHSavePhotoViewController ()

@end

@implementation MHSavePhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView = [self.capturedImages objectAtIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender{
      [self.navigationController popViewControllerAnimated:YES];
      self.capturedImages = nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"AddPhotoSegue"]) {
        UINavigationController* nc = segue.destinationViewController;
        MHAddItemViewController *vc = (MHAddItemViewController *)nc.visibleViewController;
        vc.capturedImagesURL = self.capturedImages;
    }
}

@end
