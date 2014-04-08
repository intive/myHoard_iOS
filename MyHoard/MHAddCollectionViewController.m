//
//  MHAddCollectionViewController.m
//  MyHoard
//
//  Created by Konrad Gnoinski on 12/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHAddCollectionViewController.h"
#import "MHDatabaseManager.h"

@interface MHAddCollectionViewController ()
@property (readwrite) NSUInteger last;
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
    self.descriptionBackgroundView.backgroundColor = [UIColor appBackgroundColor];
    self.questionBackgroundView.backgroundColor = [UIColor appBackgroundColor];
    self.nameTextField.textColor = [UIColor lighterYellow];
    self.descriptionTextField.textColor = [UIColor lighterYellow];
    self.tagsTextField.textColor = [UIColor lighterYellow];
    _nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
    _tagsTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Tags" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
    _descriptionTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Description" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
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
    _last=0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)typeButton:(id)sender {
    [self dismissKeyboard];
    if (self.pickerHidingView.alpha==1.0) {
        [UIView animateWithDuration:1.0 animations:^{
            self.pickerHidingView.alpha=0.0;
        }];
    }else{
        [UIView animateWithDuration:1.0 animations:^{
            self.pickerHidingView.alpha=1.0;
        }];
    }
}

- (IBAction)pickerCancel:(id)sender {
    [UIView animateWithDuration:1.0 animations:^{
        self.pickerHidingView.alpha=1.0;
    }];
    _typeLabel.text=[_items objectAtIndex:_last];
    [self.pickerView selectRow:_last inComponent:0 animated:YES];
}

- (IBAction)pickerSave:(id)sender {
    [UIView animateWithDuration:1.0 animations:^{
        self.pickerHidingView.alpha=1.0;
        self.typeLabel.textColor=[UIColor lighterYellow];
        self.typeTitleLAbel.textColor=[UIColor lighterYellow];
    }];
    _last=[_items indexOfObject: _typeLabel.text];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)add:(id)sender {
    NSString *result = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([self.descriptionTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Description must be filled" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else if([result length]<2){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Name is to short(spaces, tabs are not included in counting)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else if([self.nameTextField.text length]>64){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Name is to long(max64)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else if([MHDatabaseManager getCollectionWithObjName:self.nameTextField.text]!=nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Collection of that name exists." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }
    else{
#warning create collection without objId, update objId once uploaded to the server.
        [MHDatabaseManager insertCollectionWithObjId:[NSString stringWithFormat:@"%u",arc4random()%10000]
                                             objName:self.nameTextField.text
                                      objDescription:self.descriptionTextField.text
                                             objTags:[NSArray arrayWithArray:[self.tagsTextField.text componentsSeparatedByString:@" "]]
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
        [UIView animateWithDuration:1.0 animations:^{
            self.pickerHidingView.alpha=0.0;
        }];
    }
    return YES;
}

-(void)dismissKeyboard {
    [_nameTextField resignFirstResponder];
    [_tagsTextField resignFirstResponder];
    [_descriptionTextField resignFirstResponder];
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
