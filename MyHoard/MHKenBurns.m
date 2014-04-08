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
    
    _images = [NSMutableArray array];
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

- (void)removeAllImages {
    [_images removeAllObjects];
}

- (void)addImage:(UIImage *)image {

    if (image)
    {
        [_images addObject:image];
        [self stopAnimation];
        [self startAnimation];
    }
}

- (void)animationTapperOff {
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]initWithTarget:_kenBurnsView action:@selector(stopAnimation)];
    tapper.numberOfTapsRequired = 1;
    [_kenBurnsView addGestureRecognizer:tapper];
    [_kenBurnsView setUserInteractionEnabled:YES];

}

- (void)animationTapperOn {
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]initWithTarget:_kenBurnsView action:@selector(startAnimation)];
    tapper.numberOfTapsRequired = 2;
    [_kenBurnsView addGestureRecognizer:tapper];
    [_kenBurnsView setUserInteractionEnabled:YES];
    
}

- (void)stopAnimation {
    if (_images.count) {
        [_kenBurnsView animateWithImages:@[_images[0]] transitionDuration:_animationDuration loop:NO isLandscape:NO];
    }
}

- (void)reloadAfterDelay:(NSTimeInterval)delay {
    _delay = delay;
    
    [self stopAnimation];
    [self startAnimation];
}

- (void)startAnimation {
    
    [_kenBurnsView animateWithImages:_images
                  transitionDuration:_animationDuration
                                loop:_shouldLoop
                         isLandscape:_isLandscape];

}

@end
