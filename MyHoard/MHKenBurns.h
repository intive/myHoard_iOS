//
//  MHKenBurns.h
//  MyHoard
//
//  Created by user on 18/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBKenBurnsView.h"

@interface MHKenBurns : UIView

@property (nonatomic, strong) JBKenBurnsView *kenBurnsView;

+ (CGFloat)animationDuration;

- (void)addImage:(UIImage *)image;
- (void)stopAnimation;
- (void)startAnimation;
- (void)removeAllImages;

@end
