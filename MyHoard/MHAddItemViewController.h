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

@interface MHAddItemViewController : MHBaseViewController <UITextViewDelegate, CollectionSelectorDelegate, LocationSelectorDelegate>

@property (nonatomic) NSMutableArray *capturedImagesURL;// need to be set by previous controllers
@property (nonatomic, readwrite) NSString *mediaId;

@property (nonatomic,strong) MHLocalizationViewController *VCL;
@property (nonatomic,strong) MHCollection* selectedCollection;
@property (nonatomic,strong) NSString *locationNameString;
@property (nonatomic) CLLocationCoordinate2D locationCoordinatePassed;
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

- (IBAction)collectionButton:(id)sender;
- (IBAction)localizationButton:(id)sender;
- (IBAction)backButton:(id)sender;
- (IBAction)doneButton:(id)sender;



@end
