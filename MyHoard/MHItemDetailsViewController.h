//
//  MHItemDetailsViewController.h
//  MyHoard
//
//  Created by Kacper Tłusty on 13.04.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHBaseViewController.h"
#import "MHItem.h"
#import "MHMedia.h"

@interface MHItemDetailsViewController : MHBaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *frontImage;
@property (nonatomic, strong) MHItem *item;
@property (weak, nonatomic) IBOutlet UINavigationItem *itemTitle;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *dragTopButton;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemCommentLabel;


- (IBAction)showOrHide:(id)sender;
- (IBAction)swipeToTop:(id)sender;
- (IBAction)swipeToBottom:(id)sender;

@end
