//
//  MHTagsView.m
//  MyHoard
//
//  Created by user on 11/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHTagsView.h"

@implementation MHTagsView {
    NSInteger _tagIndex;
    NSTimer* _timer;
    NSInteger _currentLabel;
    
    NSArray* _labels;
}

- (CBAutoScrollLabel *)addAutoscrollLabelWithAlpha:(CGFloat)alpha {
    CBAutoScrollLabel* a = [[CBAutoScrollLabel alloc] initWithFrame:self.bounds];

    a.textColor = [UIColor lightGrayColor];
    a.labelSpacing = self.frame.size.width;
    a.pauseInterval = 2.0f;
    a.scrollSpeed = 30.0f;
    a.textAlignment = NSTextAlignmentLeft;
    a.fadeLength = 10.0f;
    a.scrollDirection = CBAutoScrollDirectionLeft;
    a.font = [UIFont systemFontOfSize:12];
    a.alpha = alpha;

    [self addSubview:a];
    return a;
}

- (void)baseInit {
    
    CBAutoScrollLabel* l1 = [self addAutoscrollLabelWithAlpha:1.0];
    CBAutoScrollLabel* l2 = [self addAutoscrollLabelWithAlpha:0.0];
    
    _labels = @[l1, l2];
    _currentLabel = 0;
    
    _tagIndex = 0;
    
    _duration = 2.0;
    _delay = 1.0;
    
    self.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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

- (void)setTag:(NSString *)tag inLabel:(CBAutoScrollLabel *)label {
    label.text = [NSString stringWithFormat:@"%@", tag];
}

- (void)setTagList:(NSArray *)tagList {
    _tagList = tagList;
    _tagIndex = 0;
    if (tagList.count == 1) {
        [self setTag:tagList[0] inLabel:[self currentLabel]];
    } else if (tagList.count > 1) {
        [self setLabelsTexts];
        [self startAnimating];
    }
}

- (CBAutoScrollLabel*)currentLabel {
    return _labels[_currentLabel];
}

- (CBAutoScrollLabel*)nextLabel {
    return _labels[_currentLabel ^ 1];
}

- (void)setLabelsTexts {
    [self setTag:_tagList[_tagIndex] inLabel:[self currentLabel]];
    _tagIndex++;
    if (_tagIndex == _tagList.count) {
        _tagIndex = 0;
    }
    [self setTag:_tagList[_tagIndex] inLabel:[self nextLabel]];
}

- (void)startAnimating {
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:_delay target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)timerFired {
    [self crossFade];
}

- (void)crossFade {
    [UIView animateWithDuration:_duration animations:^{
        [self currentLabel].alpha = 0.0;
        [self nextLabel].alpha = 1.0;
    } completion:^(BOOL finished) {
        if (finished) {
            _currentLabel ^= 1;
            [self setLabelsTexts];
            [self startAnimating];
        }
    }];
}

- (void)stopAnimating {
    [self stopTimer];
    [self.layer removeAllAnimations];
}

@end
