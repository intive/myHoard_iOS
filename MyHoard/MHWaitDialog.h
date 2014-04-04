//
//  MHWaitDialog.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 04/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHWaitDialog : UIView

- (void)show;
- (void)showWithText:(NSString *)text;
- (void)dismiss;

@end
