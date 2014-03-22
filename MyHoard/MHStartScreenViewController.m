//
//  MHStartScreenViewController.m
//  MyHoard
//
//  Created by user on 22/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHStartScreenViewController.h"

@interface MHStartScreenViewController ()

@end

@implementation MHStartScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    MHLoginAndRegisterViewController *loginAndRegisterViewController = [[MHLoginAndRegisterViewController alloc]init];
    loginAndRegisterViewController = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"LoginSegue"]) {
        
        if ([loginAndRegisterViewController view]) {
            if (!loginAndRegisterViewController.confirmPasswordTextField.hidden && !loginAndRegisterViewController.passwordStrengthLabel1.hidden && !loginAndRegisterViewController.passwordStrengthView.hidden) {
                loginAndRegisterViewController.confirmPasswordTextField.hidden = YES;
                loginAndRegisterViewController.passwordStrengthLabel1.hidden = YES;
                loginAndRegisterViewController.passwordStrengthView.hidden = YES;
                loginAndRegisterViewController.navigationItem.title = @"Login";
            }
        }
        
    }
}


@end
