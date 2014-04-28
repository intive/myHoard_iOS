//
//  MHLocalizationViewController.h
//  MyHoard
//
//  Created by Konrad Gnoinski on 04/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MJPlacesFinder.h"

@protocol LocationSelectorDelegate <NSObject>

- (void)selectedLocationName:(NSString *)name;
- (void)selectedLocationCoordinate:(CLLocation*)location;

@end

@interface MHLocalizationViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,MJPlacesFinderDelegate>{
}

@property (weak) id <LocationSelectorDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *localizations;
@property (nonatomic, strong) NSArray *places;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *localizationText;
@property (weak, nonatomic) IBOutlet UIButton *cancelButtonColor;
@property (weak, nonatomic) IBOutlet UIView *lineSeparatingTableView;
@property(nonatomic, strong) MJPlacesFinder *placesfinder;

- (IBAction)cancelButton:(id)sender;

@end
