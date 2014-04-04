//
//  MHWaitDialog.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 04/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHWaitDialog.h"

@implementation MHWaitDialog

- (void)commonInit {
#warning - implement
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
#warning - implement
}

- (void)dismiss {
#warning - implement
}

@end
