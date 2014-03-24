//
//  MHTagsView.h
//  MyHoard
//
//  Created by user on 11/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CBAutoScrollLabel.h>

@interface MHTagsView : UIView

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval delay;
@property (nonatomic, strong) NSArray *tagList;

- (void)startAnimating;
- (void)stopAnimating;

@end
