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
    
    self.disableMHHamburger = YES;
    self.navigationItem.title = @"Register";
    
    _passwordStrength.numberOfSections = 4;
    _passwordStrength.startColor = [UIColor darkerYellow];
    _passwordStrength.endColor = [UIColor redColor];
    _passwordStrengthLabel.textColor = [UIColor navigationBarBackgroundColor];
    
    _emailTextField.backgroundColor = [UIColor lighterGray];
    _emailTextField.textColor = [UIColor darkerYellow];
    
    _passwordTextField.backgroundColor = [UIColor lighterGray];
    _passwordTextField.textColor = [UIColor darkerYellow];
    
    _passwordTextField1.backgroundColor = [UIColor lighterGray];
    _passwordTextField1.textColor = [UIColor darkerYellow];
    
    [_emailTextField setValue:[UIColor darkerYellow] forKeyPath:@"_placeholderLabel.textColor"];
    [_passwordTextField setValue:[UIColor darkerYellow] forKeyPath:@"_placeholderLabel.textColor"];
    [_passwordTextField1 setValue:[UIColor darkerYellow] forKeyPath:@"_placeholderLabel.textColor"];
    
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField1.secureTextEntry = YES;
    
    _passwordTextField.delegate = self;
    _passwordTextField1.delegate = self;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)textFieldDidChange:(UITextField *)textField {
    if (textField == _passwordTextField) {
        [_passwordStrength setPassword:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return NO;
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
