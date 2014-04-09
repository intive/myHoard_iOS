//
//  MHSliderMenuViewController.m
//  MyHoard
//
//  Created by user on 09/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHSliderMenuViewController.h"

@implementation MHSliderMenuViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma SlideMenu

//this must be kept in sync with left menu view controller

- (NSString *)segueIdentifierForIndexPathInLeftMenu:(NSIndexPath *)indexPath {
    
    NSString *identifier;
    
    switch (indexPath.row) {
        case 0:
            identifier = @"mainSegue";
            break;
        case 1:
            identifier = @"collectionSegue";
            break;
        case 2:
            identifier = @"profileSegue";
            break;
        default:
            break;
    }
    
    return identifier;
}

- (void) configureSlideLayer:(CALayer *)layer
{
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 1;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.masksToBounds = NO;
    layer.shadowPath =[UIBezierPath bezierPathWithRect:layer.bounds].CGPath;
}

- (void)configureLeftMenuButton:(UIButton *)button {
    
    CGRect frame = button.frame;
    frame.origin = CGPointMake(0, 0);
    frame.size = CGSizeMake(15, 15);
    button.frame = frame;
    
    [button setImage:[UIImage imageNamed:@"hamburger.png"] forState:UIControlStateNormal];
}


@end
