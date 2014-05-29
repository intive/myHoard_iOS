//
//  MHItemDetailsViewController.m
//  MyHoard
//
//  Created by Kacper Tłusty on 13.04.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHItemDetailsViewController.h"
#import "MHImageCache.h"
#import "MHAddItemViewController.h"
#import "MHCoreDataContext.h"

#define BOTTOM_VIEW_COLLAPSED_HEIGHT 95
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
    _array = [[NSMutableArray alloc] init];
    
    for(MHMedia *media in _item.media) {
        [_array addObject:[[MHImageCache sharedInstance] imageForKey:media.objKey]];
    }
    
    _mapViewEnabled = NO;
    
    _bottomViewExpanded = NO;
    _bottomView.backgroundColor = [UIColor clearColor];
    
    _alphaBackgroundView.backgroundColor = [UIColor collectionThumbnailOutlineColor];
    _alphaBackgroundView.alpha = 0.7f;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStylePlain target:self action:@selector(doneButton:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    _itemCommentLabel.text = _item.objDescription;
    _itemCommentLabel.textColor = [UIColor lightGrayColor];
    _itemCommentLabel.backgroundColor = [UIColor clearColor];
    _itemCommentLabel.editable = NO;
    _itemTitleLabel.text = _item.objName;
    _itemTitleLabel.textColor = [UIColor collectionNameFrontColor];
    _itemTitleLabel.backgroundColor = [UIColor clearColor];
    _itemTitleLabel.clipsToBounds = YES;
    
    
    
    _borderView.backgroundColor = [UIColor clearColor];
    _borderView.layer.borderColor = (__bridge CGColorRef)([UIColor grayColor]);
    _borderView.layer.borderWidth = 1.0f;
    _itemTitle.title = _item.objName;
    _itemMapView.hidden = YES;
    if(_item.objLocation) {
        CLLocation *myLoc = _item.objLocation;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(myLoc.coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        [_itemMapView setRegion:viewRegion animated:YES];
        
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:myLoc.coordinate];
        [_itemMapView addAnnotation:annotation];
    } else {
        _locationButton.hidden = YES;
    }
    [self setupScrollView];
}


- (void)viewWillAppear:(BOOL)animated
{
    _itemTitleLabel.text = _item.objName;
    _itemTitle.title = _item.objName;
    _itemCommentLabel.text = _item.objDescription;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupScrollView {
    _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControlBeingUsed = NO;
    self.view.backgroundColor=[UIColor blackColor];
    for (int i = 0; i < _array.count; i++) {
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:frame];
        image.image = [_array objectAtIndex:i];
        image.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:image];
    }
    
    if(_array.count<2){
        _pageControl.alpha=0.0;
    }else {
        _pageControl.numberOfPages =_array.count;
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * _array.count, 1);
    
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
        _locationButton.selected = NO;
        _scrollView.hidden = NO;
        _itemMapView.hidden = YES;
    } else {
        _locationButton.selected = YES;
        _itemMapView.hidden = NO;
        _scrollView.hidden = YES;
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (IBAction)changePage {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

#pragma mark - edit item menu methods

- (IBAction)doneButton:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:@"Delete item"
                                                   otherButtonTitles:@"Edit item", nil];
    [actionSheet showInView:self.view];
    
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                   message:@"Do you want to delete the item?"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK", nil];
    
    switch (buttonIndex) {
        case 0:
            [alert show];
            break;
        case 1:
            [self performSegueWithIdentifier:@"ChangeItemSettingsSegue" sender:_item];
            break;
        default:
            break;
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ChangeItemSettingsSegue"]) {
        UINavigationController *nc = segue.destinationViewController;
        MHItemDetailsViewController *vc = (MHItemDetailsViewController *)nc.visibleViewController;
        vc.item = _item;
    }
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex{
    __block MHWaitDialog *waitDialog = [[MHWaitDialog alloc]init];
    switch (buttonIndex) {
        case 1:
            [waitDialog show];
            if ([[MHAPI getInstance]userId]&&([self.item.collection.objType isEqualToString:collectionTypePrivate] || [self.item.collection.objType isEqualToString:collectionTypePublic]) && ![_item.objStatus isEqualToString:objectStatusNew]){
                MHCollection *acollection = self.item.collection;
                self.item.collection = nil;
                self.item.objStatus = @"deleted";
                NSArray *itemMedia = [self.item.media allObjects];
                for (int i=0; i<[itemMedia count]; i++){
                    MHMedia *media = [itemMedia objectAtIndex:i];
                    [[MHImageCache sharedInstance] removeDataForKey:media.objKey];
                    [[MHCoreDataContext getInstance].managedObjectContext deleteObject:media];
                }
                [[MHCoreDataContext getInstance].managedObjectContext deleteObject:self.item];
                [[MHAPI getInstance] deleteItemWithId: self.item completionBlock:^(id object, NSError *error){
                    if (error){
                        [waitDialog dismiss];
                        UIAlertView *err = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:error.localizedDescription
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
                        [err show];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    else
                    {
                        for (int i=0; i<[itemMedia count]; i++){
                            MHMedia *media = [itemMedia objectAtIndex:i];
                            [[MHAPI getInstance]deleteMedia:media completionBlock:^(id object, NSError *error){
                                if (error){
                                    [waitDialog dismiss];
                                    UIAlertView *err = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:error.localizedDescription
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil];
                                    [err show];
                                    [self.navigationController popViewControllerAnimated:YES];
                                }
                                else
                                    [waitDialog dismiss];
                            }];
                        }
                        
                        [[MHAPI getInstance]updateCollection:acollection completionBlock:^(id object, NSError *error){
                            if (error){
                                [waitDialog dismiss];
                                UIAlertView *err = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                              message:error.localizedDescription
                                                                             delegate:nil
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil];
                                [err show];
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                            else
                                [waitDialog dismiss];
                        }];
                        [waitDialog dismiss];
                        [self.navigationController popViewControllerAnimated:YES];
                    };
                    
                }];
                
            }
            else
            {
                self.item.collection = nil;
                NSArray *itemMedia = [self.item.media allObjects];
                for (int i=0; i<[itemMedia count]; i++){
                    MHMedia *media = [itemMedia objectAtIndex:i];
                    [[MHImageCache sharedInstance] removeDataForKey:media.objKey];
                    [[MHCoreDataContext getInstance].managedObjectContext deleteObject:media];
                }
                [[MHCoreDataContext getInstance].managedObjectContext deleteObject:self.item];
                [waitDialog dismiss];
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
            
    }
}

@end
