//
//  MHLoginAndRegisterViewController.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 22/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHBaseViewController.h"
#import "MHPasswordStrengthView.h"
#import "MHRoundButton.h"

typedef enum  {
	MHRegisterFlow = 1,
	MHLoginFlow,
} MHFlowType;

typedef void(^LoginCompletionBlock)();

@interface MHLoginAndRegisterViewController : MHBaseViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordStrengthLabel1;
@property (weak, nonatomic) IBOutlet MHPasswordStrengthView *passwordStrengthView;
@property (assign, nonatomic) MHFlowType flowType;
@property (weak, nonatomic) IBOutlet MHRoundButton *goButton;

@property (nonatomic, copy) LoginCompletionBlock loginCompletionBlock;

@end
