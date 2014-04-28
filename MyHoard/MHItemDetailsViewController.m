//
//  MHItemDetailsViewController.m
//  MyHoard
//
//  Created by Kacper Tłusty on 13.04.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHItemDetailsViewController.h"
#import "MHImageCache.h"

#define BOTTOM_VIEW_COLLAPSED_HEIGHT 90
#define METERS_PER_MILE 1609.344


@interface MHItemDetailsViewController () <UIGestureRecognizerDelegate>
{
    BOOL _bottomViewExpanded;
    BOOL _mapViewEnabled;
}

@end

@implementation MHItemDetailsViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    _mapViewEnabled = NO;
    
    _bottomViewExpanded = NO;
    _bottomView.backgroundColor = [UIColor clearColor];
    
    _alphaBackgroundView.backgroundColor = [UIColor collectionThumbnailOutlineColor];
    _alphaBackgroundView.alpha = 0.7f;
    
    _itemCommentLabel.text = _item.objDescription;
    _itemCommentLabel.textColor = [UIColor lightGrayColor];
    _itemCommentLabel.backgroundColor = [UIColor clearColor];
    _itemCommentLabel.editable = NO;
    _itemTitleLabel.text = _item.objName;
    _itemTitleLabel.textColor = [UIColor collectionNameFrontColor];
    _itemTitleLabel.backgroundColor = [UIColor clearColor];
    _itemTitleLabel.clipsToBounds = YES;
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
    bottomBorder.borderWidth = 0.75f;
    bottomBorder.frame = CGRectMake(0, 0, CGRectGetWidth(_borderView.frame)+2, CGRectGetHeight(_borderView.frame));
    
    CALayer *topBorder = [CALayer layer];
    topBorder.borderColor = [UIColor darkGrayColor].CGColor;
    topBorder.borderWidth = 0.75f;
    topBorder.frame = CGRectMake(0, 1, CGRectGetWidth(_borderView.frame)+2, CGRectGetHeight(_borderView.frame));
    
    
    [_borderView.layer addSublayer:topBorder];
    [_borderView.layer addSublayer:bottomBorder];
    
    _borderView.backgroundColor = [UIColor clearColor];
    _borderView.layer.borderColor = (__bridge CGColorRef)([UIColor grayColor]);
    _borderView.layer.borderWidth = 1.0f;
    for(MHMedia *media in _item.media) {
        _frontImage.image = [[MHImageCache sharedInstance] imageForKey:media.objKey];
        break; //just read first item
    }
    _itemTitle.title = _item.objName;
    _itemMapView.hidden = YES;
    if(_item.objLocation) {
        CLLocation *myLoc = _item.objLocation;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(myLoc.coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        [_itemMapView setRegion:viewRegion animated:YES];
    } // dodać else i zablokować button na szarym
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)expandBottomView {
    [UIView animateWithDuration:0.3 animations:^{
        [_bottomView setFrame:CGRectMake(_bottomView.frame.origin.x, self.view.frame.size.height - (self.view.frame.size.height * 0.75), _bottomView.frame.size.width, _bottomView.frame.size.height)];
        [_dragTopButton setImage:[UIImage imageNamed:@"down_g"] forState:UIControlStateNormal];
        _bottomViewExpanded = YES;
    }];
}

- (void)collapseBottomView {
    [UIView animateWithDuration:0.3 animations:^{
        [_bottomView setFrame:CGRectMake(_bottomView.frame.origin.x, self.view.frame.size.height - BOTTOM_VIEW_COLLAPSED_HEIGHT, _bottomView.frame.size.width, _bottomView.frame.size.height)];
        [_dragTopButton setImage:[UIImage imageNamed:@"up_g"] forState:UIControlStateNormal];
        _bottomViewExpanded = NO;
    }];
}

- (IBAction)expandBottomViewButtonPressed:(id)sender
{
    if (_bottomViewExpanded) {
        [self collapseBottomView];
    } else {
        [self expandBottomView];
    }
}

- (IBAction)panGesture:(UIPanGestureRecognizer *)gesture;
{
    UIView *piece = _bottomView;
    
    CGFloat top = self.view.frame.size.height - _bottomView.frame.size.height;
    CGFloat bottom = self.view.frame.size.height - BOTTOM_VIEW_COLLAPSED_HEIGHT;
    
    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:[piece superview]];
        [piece setCenter:CGPointMake([piece center].x, [piece center].y + translation.y)];
		if (piece.frame.origin.y < top) {
			[piece setFrame:CGRectMake(piece.frame.origin.x, top, piece.frame.size.width, piece.frame.size.height)];
		}
		if (piece.frame.origin.y > bottom) {
			[piece setFrame:CGRectMake(piece.frame.origin.x, bottom, piece.frame.size.width, piece.frame.size.height)];
		}
        [gesture setTranslation:CGPointZero inView:[piece superview]];
		
    } else if ([gesture state] == UIGestureRecognizerStateEnded) {
        CGFloat middle = (bottom - top) / 2.0;
		if (_bottomView.frame.origin.y > (top + middle)) {
			[self collapseBottomView];
		} else {
			[self expandBottomView];
		}
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

- (IBAction)switchLocationImageViews:(id)sender {
   
    if (!_itemMapView.hidden) {
        [_locationButton setImage:[UIImage imageNamed:@"pin_y"] forState:UIControlStateNormal];
        _itemMapView.hidden = YES;
        _frontImage.hidden = NO;
    } else {
        [_locationButton setImage:[UIImage imageNamed:@"pin"] forState:UIControlStateNormal];
        _itemMapView.hidden = NO;
        _frontImage.hidden = YES;
    }
    
}
@end
