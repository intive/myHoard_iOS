//
//  MHAddItemViewController.m
//  
//
//  Created by Konrad Gnoinski on 11/03/14.
//
//

#import "MHAddItemViewController.h"
#import "MHDatabaseManager.h"
#import "MHAPI.h"
#import "MHWaitDialog.h"
#import "MHImageCache.h"
#import "MHCoreDataContext.h"
#import "MHImagePickerViewController.h"
#import "UIActionSheet+ButtonState.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.01;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 220;

@interface MHAddItemViewController ()
@property (readwrite) CGFloat animatedDistance;
@property (readwrite) int objectToRemove;
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
    self.addAnotherPhotoView.backgroundColor = [UIColor appBackgroundColor];
    self.titleBackground.backgroundColor = [UIColor appBackgroundColor];
    self.comentaryBackground.backgroundColor = [UIColor appBackgroundColor];
    self.shareView.backgroundColor = [UIColor appBackgroundColor];
    self.localizationBackground.backgroundColor = [UIColor appBackgroundColor];
    self.collectionBackground.backgroundColor = [UIColor appBackgroundColor];
    self.collectionLabel.textColor = [UIColor collectionNameFrontColor];
    self.localizationLabel.textColor = [UIColor collectionNameFrontColor];
    self.collectionNoneLabel.textColor = [UIColor darkerYellow];
    self.localizationNoneLabel.textColor = [UIColor darkerYellow];
    self.titleTextField.textColor = [UIColor lighterYellow];
    self.shareLabel.textColor = [UIColor lighterYellow];
    [_addAnotherPhotoColor setTitleColor:[UIColor darkerYellow] forState:UIControlStateNormal];
    [_addAnotherPhotoColor setTitleColor:[UIColor lighterYellow] forState:UIControlStateSelected];
    self.collectionView.backgroundColor = [UIColor darkerGray];
    _titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
    _defaultLabel.textColor = [UIColor darkerYellow];
    _commentaryTextView.backgroundColor = [UIColor clearColor];
    _commentaryTextView.textColor = [UIColor lighterYellow];
    _viewHidingCollectionView.backgroundColor=[UIColor darkerGray];
    [_shareSwitch setOn:0];
    _array = [[NSMutableArray alloc] init];
    if(self.selectedImage){
        _singleImageView.image=_selectedImage;
        [_array addObject: self.selectedImage];
    }else{
        _singleImageView.image=[UIImage imageNamed:@"camera_y@2x"];
        _singleImageView.contentMode = UIViewContentModeCenter;
    }
    if (self.selectedLocation) {

        CLGeocoder *geo = [[CLGeocoder alloc] init];
        [geo reverseGeocodeLocation: self.selectedLocation completionHandler:
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
    }
    if (_item) {
    for(MHMedia *media in _item.media) {
        [_array addObject:[[MHImageCache sharedInstance] imageForKey:media.objKey]];
    }
        self.title = @"Edit item";
        _selectedCollection = _item.collection;
        _titleTextField.text = _item.objName;
        _commentaryTextView.text = _item.objDescription;
        _collectionButton.enabled = NO;
        self.defaultLabel.hidden = ([_commentaryTextView.text length] > 0);
    }
}

