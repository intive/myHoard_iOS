//
//  MHAddCollectionViewController.m
//  MyHoard
//
//  Created by Konrad Gnoinski on 12/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHAddCollectionViewController.h"
#import "MHDatabaseManager.h"
#import "NSString+Tags.h"
#import "MHAPI.h"
#import "MHWaitDialog.h"
#import "MHCoreDataContext.h"

@interface MHAddCollectionViewController ()
@property (readwrite) NSUInteger last;
@property (readwrite) NSUInteger type;
@end

@implementation MHAddCollectionViewController

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
    
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"check"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(add:)];
    self.navigationController.navigationBar.topItem.rightBarButtonItems = @[save];

    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(cancel:)];
    self.navigationController.navigationBar.topItem.leftBarButtonItems = @[cancel];
    _items = [[NSArray alloc]initWithObjects:@"Public", @"Private", @"Offline", nil];
    _last=0;
    
    _deleteCollectionView.backgroundColor = [UIColor appBackgroundColor];
    
    if (_collection != nil) {
        [self loadCollectionSettings];
    } else {
        _deleteCollectionButton.hidden = YES;
        _deleteCollectionView.hidden = YES;
        _deleteCollectionButton.enabled = NO;
    }
    
    if(![[MHAPI getInstance]userId]){
        self.typeButtonO.hidden = YES;
        self.typeLabel.text = @"Offline";}
}

- (void)loadCollectionSettings
{
    _nameTextField.text = _collection.objName;
    NSString *tags = @"";
    for (NSString *tag in _collection.objTags) {
        tags = [NSString stringWithFormat:@"%@%@ ", tags, tag];
    }
    _tagsTextField.text = tags;
    _descriptionTextField.text = _collection.objDescription;
    _screenTitle.title = @"Edit Collection";
    
    if ([self.collection.objType isEqualToString:collectionTypePublic]){
        self.typeLabel.text = @"Public";
        [self.pickerView selectRow:0 inComponent:0 animated:YES];
    }
    if ([self.collection.objType isEqualToString:collectionTypePrivate]){
        self.typeLabel.text = @"Private";
        [self.pickerView selectRow:1 inComponent:0 animated:YES];
    }
    if ([self.collection.objType isEqualToString:collectionTypeOffline]){
        self.typeLabel.text = @"Offline";
        [self.pickerView selectRow:2 inComponent:0 animated:YES];
    }
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
    __block MHWaitDialog *waitDialog = [[MHWaitDialog alloc]init];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.pickerHidingView.alpha=1.0;
        self.typeLabel.textColor=[UIColor lighterYellow];
        self.typeTitleLAbel.textColor=[UIColor lighterYellow];
    }];
    _last=[_items indexOfObject: _typeLabel.text];
    if (self.collection){
        if (self.type==2){
            UIAlertView *alert5 = [[UIAlertView alloc]initWithTitle:nil message:@"Do you want to remove the collection from server? The collection will be stored in this device." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alert5 show];
        }
        if (self.type==1)
        {
            [waitDialog show];
            [[MHAPI getInstance]createCollection:self.collection completionBlock:^(id object, NSError *error){
                if (error){
                    [waitDialog dismiss];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                else
                    [waitDialog dismiss];
            }];
        }
    }
}

- (IBAction)deleteCollection:(id)sender {
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)add:(id)sender {
    NSString *result = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedString = [self.nameTextField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    if([result length]<2){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Name is to short(spaces, tabs are not included in counting)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else if([self.nameTextField.text length]>64){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Name is to long(max64)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else if([MHDatabaseManager collectionWithObjName:self.nameTextField.text]!= nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Collection of that name exists." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    } else {
        NSString *colllectionType = [[NSString alloc]init];
        if (_type==0) {
            colllectionType = collectionTypePublic;
        } else if (_type==1){
            colllectionType = collectionTypePrivate;
        } else {
            colllectionType = collectionTypeOffline;
        }
        if (_collection) {
            
            MHCollection *collection = [MHDatabaseManager collectionWithObjName:_collection.objName];
            collection.objName = trimmedString;
            collection.objDescription = self.descriptionTextField.text;
            collection.objModifiedDate = [NSDate date];
            collection.objTags = [_tagsTextField.text tags];
            [[MHCoreDataContext getInstance] saveContext];
            /*
            if ([[MHAPI getInstance]activeSession] == YES) {
                NSLog(@"Yes you are logged in");
                
                if (![_typeLabel.text isEqualToString:@"Offline"]) {
                    __block MHWaitDialog* wait = [[MHWaitDialog alloc] init];
                    [wait show];
                    [[MHAPI getInstance] updateCollection:_collection completionBlock:^(id object, NSError *error) {
                        [wait dismiss];
                        
                        if (error) {
                            UIAlertView *alert = [[UIAlertView alloc]
                                                  initWithTitle:@"Error"
                                                  message:error.localizedDescription
                                                  delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
                            [alert show];
                            NSLog(@"%@", error);
                        }
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }];
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
             
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }*/
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            MHCollection* collection = [MHDatabaseManager insertCollectionWithObjName:trimmedString
                                                                       objDescription:self.descriptionTextField.text
                                                                              objTags:[self.tagsTextField.text tags]
                                                                       objCreatedDate:[NSDate date]
                                                                      objModifiedDate:nil
                                                          objOwnerNilAddLogedUserCode:nil
                                                                            objStatus:objectStatusNew
                                        objType:colllectionType];
        
            if ([[MHAPI getInstance]activeSession] == YES) {
                if (![_typeLabel.text isEqualToString:collectionTypeOffline]) {
                    __block MHWaitDialog* wait = [[MHWaitDialog alloc] init];
                    [wait show];
                    [[MHAPI getInstance] createCollection:collection completionBlock:^(id object, NSError *error) {
                        [wait dismiss];
                        if (error) {
                            UIAlertView *alert = [[UIAlertView alloc]
                                                  initWithTitle:@"Error"
                                                  message:error.localizedDescription
                                                  delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
                            [alert show];
                            NSLog(@"%@", error);
                        }
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }];
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                }
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}

- (void) alertView:(UIAlertView *)alert5 clickedButtonAtIndex:(NSInteger)buttonIndex{
    __block MHWaitDialog *waitDialog = [[MHWaitDialog alloc]init];
    switch (buttonIndex) {
        case 1:
            [waitDialog show];
            self.collection.objStatus = objectStatusDeleted;
            self.collection.objType = collectionTypeOffline;
            [[MHAPI getInstance] deleteCollection:self.collection completionBlock:^(id object, NSError *error){
                if (error)
                {
                    [waitDialog dismiss];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                else
                    [waitDialog dismiss];
            }];
            break;
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
    _type=row;
    _typeLabel.text=_items[row];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = _items[row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor darkerYellow]}];
    
    return attString;
    
}


@end
