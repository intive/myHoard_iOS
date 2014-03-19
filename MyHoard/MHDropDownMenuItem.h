//
//  MHDropDownMenuItem.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 19/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHDropDownMenuItem : UIButton

@property (nonatomic, assign) CGFloat position;
@property (nonatomic, readonly) CGRect itemFrame;
@property (nonatomic, readonly) CGRect hiddenFrame;

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

@end
