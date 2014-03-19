//
//  MHDropDownMenuItem.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 19/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHDropDownMenuItem.h"

@interface MHDropDownMenuItem()
{
    UIColor* _backColor;
    UIColor* _highlightColor;
}
@end

@implementation MHDropDownMenuItem

- (CGRect)itemFrame {
    CGRect r = self.frame;
    r.origin.y = _position;
    return r;
}

- (CGRect)hiddenFrame {
    CGRect r = self.frame;
    r.origin.y = -r.size.height;
    return r;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.backgroundColor = _highlightColor;
    } else {
        self.backgroundColor = _backColor;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        _backColor = backgroundColor;
        self.backgroundColor = backgroundColor;
    } else if (state == UIControlStateHighlighted) {
        _highlightColor = backgroundColor;
    } else {
        _backColor = backgroundColor;
    }
}

@end
