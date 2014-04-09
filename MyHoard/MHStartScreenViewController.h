//
//  MHStartScreenViewController.h
//  MyHoard
//
//  Created by user on 22/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHBaseViewController.h"
#import "MHLoginAndRegisterViewController.h"
#import "MHRoundButton.h"
#import <UIViewController+AMSlideMenu.h>

@interface MHStartScreenViewController : MHBaseViewController

@property (weak, nonatomic) IBOutlet MHRoundButton *loginButton;
@property (weak, nonatomic) IBOutlet MHRoundButton *registerButton;
@property (weak, nonatomic) IBOutlet MHRoundButton *dontWantAnAccountButton;
@property (weak, nonatomic) IBOutlet UIImageView *startScreenMHLogo;

@end
