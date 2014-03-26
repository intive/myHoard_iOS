//
//  MHStartScreenViewController.m
//  MyHoard
//
//  Created by user on 22/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHStartScreenViewController.h"
#import "UIColor+customColors.h"

@interface MHStartScreenViewController ()

@end

@implementation MHStartScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setHideNavigationBar:YES];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginButton setBackgroundColor:[UIColor lightButtonColor]];
    [self.loginButton setTitleColor:[UIColor lightButtonTitleColor] forState:UIControlStateNormal];
    self.loginButton.layer.cornerRadius = 6.0;
    self.loginButton.frame = CGRectMake(45, 264, 235, 39);
    
    [self.registerButton setBackgroundColor:[UIColor lightButtonColor]];
    [self.registerButton setTitle:@"Register" forState:UIControlStateNormal];
    [self.registerButton setTitleColor:[UIColor lightButtonTitleColor] forState:UIControlStateNormal];
    self.registerButton.layer.cornerRadius = 6.0;
    self.registerButton.frame = CGRectMake(45, 324, 235, 39);
    
    [self.dontWantAnAccountButton setTitle:@"I don\'t want an account" forState:UIControlStateNormal];
    [self.dontWantAnAccountButton setBackgroundColor:[UIColor lightButtonColor]];
    [self.dontWantAnAccountButton setTitleColor:[UIColor lightButtonTitleColor] forState:UIControlStateNormal];
    self.dontWantAnAccountButton.layer.cornerRadius = 6.0;
    self.dontWantAnAccountButton.frame = CGRectMake(45, 410, 235, 39);
    
    self.startScreenMHLogo.frame = CGRectMake(95, 130, 132, 41);
    
    
    
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
    
    MHLoginAndRegisterViewController * loginAndRegisterViewController = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"LoginSegue"]) {
        
        loginAndRegisterViewController.flowType = MHLoginFlow;
        
    }else if ([segue.identifier isEqualToString:@"RegisterSegue"]) {
        
        loginAndRegisterViewController.flowType = MHRegisterFlow;
    }
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
