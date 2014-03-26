//
//  MHStartScreenViewController.h
//  MyHoard
//
//  Created by user on 22/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHBaseViewController.h"
#import "MHLoginAndRegisterViewController.h"

@interface MHStartScreenViewController : MHBaseViewController


@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *dontWantAnAccountButton;
@property (weak, nonatomic) IBOutlet UIImageView *startScreenMHLogo;

@end
