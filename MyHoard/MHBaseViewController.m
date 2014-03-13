//
//  MHBaseViewController.m
//  MyHoard
//
//  Created by Grzegorz Pawłowicz on 12.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHBaseViewController.h"
#import "UIColor+customColors.h"

@interface MHBaseViewController ()

@end

@implementation MHBaseViewController

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
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor navigationBarBackgroundColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    self.view.backgroundColor = [UIColor appBackgroundColor];
    
    if (![self MHHamburger]) {
        UIBarButtonItem *hamburger = [[UIBarButtonItem alloc] initWithTitle:@"\u2261" style:UIBarButtonItemStylePlain target:self action:nil];
        self.navigationItem.leftBarButtonItem = hamburger;
    };
    
    if (![self MHLogo]) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    };
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end