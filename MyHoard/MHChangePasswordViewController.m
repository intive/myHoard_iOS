//
//  MHChangePasswordViewController.m
//  MyHoard
//
//  Created by user on 05/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHChangePasswordViewController.h"

@interface MHChangePasswordViewController ()

@property (weak, nonatomic) IBOutlet MHPasswordStrengthView *passwordStrengthView;
@property (strong, nonatomic) MHUserProfile *profile;

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
    
    _passwordStrengthView.numberOfSections = 4;
    _passwordStrengthView.startColor = [UIColor darkerYellow];
    _passwordStrengthView.endColor = [UIColor redColor];
    
    _passwordTextField.textColor = [UIColor collectionNameFrontColor];
    _confirmNewPasswordTextField.textColor = [UIColor collectionNameFrontColor];
    _changePasswordTextField.textColor = [UIColor collectionNameFrontColor];
    
    _labelBackgroundViewOne.backgroundColor = [UIColor darkerGray];
    _labelBackgroundViewTwo.backgroundColor = [UIColor darkerGray];
    _labelBackgroundViewThree.backgroundColor = [UIColor darkerGray];
    
    _passwordTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"mystery field" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
    _confirmNewPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"confirm password" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
    _changePasswordTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"new password" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
    
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

- (IBAction)textFieldDidChange:(UITextField *)textField {
    if (textField == _changePasswordTextField) {
        [_passwordStrengthView setPassword:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
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

-(void)dismissKeyboard {
    
    [_passwordTextField resignFirstResponder];
    [_changePasswordTextField resignFirstResponder];
    [_confirmNewPasswordTextField resignFirstResponder];
}

- (BOOL)dataFieldsValid {
    
    if (![_changePasswordTextField.text length] && ![_confirmNewPasswordTextField.text length]) {
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Alert"
                              message:@"To change password You must provide all of the specified information"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
        [alert show];
        
        return NO;
        
    }
    
    if (![_changePasswordTextField.text isEqualToString:[NSString stringWithFormat:@"%@", _confirmNewPasswordTextField.text]]) {
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Alert"
                              message:@"Passwords do not match"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
        [alert show];
        
        return NO;
        
    }
    
    if ([_changePasswordTextField.text length] < 5) {
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Alert"
                              message:@"Password must be at least 5 characters long"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
        [alert show];
        
        return NO;
    }
    
    return YES;
}

- (void)changeUsersPassword {
    
    [[MHAPI getInstance] readUserWithCompletionBlock:^(MHUserProfile *object, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }else {
            
            [[MHAPI getInstance] updateUser:object.username withPassword:_changePasswordTextField.text andEmail:object.email completionBlock:^(id object, NSError *error) {
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Error"
                                          message:error.localizedDescription
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                    [alert show];
                } else {
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }
    }];
    
}



- (IBAction)saveButton:(id)sender {

    if([self dataFieldsValid]) {
        [self dismissKeyboard];
        [self changeUsersPassword];
    }
}

@end
