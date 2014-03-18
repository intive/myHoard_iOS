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

@property (nonatomic, strong) CBAutoScrollLabel *aslabelone;
@property (nonatomic, strong) CBAutoScrollLabel *aslabeltwo;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval delay;
@property (nonatomic, strong) NSArray *tagList;
@property (nonatomic) NSUInteger indexLabelOne;
@property (nonatomic) NSUInteger indexLabelTwo;

- (void)animateLabels;
- (void)crossFade;
- (void)updateText:(NSArray *)tagList;
- (void)checkLabelIndexing;

@end
