//
//  MHItemDetailsViewController.m
//  MyHoard
//
//  Created by user on 2/16/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHItemDetailsViewController.h"
#import "MHDatabaseManager.h"

@interface MHItemDetailsViewController ()

@end

@implementation MHItemDetailsViewController

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
    self.itemIdTextField.delegate = self;
    self.itemNameTextField.delegate = self;
    self.itemCollectionIdTextField.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    enum {kSectionItemName = 0, kSectionItemId, kSectionItemCollectionId};

    if (indexPath.section == kSectionItemName) {
        [self.itemNameTextField becomeFirstResponder];
    }else if (indexPath.section == kSectionItemId) {
        [self.itemIdTextField becomeFirstResponder];
    }else if (indexPath.section == kSectionItemCollectionId) {
        [self.itemCollectionIdTextField becomeFirstResponder];
    }
  
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (IBAction)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    
    [MHDatabaseManager insertItemWithObjId:[NSString stringWithFormat:@"%@", self.itemIdTextField.text] objName:[NSString stringWithFormat:@"%@", self.itemNameTextField.text] objDescription:nil objTags:nil objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:[NSString stringWithFormat:@"%@", self.itemCollectionIdTextField.text] objOwner:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)deleteItem:(id)sender {
    
    if (!self.itemIdTextField.text.length) {
        NSLog(@"To delete an item you need to specify objId");
        return;
    }
    
    [MHDatabaseManager removeItemWithObjId:self.itemIdTextField.text];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)deleteItemCollection:(id)sender {
    
    
    if (!self.itemCollectionIdTextField.text.length) {
        NSLog(@"To delete an item you need to specify objCollectionId");
        return;
    }
    
    [MHDatabaseManager removeAllItemForCollectionWithObjId:self.itemCollectionIdTextField.text];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
