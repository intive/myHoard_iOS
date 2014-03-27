//
//  MHBadgeView.h
//  MyHoard
//
//  Created by user on 23/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MHBadgeView : UIView

@property (nonatomic, strong) NSNumber *badgeValue;
@property (nonatomic, strong) UIColor *badgeBackgroundColor;
@property (nonatomic, strong) UIColor *badgeTextColor;

@property (nonatomic, readwrite) CGFloat badgeCorner;
@property (nonatomic, readwrite) CGFloat badgeScale;

@end
