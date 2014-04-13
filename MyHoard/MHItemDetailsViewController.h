//
//  MHItemDetailsViewController.h
//  MyHoard
//
//  Created by Kacper Tłusty on 13.04.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHBaseViewController.h"
#import "MHDragUpView.h"
#import "MHItem.h"
#import "MHMedia.h"

@interface MHItemDetailsViewController : MHBaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *frontImage;
@property (strong, nonatomic) IBOutlet MHDragUpView *bottomView;
@property (nonatomic, strong) MHItem *item;
@property (weak, nonatomic) IBOutlet UINavigationItem *itemTitle;

@end
