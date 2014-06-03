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
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user = [defaults stringForKey:@"email"];
    NSString *password = [defaults stringForKey:@"password"];
    if ([[MHAPI getInstance]token]){
        [[MHAPI getInstance]refreshTokenForUser:user withPassword:password completionBlock:^(id object, NSError *error){
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Error"
                                      message:error.localizedDescription
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                
                [alert show];
                
            } else {
                [[MHAPI getInstance]saveToken];
                [self performSegueWithIdentifier:@"collectionSegue" sender:nil];
            }
        }];
    }
    
    
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
    LoginCompletionBlock block = ^{
        [self performSegueWithIdentifier:@"collectionSegue" sender:nil];
    };
    
    if ([segue.identifier isEqualToString:@"LoginSegue"]) {

        UINavigationController* nc = segue.destinationViewController;
        MHLoginAndRegisterViewController * loginAndRegisterViewController = (MHLoginAndRegisterViewController *)nc.visibleViewController;
        loginAndRegisterViewController.flowType = MHLoginFlow;
        loginAndRegisterViewController.loginCompletionBlock = block;
        
    }else if ([segue.identifier isEqualToString:@"RegisterSegue"]) {
        
        UINavigationController* nc = segue.destinationViewController;
        MHLoginAndRegisterViewController * loginAndRegisterViewController = (MHLoginAndRegisterViewController *)nc.visibleViewController;
        loginAndRegisterViewController.flowType = MHRegisterFlow;
        loginAndRegisterViewController.loginCompletionBlock = block;
    }
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setHideNavigationBar:YES];
}

@end
