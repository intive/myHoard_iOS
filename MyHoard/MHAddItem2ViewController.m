//
//  MHAddItem2ViewController.m
//  
//
//  Created by Konrad Gnoinski on 11/03/14.
//
//

#import "MHAddItem2ViewController.h"
#import "MHDatabaseManager.h"
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.01;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 200;

@interface MHAddItem2ViewController ()
@property (readwrite) CGFloat animatedDistance;
@end

@implementation MHAddItem2ViewController

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
    self.disableMHHamburger=YES;
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"XButton.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButton:)];
    self.navigationItem.leftBarButtonItem = closeButton;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"VButton.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doneButton:)];
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
    if([self.capturedImagesURL objectAtIndex:0]!=NULL){
        //[self.imageView setImage:[self.capturedImages objectAtIndex:0]];
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
    if (_collectionNameString != NULL) {
        self.collectionNoneLabel.text=_collectionNameString;
    }
    if (_locationNameString != NULL) {
        self.localizationNoneLabel.text=_locationNameString;
    }
}


- (IBAction)collectionButton:(id)sender {
    [self dismissKeyboard];
    MHBrowseCollectionViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"browse"];
    VC.delegate = self;
    [[self navigationController] pushViewController:VC animated:YES];
}

- (IBAction)localizationButton:(id)sender {
    [self dismissKeyboard];
    MHLocalizationViewController *VCL = [self.storyboard instantiateViewControllerWithIdentifier:@"local"];
    VCL.delegate = self;
    [[self navigationController] pushViewController:VCL animated:YES];
}


- (IBAction)backButton:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButton:(id)sender {
    NSString *result = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([result length]<2){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Title is to short(spaces, tabs are not included in counting)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else if([self.titleTextField.text length]>64){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Title is to long(max64)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else if([MHDatabaseManager itemWithObjId: self.titleTextField.text]!=nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Item of that title exists." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else if(self.collectionNameString==nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Collection is not set properly" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else if ([self.commentaryTextView.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Commentary must be filled" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }
    else{

    NSString *coolId = [MHDatabaseManager getCollectionWithObjName:self.collectionNameString].objId;
        NSDictionary *locationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [NSNumber numberWithFloat:_locationCoordinatePassed.latitude] , @"latitude",
                                                                  [NSNumber numberWithFloat:_locationCoordinatePassed.latitude], @"longitude", nil];
    [MHDatabaseManager insertItemWithObjId:[NSString stringWithFormat:@"%u",arc4random()%10000] objName:self.titleTextField.text objDescription:self.commentaryTextView.text objTags:nil objLocation:locationDictionary objQuantity:[NSNumber numberWithUnsignedInteger:[self.mediaIds count]] objMediaIds:self.mediaIds objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:coolId objOwner:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)setCollectionName:(NSString *)collectionName{
    _collectionNameString = collectionName;
}

-(void)setLocationName:(NSString *)locationName{
    _locationNameString = locationName;
}

-(void)setLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate{
    _locationCoordinatePassed = locationCoordinate;
}

- (void)textViewDidChange:(UITextView *)txtView
{
    if ([_commentaryTextView.text isEqualToString:@"\n"]){
        [self.commentaryTextView setText:@""];
    }
    self.defaultLabel.hidden = ([txtView.text length] > 0);
}

@end
