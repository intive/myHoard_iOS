//
//  MHKenBurns.m
//  MyHoard
//
//  Created by user on 18/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHKenBurns.h"

#define kAnimationDuration 12.0

@implementation MHKenBurns
{
    UIImageView* _imageView;
    
    NSMutableArray *_images;
}

+ (CGFloat)animationDuration {
    return kAnimationDuration;
}

- (void)baseInit {
    
    _kenBurnsView = [[JBKenBurnsView alloc]init];
    _kenBurnsView.frame = self.bounds;
    [self addSubview:_kenBurnsView];

    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
    

    [self setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
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
    [self stopAnimation];
}

- (void)addImage:(UIImage *)image {

    if (image) {
        if (_images.count == 0) {
            _imageView.image = image;
            _imageView.hidden = NO;
            _kenBurnsView.hidden = YES;
        }
        [_images addObject:image];
    }
}

- (void)stopAnimation {
    [_kenBurnsView.layer removeAllAnimations];
    [_kenBurnsView stopAnimation];
    _imageView.hidden = NO;
    _kenBurnsView.hidden = YES;

    if (_images.count) {
        _imageView.image = _images[0];
    }
}

- (void)startAnimation {
    
    if (_images.count > 1) {
        _imageView.hidden = YES;
        _kenBurnsView.hidden = NO;
        
        [_kenBurnsView animateWithImages:_images
                      transitionDuration:kAnimationDuration / (CGFloat)_images.count
                                    loop:NO
                             isLandscape:YES];
    }
}

@end