- (void)viewWillAppear:(BOOL)animated{
    if ([_array count]<2) {
        _viewHidingCollectionView.alpha=1.0;
    }else{
        _viewHidingCollectionView.alpha=0.0;
    }
    if ([_array count]==1) {
        _addAnotherPhotoView.alpha=1.0;
        _singleImageView.contentMode = UIViewContentModeScaleAspectFit;
        _singleImageView.image=[_array objectAtIndex:0];
    }else{
        _addAnotherPhotoView.alpha=0.0;
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


- (IBAction)AddAnotherPhoto:(id)sender {
    _objectToRemove=0;
    [self showAddMenu:sender];
}

- (IBAction)buttonOnTopOfImageView:(id)sender {
    _objectToRemove=1;
    [self showAddMenu:sender];
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
    NSString *trimmedString = [self.titleTextField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    
    BOOL duplicate = NO;
    NSArray *objects = [MHDatabaseManager allItemsWithObjName:trimmedString inCollection:self.selectedCollection];
    if ([objects count]) duplicate = YES;
    
    if([result length]<2){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Title is to short(spaces, tabs are not included in counting)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else if([self.titleTextField.text length]>64){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Title is to long(max64)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else if (duplicate == YES && _item == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Item of that title exists." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else if(self.selectedCollection==nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Collection is not set properly" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else
    {
        if (_item != nil) {
            [self updateItem:_item withName:trimmedString];
            [self dismissViewControllerAnimated:YES completion:nil];
            
#warning send update to the server!
            
        } else {
            if (_shareSwitch.isOn)
            {
                NSMutableString *text = [[NSMutableString alloc] initWithString: @"I've just added"];
                [text appendFormat:@" %@ to my collection of %@!",_titleTextField.text, _collectionNoneLabel.text];
                NSArray *activityItems = [NSArray alloc];
                if([_array firstObject])
                {
                    activityItems =  @[text,[_array firstObject]];
                } else
                {
                    activityItems =  @[text];
                }
                UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                controller.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                                     UIActivityTypeMail,
                                                     UIActivityTypePrint,
                                                     UIActivityTypeCopyToPasteboard,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypeSaveToCameraRoll,
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypePostToFlickr,
                                                     UIActivityTypePostToVimeo,
                                                     UIActivityTypePostToTencentWeibo,
                                                     UIActivityTypeAirDrop];
                [[self parentViewController] presentViewController:controller animated:YES completion:nil];
                __weak typeof(self) weakself = self;
                [controller setCompletionHandler:^(NSString *activityType, BOOL completed)
                 {
                     if(completed)
                     {
                         [weakself addMediaAndItemToDatabase];
                     }
                 }];
            }
            
            [self addMediaAndItemToDatabase];
        }
    }
}

- (void) addMediaAndItemToDatabase{
    NSString *trimmedString = [self.titleTextField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    MHItem* item = [MHDatabaseManager insertItemWithObjName:trimmedString
                                             objDescription:self.commentaryTextView.text
                                                    objTags:nil
                                                objLocation:self.selectedLocation
                                             objCreatedDate:[NSDate date]
                                            objModifiedDate:nil
                                                 collection:self.selectedCollection
                                                  objStatus:objectStatusNew];
    
    if ([_array firstObject]){
        for (int i=0; i<[_array count]; i++)
        {
            NSString *key = [[MHImageCache sharedInstance] cacheImage:[_array objectAtIndex:i]];
            MHMedia* media = [MHDatabaseManager insertMediaWithCreatedDate:[NSDate date]
                                                                    objKey:key
                                                                      item:item
                                                                 objStatus:objectStatusNew];
            
            if ([[MHAPI getInstance]activeSession] == YES)
            {
                if (![self.selectedCollection.objType isEqualToString:collectionTypeOffline])
                {
                    __block MHWaitDialog* wait = [[MHWaitDialog alloc] init];
                    [wait show];
                    [[MHAPI getInstance]createMedia:media completionBlock:^(id object, NSError *error)
                    {
                        [wait dismiss];
                        if (error)
                        {
                            UIAlertView *alert = [[UIAlertView alloc]
                                                  initWithTitle:@"Error"
                                                  message:error.localizedDescription
                                                  delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
                            [alert show];
                        }else
                        {
                            [[MHAPI getInstance]createItem:item completionBlock:^(id object, NSError *error)
                            {
                                if (error)
                                {
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
                    }];
                }
            }
        }
    } else
    {
        if ([[MHAPI getInstance]activeSession] == YES)
        {
            if (![self.selectedCollection.objType isEqualToString:collectionTypeOffline])
            {
                __block MHWaitDialog* wait = [[MHWaitDialog alloc] init];
                [wait show];
                [[MHAPI getInstance] createItem:item completionBlock:^(id object, NSError *error)
                 {
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
                 }];
            }
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateItem:(MHItem *)item withName:(NSString *)name {
    item.objName = name;
    item.objDescription = _commentaryTextView.text;
    item.collection.objModifiedDate = [NSDate date];
    item.objLocation = self.selectedLocation;
}


#pragma mark CollectionSelectorDelegate
- (void)collectionSelected:(MHCollection *)collection {
    _selectedCollection = collection;
}

#pragma mark LocationSelectorDelegate
- (void)selectedLocationName:(NSString *)name {
    _locationNameString = name;
}

- (void)selectedLocationCoordinate:(CLLocation*)location {
    _selectedLocation = location;
}


- (void)textViewDidChange:(UITextView *)txtView
{
    if ([_commentaryTextView.text isEqualToString:@"\n"]){
        [self.commentaryTextView setText:@""];
    }
    self.defaultLabel.hidden = ([txtView.text length] > 0);
}

#pragma mark Collection View
-(NSInteger )numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [_array count]+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UIView* subview;
    while ((subview = [[cell subviews] lastObject]) != nil)
        [subview removeFromSuperview];
    if(indexPath.row==[_array count]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, 100, 100)];
        [button setImage:[UIImage imageNamed:@"camera_y"] forState:UIControlStateNormal];
        [button addTarget:self
              action:@selector(showAddMenu:)
        forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
        cell.backgroundColor=[UIColor blackColor];
    }else{
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        [cell addSubview:img];
        img.image=[_array objectAtIndex:indexPath.row];
    }
    return cell;
}

-(void)showAddMenu:(id)sender {
    UIActionSheet *alert = [[UIActionSheet alloc]initWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"Take a photo", @"Choose from library", nil];
    [alert showInView:self.view];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [alert setButton:0 toState:NO];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row!=[_array count]) {
        _objectToRemove=indexPath.row;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Do you want to remove this object?"
                                                      delegate:self
                                             cancelButtonTitle:@"cancel"
                                             otherButtonTitles:@"ok", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [_array removeObjectAtIndex:_objectToRemove];
        if ([_array count]<2) {
            _viewHidingCollectionView.alpha=1.0;
        }else{
            _viewHidingCollectionView.alpha=0.0;
        }
        if ([_array count]==1) {
            _addAnotherPhotoView.alpha=1.0;
            _singleImageView.contentMode = UIViewContentModeScaleAspectFit;
            _singleImageView.image=[_array objectAtIndex:0];
        }else{
            _addAnotherPhotoView.alpha=0.0;
        }
        
        [self.collectionView reloadData];
    }
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    MHImagePickerViewController *imagePickerController = [[MHImagePickerViewController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.completionBlock = ^(NSDictionary *info) {
        if ([_array count]==1 && _objectToRemove==1) {
            [_array removeObjectAtIndex:0];
        }
        [_array insertObject:info[kMHImagePickerInfoImage] atIndex:[_array count]];
        [self.collectionView reloadData];
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.view.bounds.size.height<500) {
                if ([_array count]>5) {
                    CGPoint bottomOffset = CGPointMake(0, self.collectionView.contentSize.height - self.collectionView.bounds.size.height);
                    [self.collectionView setContentOffset:bottomOffset animated:YES];
                }
            }else{
                if ([_array count]>8) {
                    CGPoint bottomOffset = CGPointMake(0, self.collectionView.contentSize.height - self.collectionView.bounds.size.height);
                    [self.collectionView setContentOffset:bottomOffset animated:YES];
                }
            }
        }];
    };
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

-(void)actionSheet:(UIActionSheet *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex){
        case 0:
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
        case 1:
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
    }
}

@end
