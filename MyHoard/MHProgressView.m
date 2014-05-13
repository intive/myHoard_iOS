//
//  MHProgressView.m
//  MyHoard
//
//  Created by user on 13/05/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHProgressView.h"

@interface MHProgressView()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation MHProgressView

- (void)commonInit {
    
    _backgroundView = [[UIView alloc] init];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
    [self addSubview:_backgroundView];
    
    _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.progress = 0.5;
    [self addSubview:_progressView];
    
    self.hidden = YES;
    self.alpha = 0.0;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)show {
    
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    
    [window addSubview:self];
    self.frame = window.bounds;
    
    self.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.alpha = 1.0;
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if(finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)layoutSubviews
{
    _backgroundView.frame = self.bounds;    
    _progressView.center = self.center;
    
}



@end
