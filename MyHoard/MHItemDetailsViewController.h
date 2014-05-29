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
#import <UIKit/UIKit.h>
#import "MHWaitDialog.h"
#import "MHAPI.h"
#import "MHDatabaseManager.h"
#import "MHCollection.h"

@interface MHItemDetailsViewController : MHBaseViewController <MKMapViewDelegate, UITextViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UIScrollViewDelegate>{
	BOOL pageControlBeingUsed;
}

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *arrayOfImages;
@property (nonatomic, strong) UIImage *img;
@property (weak, nonatomic) IBOutlet UINavigationItem *itemTitle;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *dragTopButton;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *itemCommentLabel;
@property (weak, nonatomic) IBOutlet UIView *alphaBackgroundView;
@property (weak, nonatomic) IBOutlet MKMapView *itemMapView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIView *borderView;
@property NSUInteger pageIndex;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;


- (IBAction)changePage;
- (IBAction)switchLocationImageViews:(id)sender;

@property (nonatomic, strong) MHItem *item;

@end
