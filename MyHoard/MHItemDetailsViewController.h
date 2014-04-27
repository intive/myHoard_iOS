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
#import <MapKit/MapKit.h>

@interface MHItemDetailsViewController : MHBaseViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *frontImage;
@property (weak, nonatomic) IBOutlet UINavigationItem *itemTitle;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *dragTopButton;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *itemCommentLabel;
@property (weak, nonatomic) IBOutlet UIView *alphaBackgroundView;
@property (weak, nonatomic) IBOutlet MKMapView *itemMapView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;


- (IBAction)switchLocationImageViews:(id)sender;

@property (nonatomic, strong) MHItem *item;

@end
