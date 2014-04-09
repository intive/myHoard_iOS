//
//  MHSliderMenuViewController.m
//  MyHoard
//
//  Created by user on 09/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHSliderMenuViewController.h"

@interface MHSliderMenuViewController ()

@end

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma SlideMenu

- (NSString *)segueIdentifierForIndexPathInLeftMenu:(NSIndexPath *)indexPath {
    
    NSString *identifier;
    
    switch (indexPath.row) {
        case 0:
            identifier = @"mainSegue";
            break;
        case 1:
            identifier = @"profileSegue";
            break;
        default:
            break;
    }
    
    return identifier;
}

- (void)configureLeftMenuButton:(UIButton *)button {
    
    CGRect frame = button.frame;
    frame.origin = (CGPoint){0,0};
    frame.size = (CGSize){15,15};
    button.frame = frame;
    
    [button setImage:[UIImage imageNamed:@"hamburger.png"] forState:UIControlStateNormal];
}


@end
