//
//  MHSliderMenuHeader.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 11/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHSliderMenuHeader.h"

@implementation MHSliderMenuHeader

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect r = self.titleLabel.frame;
    self.titleLabel.frame = CGRectMake(r.origin.x, r.origin.y + 20, r.size.width, r.size.height - 20);
}

@end
