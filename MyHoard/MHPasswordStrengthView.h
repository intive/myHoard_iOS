//
//  MHPasswordStrengthView.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 22/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHPasswordStrengthView : UIView

@property (nonatomic, assign) NSInteger numberOfSections;
@property (nonatomic, strong) UIColor* startColor;
@property (nonatomic, strong) UIColor* endColor;
@property (nonatomic, strong) UIColor* startBackgroundColor;
@property (nonatomic, strong) UIColor* endBackgroundColor;

- (void)setPassword:(NSString *)password;

@end
