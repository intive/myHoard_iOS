//
//  MHItemDetailsPageViewController.h
//  MyHoard
//
//  Created by Konrad Gnoinski on 08/05/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHItemDetailsViewController.h"
#import "MHItem.h"
#import "MHMedia.h"
#import "MHDatabaseManager.h"
#import "MHCollection.h"

@interface MHItemDetailsPageViewController : UIViewController<UIPageViewControllerDataSource,UIActionSheetDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray *pageImages;
@property (nonatomic, strong) MHItem *item;

@end
