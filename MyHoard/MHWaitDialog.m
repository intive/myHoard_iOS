//
//  MHWaitDialog.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 04/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHWaitDialog.h"

@interface MHWaitDialog()

@property UILabel *message;
@property UIActivityIndicatorView *indicator;

@end

@implementation MHWaitDialog

- (void)commonInit {
    [self setAlpha:0];
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
    [self setAlpha:0.5];
    self.hidden = false;
    
    _message = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width / 4, (self.bounds.size.width / 4) + 50, 100, 50)];
    _message.textColor = [UIColor collectionNameFrontColor];
    _message.text = text;
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _indicator.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    [_indicator startAnimating];
    
    [self addSubview:_indicator];
    [self addSubview:_message];
}

- (void)dismiss {
    [self setAlpha:0];
    self.hidden = true;
    [_message removeFromSuperview];
    [_indicator removeFromSuperview];
    
}

@end
