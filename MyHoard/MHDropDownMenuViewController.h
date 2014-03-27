//
//  MHDropDownMenuViewController.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 18/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDropDownMenu.h"

@interface MHDropDownMenuViewController : UIViewController

@property (nonatomic, strong) UIImage* menuButtonImage;
@property (nonatomic, strong) UIImage* selectedMenuButtonImage;
@property (nonatomic, assign) BOOL menuButtonVisible;

@property (nonatomic, readonly) MHDropDownMenu* menu;

@end
