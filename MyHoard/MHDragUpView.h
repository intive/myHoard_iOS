//
//  MHDragUpView.h
//  MyHoard
//
//  Created by Kacper Tłusty on 13.04.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+customColors.h"

@interface MHDragUpView : UIView

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *comment;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic) BOOL visible;

- (void)show;
- (void)hide;

@end
