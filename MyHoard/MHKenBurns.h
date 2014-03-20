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
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic) CGFloat animationDuration;
@property (nonatomic) BOOL shouldLoop;
@property (nonatomic) BOOL isLandscape;
@property (nonatomic) NSTimeInterval delay;

- (void)beginAnimationWithImages:(NSMutableArray *)imagesArray withDuration:(NSTimeInterval)duration shouldLoop:(BOOL)loop isLandscape:(BOOL)isLandscape;
- (void)setImages:(NSMutableArray *)images;
- (void)addImage:(UIImage *)image;
- (void)animationTapperOff;
- (void)animationTapperOn;
- (void)reloadAfterDelay:(NSTimeInterval)delay;

@end