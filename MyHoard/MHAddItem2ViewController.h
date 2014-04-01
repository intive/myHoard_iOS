//
//  MHAddItem2ViewController.h
//  
//
//  Created by Konrad Gnoinski on 11/03/14.
//
//

#import <UIKit/UIKit.h>
#import "MHBrowseCollectionViewController.h"

@interface MHAddItem2ViewController : MHBaseViewController <UITextViewDelegate,passCollectionName>

@property (nonatomic) NSMutableArray *capturedImages;// need to be set by previous controllers
@property (nonatomic) NSArray *mediaIds;// need to be set by previous controllers

@property (nonatomic,strong)NSString *collectionNameString;
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
- (IBAction)backButton:(id)sender;
- (IBAction)doneButton:(id)sender;



@end
