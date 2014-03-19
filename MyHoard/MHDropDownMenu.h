//
//  MHDropDownMenu.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 18/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MHDropDownMenu;

@protocol MHDropDownMenuDataSource <NSObject>

@required
/**
 Return number of items in given menu.
 */
- (NSInteger)numberOfItemsInDropDownMenu:(MHDropDownMenu *)menu;

@optional

/**
 Return height of item in given menu at given row. Default is 44.
 */
- (CGFloat)heightOfItemInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index;

/**
 Return title for menu item at given index. Might return nil, if there should be no text.
 Ignored if viewInDropDownMenu is implemented;
 */
- (NSString *)titleInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index;

/**
 Return image for menu item at given index. Might return nil, if there should be no image.
 Ignored if viewInDropDownMenu is implemented;
 */
- (UIImage *)imageInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index;

/**
 Return color for title for menu item at given index. default is black.
 Ignored if viewInDropDownMenu is implemented;
 */
- (UIColor *)textColorInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index;

/**
 Return background color for menu item at given index. default is white.
 Ignored if viewInDropDownMenu is implemented;
 */
- (UIColor *)backgroundColorInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index;

/**
 Return view of given size representing menu item at given index. If not implemented menu will ask for
 title and image.
 */
- (UIView *)viewInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index withSize:(CGSize)size;


@end

@protocol MHDropDownMenuDelegate <NSObject>

@optional
/**
 Return YES if the menu should be shown. Default YES.
 */
- (BOOL)shouldShowDropDownMenu:(MHDropDownMenu *)menu;

/**
 Return YES if the menu should be hidden. Default YES.
 */
- (BOOL)shouldHideDropDownMenu:(MHDropDownMenu *)menu;

/**
 Called when menu item was selected. Menu item is indicated by index.
 Menu will automatically hide after this method is called if shouldHideDropDownMenu
 is not implemented or returns YES
 */
- (void)dropDownMenu:(MHDropDownMenu*)menu didSelectItemAtIndex:(NSUInteger)index;

@end

@interface MHDropDownMenu : UIView

- (void)showMenuInView:(UIView *)view atPosition:(CGFloat)y animated:(BOOL)animated;
- (void)hideMenuAnimated:(BOOL)animated;

@property (nonatomic, weak) id<MHDropDownMenuDataSource> dataSource;
@property (nonatomic, weak) id<MHDropDownMenuDelegate> delegate;
@property (nonatomic, readonly, getter = isVisible) BOOL visible;

@end

