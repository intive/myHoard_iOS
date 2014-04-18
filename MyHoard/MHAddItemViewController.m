//
//  MHAddItemViewController.m
//  
//
//  Created by Konrad Gnoinski on 11/03/14.
//
//

#import "MHAddItemViewController.h"
#import "MHDatabaseManager.h"
#import "UIImage+Gallery.h"
#import "MHAPI.h"
#import "MHWaitDialog.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.01;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 200;

@interface MHAddItemViewController ()
@property (readwrite) CGFloat animatedDistance;
@end

@implementation MHAddItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(backButton:)];
    self.navigationItem.leftBarButtonItem = closeButton;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"check"] style:UIBarButtonItemStylePlain target:self action:@selector(doneButton:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.view.backgroundColor = [UIColor darkerGray];
    self.titleBackground.backgroundColor = [UIColor appBackgroundColor];
    self.comentaryBackground.backgroundColor = [UIColor appBackgroundColor];
    self.localizationBackground.backgroundColor = [UIColor appBackgroundColor];
    self.collectionBackground.backgroundColor = [UIColor appBackgroundColor];
    self.collectionLabel.textColor = [UIColor collectionNameFrontColor];
    self.localizationLabel.textColor = [UIColor collectionNameFrontColor];
    self.collectionNoneLabel.textColor = [UIColor darkerYellow];
    self.localizationNoneLabel.textColor = [UIColor darkerYellow];
    self.titleTextField.textColor = [UIColor lighterYellow];
    _titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
    _defaultLabel.textColor = [UIColor darkerYellow];
    _commentaryTextView.backgroundColor = [UIColor clearColor];
    _commentaryTextView.textColor = [UIColor lighterYellow];
    if (self.mediaId){
        [UIImage imageForAssetPath:self.mediaId completion:^(UIImage *image, CLLocationCoordinate2D coordinate) {
            self.imageView.image = image;
            _locationCoordinatePassed=coordinate;
            CLGeocoder *geo = [[CLGeocoder alloc]init];
            CLLocation *loc = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            [geo reverseGeocodeLocation: loc completionHandler:
             ^(NSArray *placemarks, NSError *error) {
                 if (placemarks.count && !error){
                 CLPlacemark *placemark = [placemarks objectAtIndex:0];
                 NSMutableString *tmp = [[NSMutableString alloc]init];
                 if (placemark.thoroughfare != nil){
                     [tmp appendFormat:@"%@",placemark.thoroughfare];
                 }
                 if (placemark.thoroughfare != nil && placemark.locality != nil){
                     [tmp appendFormat:@", "];
                 }
                 if (placemark.locality != nil){
                     [tmp appendFormat:@"%@", placemark.locality];
                 }
                 _locationNameString=tmp;
                 if (tmp.length) {
                     self.localizationNoneLabel.text=_locationNameString;
                 }
                 }else{
                     NSLog(@"error when geting name from location located in photo");
                 }
             }];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.titleTextField) {
        [textField resignFirstResponder];
        [self.commentaryTextView becomeFirstResponder];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        self.defaultLabel.hidden = ([_commentaryTextView.text length] > 0);
        return NO;
    }
    return YES;
}



-(void)dismissKeyboard {
    [_titleTextField resignFirstResponder];
    [_commentaryTextView resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    _animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= _animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += _animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGRect textFieldRect =
    [self.view.window convertRect:textView.bounds fromView:textView];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    _animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= _animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.defaultLabel.hidden = ([textView.text length] > 0);
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += _animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- ( void ) viewDidAppear:(BOOL)animated{
    if (_selectedCollection != NULL) {
        self.collectionNoneLabel.text = _selectedCollection.objName;
    }
    if (_locationNameString != NULL) {
        self.localizationNoneLabel.text=_locationNameString;
    }
}


- (IBAction)collectionButton:(id)sender {
    [self dismissKeyboard];
    MHBrowseCollectionViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"browse"];
    VC.delegate = self;
    VC.selectedCollection = _selectedCollection;
    [[self navigationController] pushViewController:VC animated:YES];
}

- (IBAction)localizationButton:(id)sender {
    [self dismissKeyboard];
    if (_VCL==NULL) {
    _VCL = [self.storyboard instantiateViewControllerWithIdentifier:@"location"];
    _VCL.delegate = self;
    }
    [[self navigationController] pushViewController:_VCL animated:YES];
}


- (IBAction)backButton:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButton:(id)sender {
    NSString *result = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    BOOL duplicate = NO;
    NSArray *objects = [MHDatabaseManager allItemsWithObjName:self.titleTextField.text inCollection:self.selectedCollection];
    if ([objects count]) duplicate = YES;
    
    if([result length]<2){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Title is to short(spaces, tabs are not included in counting)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else if([self.titleTextField.text length]>64){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Title is to long(max64)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else if (duplicate == YES){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Item of that title exists." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            [alert show];
    }else if(self.selectedCollection==nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Collection is not set properly" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }
    else{

        CLLocation* loc = [[CLLocation alloc] initWithLatitude:_locationCoordinatePassed.latitude longitude:_locationCoordinatePassed.longitude];
        MHItem* item = [MHDatabaseManager insertItemWithObjName:self.titleTextField.text
                                                 objDescription:self.commentaryTextView.text
                                                        objTags:nil
                                                    objLocation:loc
                                                 objCreatedDate:[NSDate date]
                                                objModifiedDate:nil
                                                     collection:self.selectedCollection];
        if (self.mediaId) {
            MHMedia *media = [MHDatabaseManager insertMediaWithCreatedDate:[NSDate date]
                                             objLocalPath:self.mediaId
                                                     item:item];
            
            if ([[MHAPI getInstance]activeSession] == YES) {
                [[MHAPI getInstance]createMedia:media completionBlock:^(id object, NSError *error) {
                    if (error) {
                        UIAlertView *alert = [[UIAlertView alloc]
                                              initWithTitle:@"Error"
                                              message:error.localizedDescription
                                              delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
                        [alert show];
                    }
                }];
            }
        }
        
        if ([[MHAPI getInstance]activeSession] == YES) {
            __block MHWaitDialog* wait = [[MHWaitDialog alloc] init];
            [wait show];
            [[MHAPI getInstance] createItem:item completionBlock:^(id object, NSError *error) {
                [wait dismiss];
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Error"
                                          message:error.localizedDescription
                                          delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
                    [alert show];
                }
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }else {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark CollectionSelectorDelegate
- (void)collectionSelected:(MHCollection *)collection {
    _selectedCollection = collection;
}

#pragma mark LocationSelectorDelegate
- (void)selectedLocationName:(NSString *)name {
    _locationNameString = name;
}

- (void)selectedLocationCoordinate:(CLLocationCoordinate2D)coordinate {
    _locationCoordinatePassed = coordinate;
}


- (void)textViewDidChange:(UITextView *)txtView
{
    if ([_commentaryTextView.text isEqualToString:@"\n"]){
        [self.commentaryTextView setText:@""];
    }
    self.defaultLabel.hidden = ([txtView.text length] > 0);
}

@end
