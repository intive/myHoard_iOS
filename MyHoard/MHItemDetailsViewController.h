//
//  MHItemDetailsViewController.h
//  MyHoard
//
//  Created by user on 2/16/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHItemDetailsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *itemNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *itemIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *itemCollectionIdTextField;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)deleteItem:(id)sender;
- (IBAction)deleteItemCollection:(id)sender;

@end
