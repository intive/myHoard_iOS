//
//  UIActionSheet+ButtonState.m
//  MyHoard
//
//  Created by Milena Gnoińska on 29.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "UIActionSheet+ButtonState.h"

@implementation UIActionSheet (ButtonState)

- (void)setButton:(NSInteger)buttonIndex toState:(BOOL)enabled {
    for (UIView* view in self.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            if (buttonIndex == 0) {
                if ([view respondsToSelector:@selector(setEnabled:)])
                {
                    UIButton* button = (UIButton*)view;
                    button.enabled = enabled;
                }
            }
            buttonIndex--;
        }
    }
}

@end
