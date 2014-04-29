//
//  MHAddItemViewController.h
//  
//
//  Created by Konrad Gnoinski on 11/03/14.
//
//

#import <UIKit/UIKit.h>
#import "MHBrowseCollectionViewController.h"
#import "MHLocalizationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "MHMedia.h"
#import "MHDatabaseManager.h"
#import "MHItem.h"
#import "MHCollection.h"

@interface MHAddItemViewController : MHBaseViewController <UITextViewDelegate, CollectionSelectorDelegate, LocationSelectorDelegate>

@property (nonatomic, strong) UIImage* selectedImage;

@property (nonatomic,strong) MHLocalizationViewController *VCL;
@property (nonatomic,strong) MHCollection* selectedCollection;
@property (nonatomic,strong) CLLocation* selectedLocation;
@property (nonatomic,strong) NSString *locationNameString;
@property (nonatomic, strong) MHItem *item;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *titleBackground;
@property (weak, nonatomic) IBOutlet UIView *collectionBackground;
@property (weak, nonatomic) IBOutlet UIView *localizationBackground;
@property (weak, nonatomic) IBOutlet UIView *comentaryBackground;
@property (weak, nonatomic) IBOutlet UILabel *collectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *localizationLabel;
@property (weak, nonatomic) IBOutlet UILabel *collectionNoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *localizationNoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *commentaryTextView;
@property (weak, nonatomic) IBOutlet UILabel *defaultLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shareSwitch;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet UIView *shareView;

- (IBAction)collectionButton:(id)sender;
- (IBAction)localizationButton:(id)sender;
- (IBAction)backButton:(id)sender;
- (IBAction)doneButton:(id)sender;
- (void)updateItem;


@end
