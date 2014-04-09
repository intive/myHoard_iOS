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
    
    if([segue.identifier isEqualToString:@"addPhotoSegue"])
    {
        MHAddItemViewController *destinationViewController;
        destinationViewController.capturedImagesURL = self.capturedImages;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
