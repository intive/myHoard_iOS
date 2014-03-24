//
//  MHLoginAndRegisterViewController.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 22/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHBaseViewController.h"
#import "MHPasswordStrengthView.h"

typedef enum  {
	MHRegisterFlow = 1,
	MHLoginFlow,
} MHFlowType;

@interface MHLoginAndRegisterViewController : MHBaseViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordStrengthLabel1;
@property (weak, nonatomic) IBOutlet MHPasswordStrengthView *passwordStrengthView;
@property (assign, nonatomic) MHFlowType flowType;

@end
