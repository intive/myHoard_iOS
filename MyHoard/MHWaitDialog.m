//
//  MHWaitDialog.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 04/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHWaitDialog.h"

@interface MHWaitDialog()

@property (nonatomic, strong) UIView* backgroundView;
@property (nonatomic, strong) UILabel *message;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation MHWaitDialog

- (void)commonInit {
    _backgroundView = [[UIView alloc] init];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
    [self addSubview:_backgroundView];

    _message = [[UILabel alloc] initWithFrame:CGRectZero];
    _message.textColor = [UIColor collectionNameFrontColor];
    [self addSubview:_message];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:_indicator];

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
    [self showWithText:@"Please wait..."];
}

- (void)showWithText:(NSString *)text {

    _message.text = text;
    [_indicator startAnimating];

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

    _indicator.center = self.center;
    _message.frame = CGRectMake(0, 0, self.bounds.size.width, 21);
    [_message sizeToFit];
    _message.center = CGPointMake(self.center.x, self.center.y + _indicator.frame.size.height + 8);

}

@end
