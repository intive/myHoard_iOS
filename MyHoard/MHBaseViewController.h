//
//  MHBaseViewController.h
//  MyHoard
//
//  Created by Grzegorz Pawłowicz on 12.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDropDownMenuViewController.h"

@interface MHBaseViewController : MHDropDownMenuViewController

@property (nonatomic, readwrite) BOOL enableMHLogo;
@property (nonatomic, readwrite) BOOL hideNavigationBar;

@end
