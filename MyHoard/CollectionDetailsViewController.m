//
//  CollectionDetailsViewController.m
//  MyHoard
//
//  Created by user on 2/16/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "CollectionDetailsViewController.h"
#import "MHDatabaseManager.h"

@interface CollectionDetailsViewController ()

@end

@implementation CollectionDetailsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.collectionNameTextField.delegate = self;
    self.collectionIdTextField.delegate = self;
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    enum {kSectionCollectionName = 0, kSectionCollectionId};
    
    if (indexPath.section == kSectionCollectionName) {
        [self.collectionNameTextField becomeFirstResponder];
    }else if (indexPath.section == kSectionCollectionId) {
        [self.collectionIdTextField becomeFirstResponder];
    }
}

- (IBAction)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)done:(id)sender {

    [MHDatabaseManager insertCollectionWithObjId: [NSString stringWithFormat:@"%@", self.collectionIdTextField.text] objName:[NSString stringWithFormat:@"%@", self.collectionNameTextField.text] objDescription:nil objTags:nil objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)deleteCollection:(id)sender {
    
    if (!self.collectionIdTextField.text.length) {
        NSLog(@"To delete a collection you need to specify objId");
        return;
    }
    
    [MHDatabaseManager removeCollectionWithId:self.collectionIdTextField.text];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (IBAction)search:(id)sender {
    
    if (!self.collectionIdTextField.text.length) {
        NSLog(@"To search for a collection you need to specify objId");
        return;
    }
    
    NSLog(@"%@",[MHDatabaseManager getCollectionWithObjId:self.collectionIdTextField.text]);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
