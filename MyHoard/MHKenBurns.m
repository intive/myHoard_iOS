//
//  MHKenBurns.m
//  MyHoard
//
//  Created by user on 18/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHKenBurns.h"

@implementation MHKenBurns

- (void)baseInit {
    
    _kenBurnsView = [[JBKenBurnsView alloc]init];
    _kenBurnsView.frame = self.bounds;

    [self addSubview:_kenBurnsView];

    [self setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    _images = [[NSMutableArray alloc]init];
    
    _animationDuration = 12;
    _delay = 3;
    _shouldLoop = YES;
    _isLandscape = YES;
    
#pragma predefined image array for testing
    
    _images = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"camera.png"],
                                                [UIImage imageNamed:@"logo.png"],
                                                [UIImage imageNamed:@"camera.png"], nil];
    
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        [self baseInit];
    }
    return self;
}

- (void)beginAnimationWithImages:(NSMutableArray *)imagesArray withDuration:(NSTimeInterval)duration shouldLoop:(BOOL)loop isLandscape:(BOOL)isLandscape {
    
    
    [_kenBurnsView animateWithImages:_images transitionDuration:_animationDuration loop:_shouldLoop isLandscape:_isLandscape];
    [self animationTapperOff];
    [self animationTapperOn];

}

- (void)addImage:(UIImage *)image {
    
    [_images addObject:image];
}

- (void)animationTapperOff {
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]initWithTarget:_kenBurnsView action:@selector(stopMHKenBurns)];
    tapper.numberOfTapsRequired = 1;
    [_kenBurnsView addGestureRecognizer:tapper];
    [_kenBurnsView setUserInteractionEnabled:YES];

}

- (void)animationTapperOn {
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]initWithTarget:_kenBurnsView action:@selector(animateWithImageSelectorWrapper)];
    tapper.numberOfTapsRequired = 2;
    [_kenBurnsView addGestureRecognizer:tapper];
    [_kenBurnsView setUserInteractionEnabled:YES];
    
}

- (void)stopMHKenBurns {
    
    [_kenBurnsView performSelector:@selector(stopKenBurns) withObject:nil];
}

- (void)reloadAfterDelay:(NSTimeInterval)delay {
    
    _delay = delay;
    
    [self performSelector:@selector(animateWithImageSelectorWrapper) withObject:nil afterDelay:_delay];
}

- (void)animateWithImageSelectorWrapper {
    
    [_kenBurnsView animateWithImages:_images transitionDuration:_animationDuration loop:_shouldLoop isLandscape:_isLandscape];

}

@end
