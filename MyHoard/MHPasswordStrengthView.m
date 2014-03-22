//
//  MHPasswordStrengthView.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 22/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHPasswordStrengthView.h"

@implementation MHPasswordStrengthView {
    NSInteger _currentValue;
}

- (void)commonInit {
    _numberOfSections = 4;
    _startColor = [UIColor yellowColor];
    _endColor = [UIColor redColor];
    _startBackgroundColor = [UIColor lightGrayColor];
    _endBackgroundColor = [UIColor blackColor];
    
    _currentValue = 0;
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 8.0;
    self.clipsToBounds = YES;

}

- (NSInteger)calculatePasswordStrength:(NSString *)password {
    if (!password) {
        return 0;
    }

    NSInteger score = 0;
    NSInteger maxScore = 100;

    NSRange range;
    
    if ([password length] < 5) {
        return 0;
    }else if ([password length] < 10) {
        score += 20;
    }else {
        score += 40;
    }
    
    range = [password rangeOfCharacterFromSet:[NSCharacterSet illegalCharacterSet]];
    
    if (range.length) {
        return 0;
    }
    
    range = [password rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (range.length) {
        return 0;
    }
    
    range = [password rangeOfCharacterFromSet:[NSCharacterSet symbolCharacterSet]];
    
    if (range.length) {
        return 0;
    }
    
    range = [password rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    
    if (!range.length) {
        score += 0;
    }else {
        score += 20;
    }
    
    range = [password rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    
    if (!range.length) {
        score += 0;
    }else {
        score += 20;
    }
    
    range = [password rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    if (!range.length) {
        score += 0;
    }else {
        score += 20;
    }
    
    
    if (score > maxScore) {
        score = maxScore;
    }
    
    return (score * _numberOfSections) / maxScore;
}

- (void)setPassword:(NSString *)password {
    _currentValue = [self calculatePasswordStrength:password];
    [self setNeedsDisplay];
}

- (void)setStartColor:(UIColor *)startColor {
    _startColor = startColor;
    [self setNeedsDisplay];
}

- (void)setEndColor:(UIColor *)endColor {
    _endColor = endColor;
    [self setNeedsDisplay];
}

- (void)setStartBackgroundColor:(UIColor *)startBackgroundColor {
    _startBackgroundColor = startBackgroundColor;
    [self setNeedsDisplay];
}

- (void)setEndBackgroundColor:(UIColor *)endBackgroundColor {
    _endBackgroundColor = endBackgroundColor;
    [self setNeedsDisplay];
}

- (void)setNumberOfSections:(NSInteger)numberOfSections {
    _numberOfSections = numberOfSections;
    
    [self setNeedsDisplay];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (UIColor*)color:(UIColor *)first mixedWithColor:(UIColor *)second atRatio:(CGFloat)ratio {

    const CGFloat *firstCC = CGColorGetComponents(first.CGColor);
    const CGFloat *secondCC = CGColorGetComponents(second.CGColor);
    
    NSInteger numCC = CGColorGetNumberOfComponents(first.CGColor);
    CGFloat newCC[numCC];
    for (NSUInteger i = 0; i < numCC; i++)
    {
        newCC[i] = (firstCC[i] * (1.0 - ratio)) + (secondCC[i] * ratio);
    }
    
    CGColorRef retRef = CGColorCreate(CGColorGetColorSpace(first.CGColor), newCC);
    UIColor *ret = [UIColor colorWithCGColor:retRef];
    CGColorRelease(retRef);
    return ret;
}

#define SPACE 2

- (void)drawRect:(CGRect)rect {
    NSInteger width = (self.frame.size.width - ((_numberOfSections-1) * SPACE)) / _numberOfSections;
    NSInteger diff = self.frame.size.width - ((width * _numberOfSections) + ((_numberOfSections - 1) * SPACE));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat step = 1.0f / (_numberOfSections - 1);
    CGFloat ratio = 0.0f;
    CGFloat x = 0.0f;
    for (int i=0;i<_currentValue;i++) {
        //draw selected sections

        if (i == (_numberOfSections - 1)) {
            width += diff;
        }
        
        CGRect r = CGRectMake(x, 0, width, rect.size.height);
        CGContextAddRect(context, r);
        UIColor *color = [self color:_startColor mixedWithColor:_endColor atRatio:ratio];
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, r);
        
        x += width + SPACE;
        ratio += step;
    }
    
    for (int i=_currentValue;i<_numberOfSections;i++) {
        //draw background sections
        
        if (i == (_numberOfSections - 1)) {
            width += diff;
        }

        CGRect r = CGRectMake(x, 0, width, rect.size.height);
        CGContextAddRect(context, r);
        UIColor *color = [self color:_startBackgroundColor mixedWithColor:_endBackgroundColor atRatio:ratio];
        CGContextSetFillColorWithColor(context,color.CGColor);
        CGContextFillRect(context, r);
        
        ratio += step;
        x += width + SPACE;

    }
    
}

@end
