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
        _emailTextField.textColor = [UIColor darkerYellow];
        
        _passwordTextField.backgroundColor = [UIColor lighterGray];
        _passwordTextField.textColor = [UIColor darkerYellow];
        
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
        _emailTextField.textColor = [UIColor darkerYellow];
        
        _passwordTextField.backgroundColor = [UIColor lighterGray];
        _passwordTextField.textColor = [UIColor darkerYellow];
        
        _passwordTextField1.backgroundColor = [UIColor lighterGray];
        _passwordTextField1.textColor = [UIColor darkerYellow];
        
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([identifier isEqualToString:@"collectionSegue"]) {
        if (_flowType == MHRegisterFlow) {
            
            if (![_passwordTextField.text isEqualToString:[NSString stringWithFormat:@"%@", _passwordTextField1.text]]) {
        
                UIAlertView *alert = [[UIAlertView alloc]
                                         initWithTitle:@"Alert"
                                         message:@"Passwords do not match"
                                         delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
            
                [alert show];
            
                return NO;
            
            }else if ([_passwordTextField1.text length] < 5) {
            
                UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Alert"
                                  message:@"Password must be at least 5 characters long"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            
                [alert show];
            
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
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
