//
//  MHDragUpView.m
//  MyHoard
//
//  Created by Kacper Tłusty on 13.04.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHDragUpView.h"

@implementation MHDragUpView

- (void)commonInit
{
    self.backgroundColor = [UIColor collectionThumbnailOutlineColor];
    self.alpha = 0.3;
    _title = [[UILabel alloc] init];
    [_title setFrame:CGRectMake(10, 15, 300, 25)];
    _title.textColor = [UIColor collectionNameFrontColor];
    [self addSubview:_title];
    _comment = [[UILabel alloc] init];
    [_comment setFrame:CGRectMake(10, 39, 30, 40)];
    _comment.textColor = [UIColor tagFrontColor];
    [self addSubview:_comment];
    
    _button = [[UIButton alloc] init];
    [_button setFrame:CGRectMake(0, 0, 320, 244)];
    [_button.imageView setImage:[UIImage imageNamed:@"up"]];
    [self addSubview:_button];
    self.userInteractionEnabled = YES;
    _visible = false;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self visible]) {
        [self show];
    } else {
        [self hide];
    }
}
- (void)show
{
    _visible = true;
    [UIView animateWithDuration:1.0 animations:^{
        self.frame = CGRectMake(0, 200, self.frame.size.width, self.frame.size.height);
    }];
    
}

- (void)hide
{
    _visible = false;
    [UIView animateWithDuration:1.0 animations:^{
        self.frame = CGRectMake(0, 350, self.frame.size.width, self.frame.size.height);
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
