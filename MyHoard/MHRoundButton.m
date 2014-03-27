//
//  MHRoundButton.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 27/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHRoundButton.h"

@implementation MHRoundButton {
    UIColor* _highlightedColor;
}

- (void)commonInit {
    self.buttonColor = [UIColor lightButtonColor];
    self.textColor = [UIColor lightButtonTitleColor];
    self.cornerRadius = 6.0;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor = _highlightedColor;
    } else {
        self.backgroundColor = _buttonColor;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

- (void)setButtonColor:(UIColor *)buttonColor {
    _buttonColor = buttonColor;
    _highlightedColor = [buttonColor colorWithAlphaComponent:0.8];
    self.backgroundColor = buttonColor;
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor {
    [self setTitleColor:textColor forState:UIControlStateNormal];
    [self setTitleColor:[textColor colorWithAlphaComponent:0.8] forState:UIControlStateHighlighted];

}

@end
