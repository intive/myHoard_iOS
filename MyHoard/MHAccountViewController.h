//
//  MHAccountViewController.h
//  MyHoard
//
//  Created by user on 04/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHBaseViewController.h"
#import "UIColor+customColors.h"
#import "MHBadgeView.h"
#import "MHDatabaseManager.h"
#import "MHCollection.h"

@interface MHAccountViewController : MHBaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *collectionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *photosLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineOne;
@property (weak, nonatomic) IBOutlet UILabel *lineTwo;
@property (weak, nonatomic) IBOutlet UIImageView *friendImageView;


@property (weak, nonatomic) IBOutlet MHBadgeView *numberOfCollections;
@property (weak, nonatomic) IBOutlet MHBadgeView *numberOfPhotos;

@end
