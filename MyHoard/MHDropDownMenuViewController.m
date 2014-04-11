//
//  MHDropDownMenuViewController.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 18/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHDropDownMenuViewController.h"
#import "MHDropDownMenu.h"

@interface MHDropDownMenuViewController ()
{
    UIBarButtonItem* _menuButton;
}

@end

@implementation MHDropDownMenuViewController

- (void)commonInit {
    _menu = [[MHDropDownMenu alloc] init];
    _menuButton = [[UIBarButtonItem alloc] initWithImage:_menuButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(dropDownMenuButtonClicked:)];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)dropDownMenuButtonClicked:(id)sender {
    if (_menu.isVisible) {
        [_menu hideMenuAnimated:YES];
        _menuButton.image = _menuButtonImage;
    } else {
        if (_selectedMenuButtonImage) {
            _menuButton.image = _selectedMenuButtonImage;
        }
        [_menu showMenuInView:self.view atPosition:0 animated:YES];
    }
}

- (void)changeRightBarButtons {
    NSMutableArray* items = [self.navigationItem.rightBarButtonItems mutableCopy];
    
    if (!items) {
        items = [NSMutableArray array];
    }
    
    [items removeObject:_menuButton];
    if (_menuButtonVisible) {
        [items addObject:_menuButton];
    }
    self.navigationItem.rightBarButtonItems = items;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self changeRightBarButtons];
}

- (void)setMenuButtonImage:(UIImage *)menuButtonImage {
    _menuButtonImage = menuButtonImage;
    _menuButton.image = menuButtonImage;
}

- (void)setMenuButtonVisible:(BOOL)menuButtonVisible {
    _menuButtonVisible = menuButtonVisible;

    [self changeRightBarButtons];
}

@end
