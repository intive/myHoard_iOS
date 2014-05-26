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
#import "MHItem.h"

const NSInteger kAlertViewOne = 1;

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
    for (MHTag *tag in _collection.tags) {
        tags = [NSString stringWithFormat:@"%@%@ ", tags, tag.tag];
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
        
        if (_type==0) {
            self.collection.objType = collectionTypePublic;
        } else if (_type==1){
            self.collection.objType = collectionTypePrivate;
        } else if (_type == 2){
            self.collection.objType = collectionTypeOffline;
        }
        
        if (_collection.objType == collectionTypeOffline){
            UIAlertView *alert5 = [[UIAlertView alloc]initWithTitle:nil message:@"Do you want to remove the collection from server? The collection will be stored in this device." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alert5 show];
        }
        else if (_collection.objType == collectionTypePrivate || self.collection.objType == collectionTypePublic)
        {
            __block NSArray *predicationResult;
            __block NSPredicate *predicate;
            
            [[MHAPI getInstance]readUserCollectionsWithCompletionBlock:^(id object, NSError *error) {
                predicate = [NSPredicate predicateWithFormat:@"id == %@", _collection.objId];
                predicationResult = [object filteredArrayUsingPredicate:predicate];
                
                if ([predicationResult count]) {
                    [waitDialog show];
                    self.collection.objStatus = objectStatusModified;
                    [[MHAPI getInstance]updateCollection:self.collection completionBlock:^(id object, NSError *error){
                        if (error){
                            [waitDialog dismiss];
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        }
                        else
                            [waitDialog dismiss];
                    }];
                }else {
                    [waitDialog show];
                    [[MHAPI getInstance]createCollection:_collection completionBlock:^(id object, NSError *error) {
                        if (error) {
                            [waitDialog dismiss];
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        }else {
                            [self createItemsAndMediaOnServer:waitDialog];
                        }
                    }];
                }
            }];
        }
    }
}

- (void)createItemsAndMediaOnServer:(MHWaitDialog *)waitDialog {
    
    NSArray *items;
    if ([_collection.items count] > 0) {
        items = [_collection.items allObjects];
    }
    
    [items enumerateObjectsUsingBlock:^(MHItem *item, NSUInteger idx, BOOL *stop) {
        NSArray *allMedia;
        if ([item.media count] > 0) {
            allMedia = [item.media allObjects];
            [allMedia enumerateObjectsUsingBlock:^(MHMedia *media, NSUInteger idx, BOOL *stop) {
                [[MHAPI getInstance]createMedia:media completionBlock:^(id object, NSError *error) {
                    if (error) {
                        [waitDialog dismiss];
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }else {
                        if (media == [allMedia lastObject]) {
                            [[MHAPI getInstance]createItem:item completionBlock:^(id object, NSError *error) {
                                if (error) {
                                    [waitDialog dismiss];
                                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                    [alert show];
                                }else {
                                    [waitDialog dismiss];
                                }
                            }];
                        }
                    }
                }];
            }];
        }else {
            [[MHAPI getInstance]createItem:item completionBlock:^(id object, NSError *error) {
                if (error) {
                    [waitDialog dismiss];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }else {
                    [waitDialog dismiss];
                }
            }];
        }
    }];
}

- (IBAction)deleteCollection:(id)sender {
    
    UIAlertView *question = [[UIAlertView alloc]initWithTitle:nil message:@"Do you want to remove this collection?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    question.tag = kAlertViewOne;
    [question show];
}

- (void)deleteCollectionMethod {
    
    __block MHWaitDialog *waitDialog = [[MHWaitDialog alloc]init];

    if ([[MHAPI getInstance]activeSession]) {
        if (![_collection.objType isEqualToString:collectionTypeOffline] && ![_collection.objStatus isEqualToString:objectStatusNew]) {
            if ([_collection.items count]) {
                for (MHItem *item in _collection.items) {
                    for (MHMedia *media in item.media) {
                        [[MHAPI getInstance]deleteMedia:media completionBlock:^(id object, NSError *error) {
                            if (error) {
                                NSLog(@"%@", error);
                            }else {
                                [item removeMediaObject:media];
                            }
                        }];
                    }
                    
                    [[MHAPI getInstance]deleteItemWithId:item completionBlock:^(id object, NSError *error) {
                        if (error) {
                            NSLog(@"%@", error);
                        }else {
                            [_collection removeItemsObject:item];
                        }
                    }];
                }
                
                [[MHAPI getInstance] deleteCollection:_collection completionBlock:^(id object, NSError *error){
                    if (error)
                    {
                        [waitDialog dismiss];
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        NSLog(@"%@", object);
                    }
                    else {
                        [self deleteCollectionFromCoreData];
                        [waitDialog dismiss];
                    }
                }];
                
            }else{
                [[MHAPI getInstance] deleteCollection:_collection completionBlock:^(id object, NSError *error){
                    if (error)
                    {
                        [waitDialog dismiss];
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        NSLog(@"%@", object);
                    }
                    else {
                        [self deleteCollectionFromCoreData];
                        [waitDialog dismiss];
                    }
                }];
            }
        }else {
            [self deleteCollectionFromCoreData];
            [waitDialog dismiss];
        }
    }else {
        
        [self deleteCollectionFromCoreData];
        [waitDialog dismiss];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteCollectionFromCoreData {
    [[[MHCoreDataContext getInstance] managedObjectContext] deleteObject:_collection];
    [[MHCoreDataContext getInstance]saveContext];
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
    }else if([MHDatabaseManager collectionWithObjName:self.nameTextField.text]!= nil && _collection == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Collection of that name exists." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    } else {
        NSString *colllectionType = [[NSString alloc]init];
        if (_type==0) {
            colllectionType = collectionTypePublic;
        } else if (_type==1){
            colllectionType = collectionTypePrivate;
        } else if (_type == 2){
            colllectionType = collectionTypeOffline;
        }
        
        if (_collection) {
            
            NSArray *collections = [[NSArray alloc] initWithArray:[MHDatabaseManager allCollections]];
            for (MHCollection *col in collections) {
                if([col.objName isEqualToString:self.nameTextField.text] && !([col.objCreatedDate isEqualToDate:_collection.objCreatedDate])) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Collection of that name exists." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                    [alert show];
                }
                
            }
            

            
            _collection.objName = trimmedString;
            _collection.objDescription = self.descriptionTextField.text;
            _collection.objModifiedDate = [NSDate date];
            //remove all tags
            [_collection removeTags:_collection.tags];

            //add new tags
            NSArray* tags = [_tagsTextField.text tags];
            for (NSString *tag in tags) {
                [MHDatabaseManager insertTag:tag forObject:_collection];
            }
            [[MHCoreDataContext getInstance] saveContext];
            
            if ([[MHAPI getInstance]activeSession] == YES) {
                if (![_collection.objType isEqualToString:collectionTypeOffline]) {
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
            }
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
                if (![colllectionType isEqualToString:collectionTypeOffline]) {
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
    
    if (alert5.tag == kAlertViewOne) {
        if (buttonIndex == 1) {
            [self deleteCollectionMethod];
        }
    }else {
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
