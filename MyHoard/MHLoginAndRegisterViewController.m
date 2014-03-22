//
//  MHLoginAndRegisterViewController.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 22/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHLoginAndRegisterViewController.h"
#import "MHPasswordStrengthView.h"

@interface MHLoginAndRegisterViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField1;
@property (weak, nonatomic) IBOutlet MHPasswordStrengthView *passwordStrength;
@property (weak, nonatomic) IBOutlet UILabel *passwordStrengthLabel;

@end

@implementation MHLoginAndRegisterViewController

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
    
#warning - change colors!
    _passwordStrength.numberOfSections = 4;
    _passwordStrength.startColor = [UIColor navigationBarBackgroundColor];
    _passwordStrength.endColor = [UIColor redColor];
    _passwordStrengthLabel.textColor = [UIColor navigationBarBackgroundColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)textFieldDidChange:(UITextField *)textField {
    if (textField == _passwordTextField1) {
        [_passwordStrength setPassword:textField.text];
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
