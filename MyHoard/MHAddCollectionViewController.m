//
//  MHAddCollectionViewController.m
//  MyHoard
//
//  Created by Konrad Gnoinski on 12/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHAddCollectionViewController.h"
#import "MHDatabaseManager.h"
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;

@interface MHAddCollectionViewController ()
@property (readwrite) CGFloat animatedDistance;
@end

@implementation MHAddCollectionViewController

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
    self.view.backgroundColor = [UIColor darkerGray];
    self.pickerHidingView.backgroundColor = [UIColor darkerGray];
    self.nameBackgroundView.backgroundColor = [UIColor appBackgroundColor];
    self.tagsBackgroundView.backgroundColor = [UIColor appBackgroundColor];
    self.pickerHidingView.backgroundColor = [UIColor appBackgroundColor];
    self.descriptionBackgroundView.backgroundColor = [UIColor appBackgroundColor];
    self.questionBackgroundView.backgroundColor = [UIColor appBackgroundColor];
    self.nameTextField.textColor=[UIColor darkerYellow];
    self.tagsTextField.textColor=[UIColor darkerYellow];
    self.descriptionTextField.textColor=[UIColor darkerYellow];
    self.typeLabel.textColor=[UIColor darkerYellow];
    self.typeTitleLAbel.textColor=[UIColor darkerYellow];
    [_pickerCancelColor setTitleColor:[UIColor darkerYellow] forState:UIControlStateNormal];
    [_pickerSaveColor setTitleColor:[UIColor darkerYellow] forState:UIControlStateNormal];
    self.disableMHHamburger = YES;
    
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(add:)];
    self.navigationController.navigationBar.topItem.rightBarButtonItems = @[save];

    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(cancel:)];
    self.navigationController.navigationBar.topItem.leftBarButtonItems = @[cancel];
    _items = [[NSArray alloc]initWithObjects:@"Public", @"Private", @"Offline", nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)typeButton:(id)sender {
    [self dismissKeyboard];
    if (self.pickerHidingView.alpha==1.0) {
        self.pickerHidingView.alpha=0.0;
    }else{
        self.pickerHidingView.alpha=1.0;
    }
}

- (IBAction)pickerCancel:(id)sender {
    self.pickerHidingView.alpha=1.0;
}

- (IBAction)pickerSave:(id)sender {
    self.pickerHidingView.alpha=1.0;
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)add:(id)sender {
    if ([self.nameTextField.text isEqualToString:@""] || [self.nameTextField.text isEqualToString:@"Name"]|| [self.descriptionTextField.text isEqualToString:@""] || [self.descriptionTextField.text isEqualToString:@"Description"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Some field is not filled properly" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else if([self.nameTextField.text length]<2){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Name is to short" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }
    else{
        [MHDatabaseManager insertCollectionWithObjId:[NSString stringWithFormat:@"%u",arc4random()%10000]//in futere we will get it from server propably
                                             objName:self.nameTextField.text
                                      objDescription:self.descriptionTextField.text
                                             objTags:[NSArray arrayWithObject:self.tagsTextField.text]
                                      objItemsNumber:nil
                                      objCreatedDate:[NSDate date]
                                     objModifiedDate:nil
                                            objOwner:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameTextField) {
        [textField resignFirstResponder];
        [self.tagsTextField becomeFirstResponder];
    }
    else if (textField == self.tagsTextField) {
        [textField resignFirstResponder];
        [self.descriptionTextField becomeFirstResponder];
    }
    else if (textField == self.descriptionTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)dismissKeyboard {
    [_nameTextField resignFirstResponder];
    [_tagsTextField resignFirstResponder];
    [_descriptionTextField resignFirstResponder];
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_items count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [_items objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    _typeLabel.text=_items[row];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = _items[row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor darkerYellow]}];
    
    return attString;
    
}

@end
