//
//  MHLocalizationViewController.h
//  MyHoard
//
//  Created by Konrad Gnoinski on 04/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationSelectorDelegate <NSObject>

- (void)selectedLocationName:(NSString *)name;
- (void)selectedLocationCoordinate:(CLLocationCoordinate2D)coordinate;

@end

@interface MHLocalizationViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak) id <LocationSelectorDelegate> delegate;
@property (nonatomic, strong) NSArray *localizations;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *localizationText;
@property (weak, nonatomic) IBOutlet UIButton *cancelButtonColor;
@property (weak, nonatomic) IBOutlet UIView *lineSeparatingTableView;

- (IBAction)cancelButton:(id)sender;

@end
