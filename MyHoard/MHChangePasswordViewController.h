//
//  MHChangePasswordViewController.h
//  MyHoard
//
//  Created by user on 05/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHBaseViewController.h"
#import "MHPasswordStrengthView.h"
#import "MHAPI.h"
#import "MHUserProfile.h"

@interface MHChangePasswordViewController : MHBaseViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *changePasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmNewPasswordTextField;


@property (weak, nonatomic) IBOutlet UIView *labelBackgroundViewOne;
@property (weak, nonatomic) IBOutlet UIView *labelBackgroundViewTwo;
@property (weak, nonatomic) IBOutlet UIView *labelBackgroundViewThree;

@property (weak, nonatomic) IBOutlet UILabel *passwordStrengthLabel;

@end
