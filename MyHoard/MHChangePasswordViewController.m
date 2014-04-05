//
//  MHChangePasswordViewController.m
//  MyHoard
//
//  Created by user on 05/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHChangePasswordViewController.h"

@interface MHChangePasswordViewController ()

@end

@implementation MHChangePasswordViewController

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
    
    _passwordTextField.textColor = [UIColor collectionNameFrontColor];
    _confirmNewPasswordTextField.textColor = [UIColor collectionNameFrontColor];
    _changePasswordTextField.textColor = [UIColor collectionNameFrontColor];
    
    _labelBackgroundViewOne.backgroundColor = [UIColor darkerGray];
    _labelBackgroundViewTwo.backgroundColor = [UIColor darkerGray];
    _labelBackgroundViewThree.backgroundColor = [UIColor darkerGray];
    
    _passwordTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"pojecia nie mam co tu ma byc" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
    _confirmNewPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"new password" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
    _changePasswordTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"confirm password" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
    
    _passwordTextField.delegate = self;
    _confirmNewPasswordTextField.delegate = self;
    _changePasswordTextField.delegate = self;
    
    _passwordStrengthLabel.textColor = [UIColor collectionNameFrontColor];
    
    _passwordTextField.secureTextEntry = YES;
    _confirmNewPasswordTextField.secureTextEntry = YES;
    _changePasswordTextField.secureTextEntry = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButton:)];
    self.navigationItem.leftBarButtonItem = closeButton;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"check.png"] style:UIBarButtonItemStylePlain target:self action:@selector(saveButton:)];
    self.navigationItem.rightBarButtonItem = saveButton;



}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
}

- (IBAction)textFieldDidChange:(UITextField *)textField {
    if (textField == _passwordTextField) {
        [_passwordStrengthView setPassword:textField.text];
    }
}

- (void)slideFrame:(BOOL)yesNo {
    
    int movement = (yesNo ? -40 : 40);
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    }];
}

- (void)keyboardDidShow: (NSNotification *) notif{
    
    [self slideFrame: YES];
}

- (void)keyboardDidHide: (NSNotification *) notif{
    
    [self slideFrame: NO];
}

- (IBAction)backButton:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButton:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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

@end
