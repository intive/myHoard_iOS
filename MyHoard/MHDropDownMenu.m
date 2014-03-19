//
//  MHDropDownMenu.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 18/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHDropDownMenu.h"
#import "MHDropDownMenuItem.h"

#define MENU_SHOW_ANIMATION_DURATION 0.8
#define MENU_HIDE_ANIMATION_DURATION 0.8
#define MENU_ITEM_ANIMATION_DURATION 0.5
#define MENU_ITEM_ANIMATION_DELAY 0.08
#define MENU_BORDER 2

@interface MHDropDownMenu()
{
    BOOL _visible;
    UIView* _backgroundView;
    NSMutableArray* _items;
}

@end

@implementation MHDropDownMenu

- (void)commonInit {
    _visible = NO;
    _backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    [self addSubview:_backgroundView];
    _items = [NSMutableArray array];
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)menuItemSelected:(MHDropDownMenuItem *)sender {
    NSInteger index = sender.tag;
    if ([_delegate respondsToSelector:@selector(dropDownMenu:didSelectItemAtIndex:)]) {
        [_delegate dropDownMenu:self didSelectItemAtIndex:index];
    }
    [self hideMenuAnimated:YES];
}

- (void)buildMenuForWidth:(CGFloat)width atPosition:(CGFloat)y {
    NSInteger numberOfItems = [_dataSource numberOfItemsInDropDownMenu:self];

    if (_items.count == numberOfItems) {
        return;
    }
    
    for (MHDropDownMenuItem *item in _items) {
        [item removeFromSuperview];
    }
    [_items removeAllObjects];
    
    y += MENU_BORDER;
    for (NSInteger i = 0; i < numberOfItems; i++) {
        CGFloat height = 44;
        
        if ([_dataSource respondsToSelector:@selector(heightOfItemInDropDownMenu:atIndex:)]) {
            height = [_dataSource heightOfItemInDropDownMenu:self atIndex:i];
        }
        
        CGSize s = CGSizeMake(width, height);
        
        UIView* view = nil;
        if ([_dataSource respondsToSelector:@selector(viewInDropDownMenu:atIndex:withSize:)]) {
            view = [_dataSource viewInDropDownMenu:self atIndex:i withSize:s];
        }
        
        MHDropDownMenuItem* item = [[MHDropDownMenuItem alloc] init];
        item.frame = CGRectMake(MENU_BORDER, -height, width, height);
        [item addTarget:self action:@selector(menuItemSelected:) forControlEvents:UIControlEventTouchUpInside];
        item.tag = i;
        item.position = y;
        
        if (!view) {
            NSString* title = nil;
            if ([_dataSource respondsToSelector:@selector(titleInDropDownMenu:atIndex:)]) {
                title = [_dataSource titleInDropDownMenu:self atIndex:i];
            }

            UIImage* image = nil;
            if ([_dataSource respondsToSelector:@selector(imageInDropDownMenu:atIndex:)]) {
                image = [_dataSource imageInDropDownMenu:self atIndex:i];
            }
            
            UIColor* textColor = [UIColor blackColor];
            if ([_dataSource respondsToSelector:@selector(textColorInDropDownMenu:atIndex:)]) {
                textColor = [_dataSource textColorInDropDownMenu:self atIndex:i];
            }
            
            UIColor* backgroundColor = [UIColor whiteColor];
            if ([_dataSource respondsToSelector:@selector(backgroundColorInDropDownMenu:atIndex:)]) {
                backgroundColor = [_dataSource backgroundColorInDropDownMenu:self atIndex:i];
            }

            [item setTitle:title forState:UIControlStateNormal];
            [item setImage:image forState:UIControlStateNormal];
            [item setBackgroundColor:backgroundColor forState:UIControlStateNormal];
            [item setBackgroundColor:[backgroundColor colorWithAlphaComponent:0.45] forState:UIControlStateHighlighted];
            [item setTitleColor:textColor forState:UIControlStateNormal];
            
        } else {
            view.frame = CGRectMake(0, 0, width, height);
            [item addSubview:view];
        }
        
        y += (MENU_BORDER + height);
        
        [self addSubview:item];
        [_items addObject:item];
    }
}

- (void)hideMenuAnimated:(BOOL)animated {
    BOOL shouldHide = YES;
    if ([_delegate respondsToSelector:@selector(shouldHideDropDownMenu:)]) {
        shouldHide = [_delegate shouldHideDropDownMenu:self];
    }

    if (shouldHide) {
        if (animated) {

            for(NSInteger i=0;i<_items.count;i++) {
                MHDropDownMenuItem* item = _items[i];

                CGRect frame = item.hiddenFrame;
                
                [UIView animateWithDuration:MENU_ITEM_ANIMATION_DURATION
                                      delay:i * MENU_ITEM_ANIMATION_DELAY
                     usingSpringWithDamping:1.0
                      initialSpringVelocity:4.0
                                    options: UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     item.frame = frame;
                                 }
                                 completion:^(BOOL finished){
                                 }];
                [UIView commitAnimations];
                
            }

            
            [UIView animateWithDuration:MENU_HIDE_ANIMATION_DURATION
                             animations:^{
                                 _backgroundView.alpha = 0.0;
            }
                             completion:^(BOOL finished) {
                                 [self removeFromSuperview];
                                 _visible = NO;
            }];
        } else {
            for (MHDropDownMenuItem* item in _items) {
                item.frame = item.hiddenFrame;
            }
            
            [self removeFromSuperview];
            _visible = NO;
        }
    }
}

- (void)showMenuInView:(UIView *)view atPosition:(CGFloat)y animated:(BOOL)animated {

    BOOL shouldShow = YES;
    if ([_delegate respondsToSelector:@selector(shouldShowDropDownMenu:)]) {
        shouldShow = [_delegate shouldShowDropDownMenu:self];
    }
    
    if (shouldShow) {

        [self buildMenuForWidth:view.frame.size.width - (MENU_BORDER * 2) atPosition:y];
        
        self.frame = view.bounds;
        _backgroundView.frame = view.bounds;
        _backgroundView.alpha = 0.0;
        [view addSubview:self];

        y += MENU_BORDER;
        for(NSInteger i=_items.count-1;i >= 0;i--) {
            MHDropDownMenuItem* item = _items[i];
            
            CGRect frame = item.itemFrame;

            [UIView animateWithDuration:MENU_ITEM_ANIMATION_DURATION
                                  delay:(_items.count - i + 1) * MENU_ITEM_ANIMATION_DELAY
                 usingSpringWithDamping:1.0
                  initialSpringVelocity:4.0
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 item.frame = frame;
                             }
                             completion:^(BOOL finished){
                             }];
            [UIView commitAnimations];

        }
        
        if (animated) {
            [UIView animateWithDuration:MENU_HIDE_ANIMATION_DURATION
                             animations:^{
                                 _backgroundView.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                                 _visible = YES;
                             }];
        } else {
            for (MHDropDownMenuItem* item in _items) {
                item.frame = item.itemFrame;
            }
            
            _visible = YES;
        }
    }
}

- (BOOL)isVisible {
    return _visible;
}

@end
