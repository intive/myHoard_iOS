//
//  MHLoginAndRegisterViewController.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 22/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHLoginAndRegisterViewController.h"
#import "MHPasswordStrengthView.h"
#import "MHAPI.h"
#import "MHWaitDialog.h"

@interface MHLoginAndRegisterViewController () <UITextFieldDelegate> {
    MHWaitDialog* _waitDialog;
}

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField1;
@property (weak, nonatomic) IBOutlet MHPasswordStrengthView *passwordStrength;
@property (weak, nonatomic) IBOutlet UILabel *passwordStrengthLabel;

- (IBAction)goButtonPressed:(id)sender;

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
    
    _waitDialog = [[MHWaitDialog alloc] init];

    _goButton.cornerRadius = _goButton.frame.size.width / 2.0;
    
    if (_flowType == MHLoginFlow) {
        
        self.disableMHHamburger = YES;
        self.navigationItem.title = @"Login";
        
        if (!_passwordStrength.hidden && !_passwordStrengthLabel1.hidden && !_passwordTextField1.hidden) {
            
            _passwordStrength.hidden = YES;
            _passwordStrengthLabel.hidden = YES;
            _passwordTextField1.hidden = YES;
            
        }
        
        _emailTextField.backgroundColor = [UIColor lighterGray];
        _emailTextField.textColor = [UIColor lightLoginAndRegistrationTextFieldTextColor];
        
        _passwordTextField.backgroundColor = [UIColor lighterGray];
        _passwordTextField.textColor = [UIColor lightLoginAndRegistrationTextFieldTextColor];
        
        _emailTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"E-mail" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
        _passwordTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
        
        _passwordTextField.secureTextEntry = YES;
        
        _emailTextField.delegate = self;
        _passwordTextField.delegate = self;
        
        [self.view removeConstraints:[self.view constraints]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_emailTextField attribute:NSLayoutAttributeTop multiplier:1.0 constant:-107]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_emailTextField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_passwordTextField attribute:NSLayoutAttributeTop multiplier:1.0 constant:-12]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_passwordTextField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_goButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:-40]];
        
    }else if (_flowType == MHRegisterFlow) {
        
        self.disableMHHamburger = YES;
        self.navigationItem.title = @"Register";
        
        _passwordStrength.numberOfSections = 4;
        _passwordStrength.startColor = [UIColor darkerYellow];
        _passwordStrength.endColor = [UIColor redColor];
        _passwordStrengthLabel.textColor = [UIColor navigationBarBackgroundColor];
        
        _emailTextField.backgroundColor = [UIColor lighterGray];
        _emailTextField.textColor = [UIColor lightLoginAndRegistrationTextFieldTextColor];
        
        _passwordTextField.backgroundColor = [UIColor lighterGray];
        _passwordTextField.textColor = [UIColor lightLoginAndRegistrationTextFieldTextColor];
        
        _passwordTextField1.backgroundColor = [UIColor lighterGray];
        _passwordTextField1.textColor = [UIColor lightLoginAndRegistrationTextFieldTextColor];
        
        _emailTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"E-mail" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
        _passwordTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
        _passwordTextField1.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Confirm password" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
        
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField1.secureTextEntry = YES;
        
        _emailTextField.delegate = self;
        _passwordTextField.delegate = self;
        _passwordTextField1.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHide:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
    }

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
    return YES;
}

-(void)dismissKeyboard {
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_passwordTextField1 resignFirstResponder];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
}

- (BOOL)dataFieldsValid {
    if (_flowType == MHRegisterFlow) {
        
        
        if (![_passwordTextField.text length] && ![_passwordTextField1.text length] && ![_emailTextField.text length]) {
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Alert"
                                  message:@"To register You must provide all of the specified information"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            
            [alert show];
            
            return NO;
            
        }
        
        if (![_passwordTextField.text isEqualToString:[NSString stringWithFormat:@"%@", _passwordTextField1.text]]) {
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Alert"
                                  message:@"Passwords do not match"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            
            [alert show];
            
            return NO;
            
        }
        
        if ([_passwordTextField1.text length] < 5) {
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Alert"
                                  message:@"Password must be at least 5 characters long"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            
            [alert show];
            
            return NO;
        }
        
        if ([_emailTextField.text length] > 0) {
            
            NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
            NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
            
            if ([emailTest evaluateWithObject:_emailTextField.text] == NO) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Enter valid e-mail address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
                return NO;
            }
            
        }else {
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Alert"
                                  message:@"E-mail field is empty"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            
            [alert show];
            
            return NO;
        }
    }else if (_flowType == MHLoginFlow) {
        
        if (![_passwordTextField.text length] && ![_emailTextField.text length]) {
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Alert"
                                  message:@"To log in You must provide all of the specified information"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            
            [alert show];
            
            return NO;
            
        }
        
        if ([_emailTextField.text length] > 0) {
            
            NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
            NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
            
            if ([emailTest evaluateWithObject:_emailTextField.text] == NO) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Enter valid e-mail address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
                return NO;
            }
            
        }else {
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Alert"
                                  message:@"E-mail field is empty"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            
            [alert show];
            
            return NO;
        }
        
        if ([_passwordTextField.text length] == 0) {
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Alert"
                                  message:@"Password field is empty"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            
            [alert show];
            
            return NO;
        }
    }
    return YES;
}

- (void)login {
    [[MHAPI getInstance] accessTokenForUser:_emailTextField.text
                               withPassword:_passwordTextField.text
                            completionBlock:^(id object, NSError *error) {
                                [_waitDialog dismiss];
                                if (error) {
#warning - show error
                                } else {
                                    [self performSegueWithIdentifier:@"collectionSegue" sender:self];
                                }
                            }];
}

- (IBAction)goButtonPressed:(id)sender {
    if( [self dataFieldsValid]) {
        
        [self dismissKeyboard];
        [_waitDialog show];
        
        if (_flowType == MHLoginFlow) {
            [self login];
        } else { //register and then login
            [[MHAPI getInstance] createUser:_emailTextField.text withPassword:_passwordTextField.text completionBlock:^(id object, NSError *error) {
                if (error) {
                    [_waitDialog dismiss];
#warning show error!
                } else {
                    [self login];
                }
            }];
        }
    }
}
@end
